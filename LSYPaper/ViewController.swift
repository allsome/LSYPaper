//
//  ViewController.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/2/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

let cellGap:CGFloat = 2
private let tinyCellReuseIdentifier = "TinyNewsDetailCell"
private let fullScreenCellReuseIdentifier = "BigNewsDetailCell"

private let fullScreenGap:CGFloat = cellGap * SCREEN_WIDTH / normalCellWidth

private let tinyCollectFrame = CGRectMake(-(SCREEN_WIDTH * 3 / minCellRatio - SCREEN_WIDTH) / 2, POSTER_HEIGHT, SCREEN_WIDTH * 3 / minCellRatio, CELL_NORMAL_HEIGHT)
private let fullScreenCollectFrame = CGRectMake(-SCREEN_WIDTH * 2, 0, SCREEN_WIDTH * 5, SCREEN_HEIGHT)

private let hideStartRatio:CGFloat = 4 / 7
private let hideOverRatio:CGFloat = 0.85

private let minCellRatio:CGFloat = 3 / 4
private let maxCellRatio:CGFloat = 1.5
private let minScale:CGFloat = 0.95
private let normalCellWidth:CGFloat = CELL_NORMAL_HEIGHT * SCREEN_WIDTH / SCREEN_HEIGHT

class ViewController: UIViewController {
    
    private let tinyCollectionView = UICollectionView(frame: tinyCollectFrame, collectionViewLayout: UICollectionViewFlowLayout())
    private let fullScreenCollectionView = UICollectionView(frame: fullScreenCollectFrame, collectionViewLayout: UICollectionViewFlowLayout())

    private var pageControl:LSYPageControl = LSYPageControl()
    private var blackView:UIView = UIView()
    
