//
//  ViewController.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/2/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

let cellGap:CGFloat = 2
private let cellReuseIdentifier = "NewsDetailCell"
private let maxTitleLabelY = SCREEN_WIDTH + 15
private let collectionViewFrame = CGRectMake(0, POSTER_HEIGHT, SCREEN_WIDTH, CELL_NORMAL_HEIGHT)
private let fullScreenCollectFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

private let minCellRatio:CGFloat = 3 / 4
private let maxCellRatio:CGFloat = 1.5
private let normalCellWidth:CGFloat = CELL_NORMAL_HEIGHT * SCREEN_WIDTH / SCREEN_HEIGHT

class ViewController: UIViewController {
    
    private let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: UICollectionViewFlowLayout())
    private var pageControl:LSYPageControl = LSYPageControl()
    private var collectLayout:UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    private var normalCollectLayout:UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSizeMake(normalCellWidth, CELL_NORMAL_HEIGHT)
        layout.minimumLineSpacing = cellGap
        layout.sectionInset = UIEdgeInsetsMake(0, cellGap, 0, cellGap)
        return layout
    }
    private var fullScreenLayout:UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let fullScreenGap = cellGap * SCREEN_WIDTH / normalCellWidth
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)
        layout.minimumLineSpacing = fullScreenGap
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, fullScreenGap)
        return layout
    }
    private var panCollect:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var isPanVertical:Bool = false
    private var isFromFullScreen:Bool = false
    private var hasReachNormalHeightFromFullScreen:Bool = false
    private var reachNormalLocationYFromFullScreen:CGFloat = 0.0
    private var reachNormalTransitionYFromFullScreen:CGFloat = 0.0
    private var locationInView:CGPoint = CGPointZero
    private var translationInView:CGPoint = CGPointZero
    private var locationRatio:CGFloat = 0
    
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
        setCollectionView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func handleCollectPanGesture(recognizer:UIPanGestureRecognizer) {
        let velocity = recognizer.velocityInView(view)
        if recognizer.state == UIGestureRecognizerState.Began {
            if fabs(velocity.x) <= fabs(velocity.y) {
                collectionView.panGestureRecognizer.enabled = false
                locationInView = recognizer.locationInView(collectionView)
                locationRatio = locationInView.x / (collectLayout.minimumLineSpacing + collectLayout.itemSize.width)
                isPanVertical = true
                isFromFullScreen = collectionView.frame.height == SCREEN_HEIGHT ? true : false
            }
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            if isPanVertical {
                translationInView = recognizer.translationInView(view)
                var newCellHeight:CGFloat = 0
                if isFromFullScreen == false {
                    if translationInView.y >= 0 {
                        newCellHeight = computeCellHeightUnderExtraZoomOut()
                    }else {
                        newCellHeight = computeCellHeightUnderNormalZoomInOut()
                        if newCellHeight >= SCREEN_HEIGHT {
                            reachNormalHeightSetting(recognizer)
                            newCellHeight = computeCellHeightUnderExtraZoomIn()
                        }
                    }
                }else {
                    if translationInView.y >= 0 {
                        newCellHeight = computeCellHeightUnderNormalZoomInOut()
                        if newCellHeight <= CELL_NORMAL_HEIGHT {
                            reachNormalHeightSetting(recognizer)
                            newCellHeight = computeCellHeightUnderExtraZoomOut()
                        }
                    }else {
                        newCellHeight = computeCellHeightUnderExtraZoomIn()
                    }
                }
                let newCellWidth = normalCellWidth * newCellHeight / CELL_NORMAL_HEIGHT
                let ratio = newCellWidth / normalCellWidth
                let newCellGap = ratio * cellGap
                let fastenCellGap = locationInView.x - locationRatio * (newCellWidth + newCellGap)
                let targetCellheight = isFromFullScreen == false ? CELL_NORMAL_HEIGHT : SCREEN_HEIGHT
                collectLayout.itemSize = CGSizeMake(newCellWidth, newCellHeight)
                collectLayout.minimumLineSpacing = newCellGap
                collectLayout.sectionInset = UIEdgeInsetsMake(targetCellheight - newCellHeight, newCellGap + fastenCellGap + translationInView.x, 0, newCellGap)
            }
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            if isPanVertical == true {
                let isZoomed = collectLayout.itemSize.width / normalCellWidth > 1
                let duration = isZoomed ? 0.3 : 0.2
                let option = isZoomed ? UIViewAnimationOptions.CurveEaseInOut:UIViewAnimationOptions.CurveEaseOut
                
                let isFullScreen = collectLayout.itemSize.width / SCREEN_WIDTH > 2 / 3
                let layout = isFullScreen ? self.fullScreenLayout : self.normalCollectLayout
                self.collectionView.pagingEnabled = isFullScreen ? true : false
                self.collectionView.frame = isFullScreen ? fullScreenCollectFrame : collectionViewFrame
                UIView.animateWithDuration(duration, delay: 0.0, options: option, animations: { () -> Void in
                    self.collectionView.setCollectionViewLayout(layout, animated: true)
                    }, completion: { (stop:Bool) -> Void in
                        self.collectionView.panGestureRecognizer.enabled = true
                        self.isPanVertical = false
                        self.hasReachNormalHeightFromFullScreen = false
                        self.reachNormalLocationYFromFullScreen = 0
                        self.reachNormalTransitionYFromFullScreen = 0
                })
            }
        }
    }
    
    // panOffY * panOffY = (locationY / screenH) * (locationY / screenH) * (maxRatio - 1) * (maxRatio - 1) * screenH * (-translationY)
    func computeCellHeightUnderExtraZoomIn() -> CGFloat {
        let gap = isFromFullScreen == false ? (-translationInView.y + reachNormalTransitionYFromFullScreen < 0 ? 0 : -translationInView.y + reachNormalTransitionYFromFullScreen) : -translationInView.y
        let panOffsetY = locationInView.y / SCREEN_HEIGHT * (maxCellRatio - 1) * sqrt(SCREEN_HEIGHT * (gap))
        return SCREEN_HEIGHT + panOffsetY
    }
    
    // (normalHeight - locationY) / normalHeight = (normalHeight - (locationY + transitionY)) / newCellHeight
    func computeCellHeightUnderNormalZoomInOut() -> CGFloat {
        let targetCellheight = isFromFullScreen == false ? CELL_NORMAL_HEIGHT : SCREEN_HEIGHT
        return ((targetCellheight - (locationInView.y + translationInView.y)) * targetCellheight) / (targetCellheight - locationInView.y)
    }
    
    // panOffY * panOffY = (1- minRatio) * (1- minRatio) * normalHeight * normalHeight * transitionY/ (normalHeight - locationY)
    func computeCellHeightUnderExtraZoomOut() -> CGFloat {
        let gap = isFromFullScreen == false ? translationInView.y : (translationInView.y - reachNormalTransitionYFromFullScreen < 0 ? 0 : translationInView.y - reachNormalTransitionYFromFullScreen)
        let denominator = isFromFullScreen == false ? CELL_NORMAL_HEIGHT - locationInView.y : CELL_NORMAL_HEIGHT - reachNormalLocationYFromFullScreen + POSTER_HEIGHT
        let numerator = (1 - minCellRatio) * (1 - minCellRatio) * CELL_NORMAL_HEIGHT * CELL_NORMAL_HEIGHT * (gap)
        let panOffsetY = sqrt(numerator / denominator)
        return CELL_NORMAL_HEIGHT - panOffsetY
    }
    
    func reachNormalHeightSetting(recognizer:UIPanGestureRecognizer) {
        if hasReachNormalHeightFromFullScreen == false {
            reachNormalLocationYFromFullScreen = recognizer.locationInView(collectionView).y
            reachNormalTransitionYFromFullScreen = recognizer.translationInView(collectionView).y
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
            self.collectionView.setContentOffset(CGPointZero, animated: false)
            let anim = CATransition()
            anim.type = kCATransitionPush
            anim.subtype = changeDirection == PageChangeDirectionType.Left ? kCATransitionFromLeft : kCATransitionFromRight
            anim.duration = 0.25
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.collectionView.layer.addAnimation(anim, forKey: nil)
        }
        
        pageControl.didScrollCrossLeftEdge = {(contentOffsetX:CGFloat) in
            if self.collectionView.contentOffset.x == 0 {
                self.collectionView.transform = CGAffineTransformMakeTranslation(-contentOffsetX, 0)
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
            self.collectionView.setContentOffset(CGPointZero, animated: true)
        }
        self.pageControl = pageControl
        view.addSubview(pageControl)
        view.setSpecialCorner([UIRectCorner.TopLeft,UIRectCorner.TopRight])
    }
    
    private func setMessageView() {
        let messageView = MessageView.messageViewWith(frame: CGRectMake(SCREEN_WIDTH - 135, 0, 135, 55))
        view.addSubview(messageView)
    }
    
    private func setCollectionView() {
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        let nib = UINib(nibName: cellReuseIdentifier, bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.clipsToBounds = false
        panCollect = UIPanGestureRecognizer(target: self, action: "handleCollectPanGesture:")
        panCollect.delegate = self
        panCollect.maximumNumberOfTouches = 1;
        collectionView.addGestureRecognizer(panCollect)
        collectionView.collectionViewLayout = normalCollectLayout
        view.addSubview(collectionView)
    }
}

extension ViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panCollect && otherGestureRecognizer == collectionView.panGestureRecognizer {
            return true
        }else {
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        return cell
    }
}