    private var collectLayout:UICollectionViewFlowLayout {
        return tinyCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var tinyCollectionViewLayout:UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSizeMake(normalCellWidth, CELL_NORMAL_HEIGHT)
        layout.minimumLineSpacing = cellGap
        layout.sectionInset = UIEdgeInsetsMake(0, (tinyCollectionView.frame.width - SCREEN_WIDTH) / 2 + cellGap, 0, (tinyCollectionView.frame.width - SCREEN_WIDTH) / 2 + cellGap)
        return layout
    }
    private var fullScreenCollectionViewLayout:UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)
        layout.minimumLineSpacing = fullScreenGap
        layout.sectionInset = UIEdgeInsetsMake(0, (fullScreenCollectionView.frame.width - SCREEN_WIDTH) / 2 + fullScreenGap, 0, (fullScreenCollectionView.frame.width - SCREEN_WIDTH) / 2 + fullScreenGap)
        return layout
    }
    
    private var tinyPanCollect:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var fullScreenPanCollect:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var isPanVertical:Bool = false
    private var isFromFullScreen:Bool = false
    private var hasReachNormalHeightFromFullScreen:Bool = false
    private var reachNormalLocationYFromFullScreen:CGFloat = 0.0
    private var reachNormalTransitionYFromFullScreen:CGFloat = 0.0
    private var locationInView:CGPoint = CGPointZero
    private var translationInView:CGPoint = CGPointZero
    private var contentOffset:CGPoint = CGPointZero
    private var locationRatio:CGFloat = 0
    private var newCellHeight:CGFloat = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPageControl()
        setMessageView()
        setBlackView()
        setCollectionView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func handleTinyCollectPanGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            let velocity = recognizer.velocityInView(view)
            if fabs(velocity.x) <= fabs(velocity.y) {
                locationInView = recognizer.locationInView(view)
                locationRatio = locationInView.x / (collectLayout.minimumLineSpacing + collectLayout.itemSize.width)
                isPanVertical = true
                isFromFullScreen = false
                tinyCollectionView.panGestureRecognizer.enabled = false
                contentOffset = tinyCollectionView.contentOffset
                setAnchorPoint(CGPointMake((locationInView.x - tinyCollectionView.frame.origin.x) / tinyCollectionView.frame.width, 1), view: tinyCollectionView)
                setAnchorPoint(CGPointMake((locationInView.x - fullScreenCollectionView.frame.origin.x) / fullScreenCollectionView.frame.width, 1), view: fullScreenCollectionView)
            }
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            if isPanVertical {
                translationInView = recognizer.translationInView(view)
                if translationInView.y >= 0 {
                    newCellHeight = computeCellHeightUnderExtraZoomOut()
                }else {
                    newCellHeight = computeCellHeightUnderNormalZoomInOut()
                    if newCellHeight >= SCREEN_HEIGHT {
                        reachNormalHeightSetting(recognizer)
                        newCellHeight = computeCellHeightUnderExtraZoomIn()
                    }
                }
                var scale = ((minScale - 1) * newCellHeight + SCREEN_HEIGHT - minScale * CELL_NORMAL_HEIGHT) / (SCREEN_HEIGHT - CELL_NORMAL_HEIGHT)
                if scale >= 1 {
                    scale = 1
                }
                let alpha = newCellHeight / SCREEN_HEIGHT / (hideStartRatio - hideOverRatio) - (hideOverRatio / (hideStartRatio - hideOverRatio))
                print(alpha)
                tinyCollectionView.alpha = alpha
                fullScreenCollectionView.alpha = 1 - alpha
                blackView.alpha = -20 * scale + 20
                pageControl.transform = CGAffineTransformMakeScale(scale, scale)
                let tinyRatio = newCellHeight / CELL_NORMAL_HEIGHT
                let fullRatio = newCellHeight / SCREEN_HEIGHT
                tinyCollectionView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(tinyRatio, tinyRatio),CGAffineTransformMakeTranslation(translationInView.x, 0))
                fullScreenCollectionView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(fullRatio, fullRatio),CGAffineTransformMakeTranslation(translationInView.x, 0))
            }
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            if isPanVertical == true {
                let isFullScreen = collectLayout.itemSize.width / SCREEN_WIDTH > 2 / 3
                let scale:CGFloat = isFullScreen ? minScale : 1.0
                let alpha:CGFloat = isFullScreen ? 1.0 : 0.0
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    let gapNum:CGFloat = self.translationInView.x * 50 / SCREEN_WIDTH
                    var pointX = self.contentOffset.x - self.translationInView.x + gapNum
                    if pointX <= 0 {
                        pointX = 0
                    }
                    self.tinyCollectionView.setContentOffset(CGPointMake(pointX, self.contentOffset.y), animated: false)
                    self.tinyCollectionView.transform = CGAffineTransformIdentity
                    self.tinyCollectionView.alpha = 1.0
                    self.pageControl.transform = CGAffineTransformMakeScale(scale, scale)
                    self.blackView.alpha = alpha
                    }, completion: { (stop:Bool) -> Void in
                        self.isPanVertical = false
                        self.hasReachNormalHeightFromFullScreen = false
                        self.tinyCollectionView.panGestureRecognizer.enabled = true
                })
            }
        }
    }
    
    /* panOffY * panOffY = (locationY / screenH) * (locationY / screenH) * (maxRatio - 1) * (maxRatio - 1) * screenH * (-translationY) */
    private func computeCellHeightUnderExtraZoomIn() -> CGFloat {
        let gap = isFromFullScreen == false ? (-translationInView.y + reachNormalTransitionYFromFullScreen < 0 ? 0 : -translationInView.y + reachNormalTransitionYFromFullScreen) : -translationInView.y
        let panOffsetY = (locationInView.y - POSTER_HEIGHT) / SCREEN_HEIGHT * (maxCellRatio - 1) * sqrt(SCREEN_HEIGHT * (gap))
        return SCREEN_HEIGHT + panOffsetY
    }
    
    /* (normalHeight - locationY) / normalHeight = (normalHeight - (locationY + transitionY)) / newCellHeight */
    private func computeCellHeightUnderNormalZoomInOut() -> CGFloat {
        let targetCellheight = isFromFullScreen == false ? CELL_NORMAL_HEIGHT : SCREEN_HEIGHT
        return ((targetCellheight - (locationInView.y - POSTER_HEIGHT + translationInView.y)) * targetCellheight) / (targetCellheight - locationInView.y + POSTER_HEIGHT)
    }
    
    /* panOffY * panOffY = (1- minRatio) * (1- minRatio) * normalHeight * normalHeight * transitionY/ (normalHeight - locationY) */
    private func computeCellHeightUnderExtraZoomOut() -> CGFloat {
        let gap = isFromFullScreen == false ? translationInView.y :         (translationInView.y - reachNormalTransitionYFromFullScreen < 0 ? 0 : translationInView.y - reachNormalTransitionYFromFullScreen)
        let denominator = isFromFullScreen == false ? CELL_NORMAL_HEIGHT - locationInView.y + POSTER_HEIGHT : CELL_NORMAL_HEIGHT - reachNormalLocationYFromFullScreen + POSTER_HEIGHT
        let panOffsetY = (1 - minCellRatio) * CELL_NORMAL_HEIGHT * sqrt(gap / denominator)
        return CELL_NORMAL_HEIGHT - panOffsetY
    }
    
    private func reachNormalHeightSetting(recognizer:UIPanGestureRecognizer) {
        if hasReachNormalHeightFromFullScreen == false {
            reachNormalLocationYFromFullScreen = recognizer.locationInView(view).y
            reachNormalTransitionYFromFullScreen = recognizer.translationInView(view).y
            hasReachNormalHeightFromFullScreen = true
        }
    }
}

private extension ViewController {
    private func setPageControl() {
        
        let path = NSBundle.mainBundle().pathForResource("Section", ofType: "plist")
        let dicArray = NSArray(contentsOfFile: path!)
        
        var views = [UIView]()
        for index in 0 ..< dicArray!.count {
            let dic = dicArray?.objectAtIndex(index)
            let data = SectionData(dictionary: dic as! [String : AnyObject])
            let frame = CGRectMake(SCREEN_WIDTH * CGFloat(index), 0, SCREEN_WIDTH, SCREEN_HEIGHT)
            let view = SectionPosterView.sectionPosterViewWith(data: data, frame: frame)
            views.append(view)
        }
        
        let pageControl = LSYPageControl.pageControlWith(CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), views: views)
        pageControl.pageControlBottomConstraint.constant = SCREEN_HEIGHT - POSTER_HEIGHT
        pageControl.didScrollOption = {(targetPage:NSInteger,views:[UIView],contentOffsetX:CGFloat) in
            let view = views[targetPage] as! SectionPosterView
            let frame = view.titleLabel.convertRect(view.titleLabel.bounds, toView: self.view)
            
            let rightEdge = SCREEN_WIDTH - 20
            let leftEdge = SCREEN_WIDTH - 151
            if frame.origin.x > rightEdge {
                view.titleLabel.alpha = (frame.origin.x - rightEdge) / view.titleLabel.bounds.width
            }else if frame.origin.x <= rightEdge && frame.origin.x >= leftEdge {
                view.titleLabel.alpha = 0.0
            }else {
                view.titleLabel.alpha = (leftEdge - frame.origin.x) / view.titleLabel.bounds.width
            }
            
            let firstView = views.first
            if contentOffsetX == 0 {
                firstView!.layer.masksToBounds = false
            }else if contentOffsetX < 0 {
                firstView!.layer.masksToBounds = true
                firstView!.layer.cornerRadius = CORNER_REDIUS
            }
        }
        
        pageControl.pageDidChangeOption = {(currentPage:Int,changeDirection:PageChangeDirectionType) in
            self.tinyCollectionView.setContentOffset(CGPointZero, animated: false)
            let anim = CATransition()
            anim.type = kCATransitionPush
            anim.subtype = changeDirection == PageChangeDirectionType.Left ? kCATransitionFromLeft : kCATransitionFromRight
            anim.duration = 0.25
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.tinyCollectionView.layer.addAnimation(anim, forKey: nil)
        }
        
        pageControl.didScrollCrossLeftEdge = {(contentOffsetX:CGFloat) in
            if self.tinyCollectionView.contentOffset.x == 0 {
                self.tinyCollectionView.transform = CGAffineTransformMakeTranslation(-contentOffsetX, 0)
            }
        }
        
        pageControl.didScrollCrossRightEdge = {(translation:CGFloat,lastView:UIView) in
            if translation == 0 {
                lastView.layer.masksToBounds = false
            }else if translation < 0 {
                lastView.layer.masksToBounds = true
                lastView.layer.cornerRadius = CORNER_REDIUS
            }

        }
        
        pageControl.backFromLeftEdge = {() in
            self.tinyCollectionView.setContentOffset(CGPointZero, animated: true)
        }
        self.pageControl = pageControl
        view.addSubview(pageControl)
        view.setSpecialCorner([UIRectCorner.TopLeft,UIRectCorner.TopRight])
    }
    
    private func setMessageView() {
        let messageView = MessageView.messageViewWith(frame: CGRectMake(SCREEN_WIDTH - 135, 0, 135, 55))
        self.pageControl.addSubview(messageView)
    }
    
    private func setBlackView() {
        blackView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        blackView.backgroundColor = UIColor.blackColor()
        blackView.alpha = 0.0
        view.addSubview(blackView)
    }
    
    private func setCollectionView() {
        tinyCollectionView.backgroundColor = UIColor.clearColor()
        tinyCollectionView.dataSource = self
        tinyCollectionView.delegate = self
        var nib = UINib(nibName: tinyCellReuseIdentifier, bundle: nil)
        tinyCollectionView.registerNib(nib, forCellWithReuseIdentifier: tinyCellReuseIdentifier)
        tinyPanCollect = UIPanGestureRecognizer(target: self, action: "handleTinyCollectPanGesture:")
        tinyPanCollect.delegate = self
        tinyPanCollect.maximumNumberOfTouches = 1
        tinyCollectionView.addGestureRecognizer(tinyPanCollect)
        tinyCollectionView.collectionViewLayout = tinyCollectionViewLayout
        view.addSubview(tinyCollectionView)
        
        fullScreenCollectionView.backgroundColor = UIColor.clearColor()
        fullScreenCollectionView.dataSource = self
        fullScreenCollectionView.delegate = self
        nib = UINib(nibName: fullScreenCellReuseIdentifier, bundle: nil)
        fullScreenCollectionView.registerNib(nib, forCellWithReuseIdentifier: fullScreenCellReuseIdentifier)
        fullScreenPanCollect = UIPanGestureRecognizer(target: self, action: "handleFullScreenCollectPanGesture:")
        fullScreenPanCollect.delegate = self
        fullScreenPanCollect.maximumNumberOfTouches = 1
        fullScreenCollectionView.addGestureRecognizer(fullScreenPanCollect)
        fullScreenCollectionView.collectionViewLayout = fullScreenCollectionViewLayout
        fullScreenCollectionView.alpha = 0.0
        view.addSubview(fullScreenCollectionView)
    }
    
    func setAnchorPoint(anchorPoint:CGPoint,view:UIView) {
        let oldFrame = view.frame
        view.layer.anchorPoint = anchorPoint
        view.frame = oldFrame
    }
}

extension ViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tinyPanCollect && otherGestureRecognizer == tinyCollectionView.panGestureRecognizer {
            return true
        } else if gestureRecognizer == fullScreenPanCollect && otherGestureRecognizer == fullScreenCollectionView.panGestureRecognizer{
            return true
        } else {
            return false
        }
    }
}

extension ViewController:UICollectionViewDelegate {
}

extension ViewController:UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == tinyCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(tinyCellReuseIdentifier, forIndexPath: indexPath) as! TinyNewsDetailCell
            cell.testLabel.text = String(indexPath.item)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(fullScreenCellReuseIdentifier, forIndexPath: indexPath) as! BigNewsDetailCell
            cell.testLabel.text = String(indexPath.item)
            return cell
        }
    }
}

