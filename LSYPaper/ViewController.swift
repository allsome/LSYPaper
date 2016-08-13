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

private let tinyCollectFrame = CGRect(x: -SCREEN_WIDTH * 2, y: POSTER_HEIGHT, width: SCREEN_WIDTH * 5, height: CELL_NORMAL_HEIGHT)
private let fullScreenCollectFrame = CGRect(x: -SCREEN_WIDTH * 2, y: 0, width: SCREEN_WIDTH * 5, height: SCREEN_HEIGHT)
private let fullScreenPageEnableCollectFrame = CGRect(x: -fullScreenGap / 2, y: 0, width: SCREEN_WIDTH + fullScreenGap, height: SCREEN_HEIGHT)

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
    private var fullScreenCollectLayout:UICollectionViewFlowLayout {
        return fullScreenCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var tinyCollectSideInset:CGFloat {
        return (tinyCollectionView.frame.width - SCREEN_WIDTH) / 2
    }
    
    private var fullScreenCollectSideInset:CGFloat {
        return (fullScreenCollectionView.frame.width - SCREEN_WIDTH) / 2
    }
    
    private var tinyCollectionViewLayout:UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: normalCellWidth, height: CELL_NORMAL_HEIGHT)
        layout.minimumLineSpacing = cellGap
        layout.sectionInset = UIEdgeInsetsMake(0, tinyCollectSideInset + cellGap, 0, tinyCollectSideInset + cellGap)
        return layout
    }
    private var fullScreenCollectionViewLayout:UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.itemSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        layout.minimumLineSpacing = fullScreenGap
        layout.sectionInset = UIEdgeInsetsMake(0, fullScreenCollectSideInset + fullScreenGap, 0, fullScreenCollectSideInset + fullScreenGap)
        return layout
    }
    
    private var tinyPanCollect:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var tinyTapCollect:UITapGestureRecognizer = UITapGestureRecognizer()
    private var fullScreenPanCollect:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var isPanVertical:Bool = false
    private var isFromFullScreen:Bool = false
    private var hasReachNormalHeightFromFullScreen:Bool = false
    private var reachNormalLocationYFromFullScreen:CGFloat = 0.0
    private var reachNormalTransitionYFromFullScreen:CGFloat = 0.0
    private var locationInView:CGPoint = CGPoint.zero
    private var translationInView:CGPoint = CGPoint.zero
    private var currentContentOffset:CGPoint = CGPoint.zero
    private var locationRatio:CGFloat = 0
    private var newCellHeight:CGFloat = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPageControl()
        setMessageView()
        setBlackView()
        setCollectionView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func handleCollectTapGesture(_ recognizer:UIPanGestureRecognizer) {
        tinyCollectionView.alpha = 0.0
        locationInView = recognizer.location(in: view)
        locationRatio = (recognizer.location(in: tinyCollectionView).x - tinyCollectSideInset) / (collectLayout.minimumLineSpacing + collectLayout.itemSize.width)
        fullScreenCollectionView.contentOffset = CGPoint(x: locationRatio * (fullScreenCollectionViewLayout.minimumLineSpacing + fullScreenCollectionViewLayout.itemSize.width) - locationInView.x, y: 0)
        fullScreenCollectionView.safeSetAnchorPoint(CGPoint(x: (locationInView.x - fullScreenCollectionView.frame.origin.x) / fullScreenCollectionView.frame.width, y: 1))
        fullScreenCollectionView.transform = CGAffineTransform(scaleX: CELL_NORMAL_HEIGHT / SCREEN_HEIGHT, y: CELL_NORMAL_HEIGHT / SCREEN_HEIGHT)
        fullScreenCollectionView.alpha = 1.0
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.fullScreenCollectionView.transform = CGAffineTransform.identity
            self.fullScreenCollectionView.setContentOffset(CGPoint(x: (CGFloat(Int(self.locationRatio)) * (SCREEN_WIDTH + fullScreenGap) + fullScreenGap), y: 0), animated: false)
            self.pageControl.transform = CGAffineTransform(scaleX: minScale, y: minScale)
            self.blackView.alpha = 1.0
            for cell in self.fullScreenCollectionView.visibleCells {
                let bigCell = cell as! BigNewsDetailCell
                bigCell.bottomViewHeightConstraint.constant = bottomViewDefaultHeight
                bigCell.coreViewBottomConstraint.constant = 20 + bottomViewDefaultHeight
                bigCell.layoutIfNeeded()
            }
            }) { (stop:Bool) -> Void in
                self.fullScreenCollectionView.frame = fullScreenPageEnableCollectFrame
                self.fullScreenCollectLayout.sectionInset.left = fullScreenGap / 2
                self.fullScreenCollectLayout.sectionInset.right = fullScreenGap / 2
                self.fullScreenCollectionView.setContentOffset(CGPoint(x: (CGFloat(Int(self.locationRatio)) * (SCREEN_WIDTH + fullScreenGap)), y: 0), animated: false)
                self.fullScreenCollectionView.isPagingEnabled = true
        }
    }
    
     func handleCollectPanGesture(_ recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            let velocity = recognizer.velocity(in: view)
            if fabs(velocity.x) <= fabs(velocity.y) {
                locationInView = recognizer.location(in: view)
                isPanVertical = true
                tinyCollectionView.panGestureRecognizer.isEnabled = false
                fullScreenCollectionView.panGestureRecognizer.isEnabled = false
                if recognizer == tinyPanCollect {
                    locationRatio = (recognizer.location(in: tinyCollectionView).x - tinyCollectSideInset) / (collectLayout.minimumLineSpacing + collectLayout.itemSize.width)
                    isFromFullScreen = false
                    currentContentOffset = tinyCollectionView.contentOffset
                    fullScreenCollectionView.contentOffset = CGPoint(x: locationRatio * (fullScreenCollectionViewLayout.minimumLineSpacing + fullScreenCollectionViewLayout.itemSize.width) - locationInView.x, y: 0)
                    tinyCollectionView.safeSetAnchorPoint(CGPoint(x: (locationInView.x - tinyCollectionView.frame.origin.x) / tinyCollectionView.frame.width, y: 1))
                    fullScreenCollectionView.safeSetAnchorPoint(CGPoint(x: (locationInView.x - fullScreenCollectionView.frame.origin.x) / fullScreenCollectionView.frame.width, y: 1))
                }else if recognizer == fullScreenPanCollect {
                    currentContentOffset = fullScreenCollectionView.contentOffset
                    fullScreenCollectionView.isPagingEnabled = false
                    fullScreenCollectionView.frame = fullScreenCollectFrame
                    fullScreenCollectionView.contentOffset = CGPoint(x: fullScreenGap + currentContentOffset.x, y: currentContentOffset.y)
                    fullScreenCollectLayout.sectionInset.left = fullScreenCollectionViewLayout.sectionInset.left
                    fullScreenCollectLayout.sectionInset.right = fullScreenCollectionViewLayout.sectionInset.right
                    locationRatio = (recognizer.location(in: fullScreenCollectionView).x - fullScreenCollectSideInset) / (fullScreenCollectLayout.minimumLineSpacing + fullScreenCollectLayout.itemSize.width)
                    isFromFullScreen = true
                    tinyCollectionView.safeSetAnchorPoint(CGPoint(x: (locationInView.x - tinyCollectionView.frame.origin.x) / tinyCollectionView.frame.width, y: 1))
                    fullScreenCollectionView.safeSetAnchorPoint(CGPoint(x: (locationInView.x - fullScreenCollectionView.frame.origin.x) / fullScreenCollectionView.frame.width, y: 1))
                    tinyCollectionView.contentOffset = CGPoint(x: locationRatio * (tinyCollectionViewLayout.minimumLineSpacing + tinyCollectionViewLayout.itemSize.width) - locationInView.x, y: 0)
                }

            }
            if recognizer == fullScreenPanCollect {
                let index:Int = Int((recognizer.location(in: fullScreenCollectionView).x - fullScreenCollectSideInset - fullScreenGap) / SCREEN_WIDTH)
                let currentCell = fullScreenCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! BigNewsDetailCell
                if currentCell.isDarkMode == true {
                    currentCell.revokePopView()
                }
            }
        } else if recognizer.state == UIGestureRecognizerState.changed {
            if isPanVertical {
                translationInView = recognizer.translation(in: view)
                if recognizer == tinyPanCollect {
                    if translationInView.y >= 0 {
                        newCellHeight = computeCellHeightUnderExtraZoomOut()
                    }else {
                        newCellHeight = computeCellHeightUnderNormalZoomInOut()
                        if newCellHeight >= SCREEN_HEIGHT {
                            reachNormalHeightSetting(recognizer)
                            newCellHeight = computeCellHeightUnderExtraZoomIn()
                        }
                    }
                }else if recognizer == fullScreenPanCollect {
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

                let upScale = (minScale - 1) * newCellHeight + SCREEN_HEIGHT - minScale * CELL_NORMAL_HEIGHT
                let downScale = SCREEN_HEIGHT - CELL_NORMAL_HEIGHT
                var scale = upScale / downScale
                if scale >= 1 {
                    scale = 1
                }
                let alpha = newCellHeight / SCREEN_HEIGHT / (hideStartRatio - hideOverRatio) - (hideOverRatio / (hideStartRatio - hideOverRatio))
                tinyCollectionView.alpha = 1
                for cell in tinyCollectionView.visibleCells {
                    let tinyCell = cell as! TinyNewsDetailCell
                    cell.contentView.alpha = alpha
                    tinyCell.bottomViewHeightConstraint.constant = 1 - alpha >= 1 ? tinyBottomViewDefaultHeight : tinyBottomViewDefaultHeight * (1 - alpha)
                }
                for cell in fullScreenCollectionView.visibleCells {
                    let bigCell = cell as! BigNewsDetailCell
                    bigCell.bottomViewHeightConstraint.constant = 1 - alpha >= 1 ? bottomViewDefaultHeight : bottomViewDefaultHeight * (1 - alpha)
                    bigCell.coreViewBottomConstraint.constant = 1 - alpha >= 1 ? (20 + bottomViewDefaultHeight) : 20 + bottomViewDefaultHeight * (1 - alpha)
                }
                fullScreenCollectionView.alpha = 1 - alpha
                blackView.alpha = -20 * scale + 20
                pageControl.transform = CGAffineTransform(scaleX: scale, y: scale)
                let tinyRatio = newCellHeight / CELL_NORMAL_HEIGHT
                let fullRatio = newCellHeight / SCREEN_HEIGHT
                tinyCollectionView.transform = CGAffineTransform(scaleX: tinyRatio, y: tinyRatio).concatenating(CGAffineTransform(translationX: translationInView.x, y: 0))
                fullScreenCollectionView.transform = CGAffineTransform(scaleX: fullRatio, y: fullRatio).concatenating(CGAffineTransform(translationX: translationInView.x, y: 0))
            }
        } else if (recognizer.state == UIGestureRecognizerState.cancelled || recognizer.state == UIGestureRecognizerState.ended){
            if isPanVertical == true {
                let isZoomed = blackView.alpha > 0
                let duration = isZoomed ? 0.3 : 0.2
                let option = isZoomed ? UIViewAnimationOptions():UIViewAnimationOptions.curveEaseOut
                let isFullScreen = fullScreenCollectionView.alpha >= 0.5
                let scale:CGFloat = isFullScreen ? minScale : 1.0
                let alpha:CGFloat = isFullScreen ? 1.0 : 0.0
                fullScreenCollectionView.alpha = alpha
                tinyCollectionView.alpha = 1 - alpha
                UIView.animate(withDuration: duration, delay: 0.0, options: option, animations: { () -> Void in
                    self.fullScreenCollectionView.transform = CGAffineTransform.identity
                    if isFullScreen {
                        self.fullScreenCollectionView.setContentOffset(CGPoint(x: (CGFloat(Int(self.locationRatio)) * (SCREEN_WIDTH + fullScreenGap) + fullScreenGap), y: 0), animated: false)
                    }else {
                        let gapNum:CGFloat = self.translationInView.x * 50 / SCREEN_WIDTH
                        var pointX = self.tinyCollectionView.contentOffset.x - self.translationInView.x + gapNum
                        if pointX <= 0 {
                            pointX = 0
                        }
                        self.tinyCollectionView.setContentOffset(CGPoint(x: pointX, y: self.currentContentOffset.y), animated: false)
                    }
                    for cell in self.fullScreenCollectionView.visibleCells {
                        let bigCell = cell as! BigNewsDetailCell
                        bigCell.bottomViewHeightConstraint.constant = bottomViewDefaultHeight * alpha
                        bigCell.coreViewBottomConstraint.constant = 20 + (bottomViewDefaultHeight) * alpha

                        bigCell.layoutIfNeeded()
                    }
                    for cell in self.tinyCollectionView.visibleCells {
                        let tinyCell = cell as! TinyNewsDetailCell
                        cell.contentView.alpha = 1.0 - alpha
                        tinyCell.bottomViewHeightConstraint.constant = tinyBottomViewDefaultHeight * alpha
                        tinyCell.layoutIfNeeded()
                    }
                    self.tinyCollectionView.transform = CGAffineTransform.identity
                    self.pageControl.transform = CGAffineTransform(scaleX: scale, y: scale)
                    self.blackView.alpha = alpha
                    }, completion: { (stop:Bool) -> Void in
                        if isFullScreen {
                            self.fullScreenCollectionView.frame = fullScreenPageEnableCollectFrame
                            self.fullScreenCollectLayout.sectionInset.left = fullScreenGap / 2
                            self.fullScreenCollectLayout.sectionInset.right = fullScreenGap / 2
                            self.fullScreenCollectionView.setContentOffset(CGPoint(x: (CGFloat(Int(self.locationRatio)) * (SCREEN_WIDTH + fullScreenGap)), y: 0), animated: false)
                            self.fullScreenCollectionView.isPagingEnabled = true
                        }
                        self.isPanVertical = false
                        self.hasReachNormalHeightFromFullScreen = false
                        self.tinyCollectionView.panGestureRecognizer.isEnabled = true
                        self.fullScreenCollectionView.panGestureRecognizer.isEnabled = true
                })
            }
        }
    }
    
    /* panOffY * panOffY = (locationY / screenH) * (locationY / screenH) * (maxRatio - 1) * (maxRatio - 1) * screenH * (-translationY) */
    private func computeCellHeightUnderExtraZoomIn() -> CGFloat {
        let gap = isFromFullScreen == false ? (-translationInView.y + reachNormalTransitionYFromFullScreen < 0 ? 0 : -translationInView.y + reachNormalTransitionYFromFullScreen) : -translationInView.y
        let panOffsetY = (isFromFullScreen == false ? locationInView.y - POSTER_HEIGHT : locationInView.y) / SCREEN_HEIGHT * (maxCellRatio - 1) * sqrt(SCREEN_HEIGHT * (gap))
        return SCREEN_HEIGHT + panOffsetY
    }
    
    /* (normalHeight - locationY) / normalHeight = (normalHeight - (locationY + transitionY)) / newCellHeight */
    private func computeCellHeightUnderNormalZoomInOut() -> CGFloat {
        let targetCellheight = isFromFullScreen == false ? CELL_NORMAL_HEIGHT : SCREEN_HEIGHT
        let gap = isFromFullScreen == false ? POSTER_HEIGHT : 0
        return ((targetCellheight - (locationInView.y - gap + translationInView.y)) * targetCellheight) / (targetCellheight - locationInView.y + gap)
    }
    
    /* panOffY * panOffY = (1- minRatio) * (1- minRatio) * normalHeight * normalHeight * transitionY/ (normalHeight - locationY) */
    private func computeCellHeightUnderExtraZoomOut() -> CGFloat {
        let gap = isFromFullScreen == false ? translationInView.y :         (translationInView.y - reachNormalTransitionYFromFullScreen < 0 ? 0 : translationInView.y - reachNormalTransitionYFromFullScreen)
        let denominator = isFromFullScreen == false ? CELL_NORMAL_HEIGHT - locationInView.y + (isFromFullScreen == false ? POSTER_HEIGHT : 0) : CELL_NORMAL_HEIGHT - reachNormalLocationYFromFullScreen + POSTER_HEIGHT
        let panOffsetY = (1 - minCellRatio) * CELL_NORMAL_HEIGHT * sqrt(gap / denominator)
        return CELL_NORMAL_HEIGHT - panOffsetY
    }
    
    private func reachNormalHeightSetting(_ recognizer:UIPanGestureRecognizer) {
        if hasReachNormalHeightFromFullScreen == false {
            reachNormalLocationYFromFullScreen = recognizer.location(in: view).y
            reachNormalTransitionYFromFullScreen = recognizer.translation(in: view).y
            hasReachNormalHeightFromFullScreen = true
        }
    }
}

private extension ViewController {
    private func setPageControl() {
        
        let path = Bundle.main.path(forResource: "Section", ofType: "plist")
        let dicArray = NSArray(contentsOfFile: path!)
        
        var views = [UIView]()
        for index in 0 ..< dicArray!.count {
            let dic = dicArray?.object(at: index)
            let data = SectionData(dictionary: dic as! [String : AnyObject])
            let frame = CGRect(x: SCREEN_WIDTH * CGFloat(index), y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            let view = SectionPosterView.sectionPosterViewWith(data: data, frame: frame)
            views.append(view)
        }
        
        let pageControl = LSYPageControl.pageControlWith(CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), views: views)
        pageControl.pageControlBottomConstraint.constant = SCREEN_HEIGHT - POSTER_HEIGHT
        pageControl.didScrollOption = {(targetPage:NSInteger,views:[UIView],contentOffsetX:CGFloat) in
            let view = views[targetPage] as! SectionPosterView
            let frame = view.titleLabel.convert(view.titleLabel.bounds, to: self.view)
            
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
            self.tinyCollectionView.setContentOffset(CGPoint.zero, animated: false)
            let anim = CATransition()
            anim.type = kCATransitionPush
            anim.subtype = changeDirection == PageChangeDirectionType.left ? kCATransitionFromLeft : kCATransitionFromRight
            anim.duration = 0.25
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.tinyCollectionView.layer.add(anim, forKey: nil)
        }
        
        pageControl.didScrollCrossLeftEdge = {(contentOffsetX:CGFloat) in
            if self.tinyCollectionView.contentOffset.x == 0 {
                self.tinyCollectionView.transform = CGAffineTransform(translationX: -contentOffsetX, y: 0)
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
            self.tinyCollectionView.setContentOffset(CGPoint.zero, animated: true)
        }
        self.pageControl = pageControl
        view.addSubview(pageControl)
    }
    
    private func setMessageView() {
        let messageView = MessageView.messageViewWith(frame: CGRect(x: SCREEN_WIDTH - 135, y: 0, width: 135, height: 55))
        self.pageControl.addSubview(messageView)
    }
    
    private func setBlackView() {
        blackView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0.0
        view.addSubview(blackView)
    }
    
    private func setCollectionView() {
        tinyCollectionView.backgroundColor = UIColor.clear
        tinyCollectionView.dataSource = self
        tinyCollectionView.delegate = self
        var nib = UINib(nibName: tinyCellReuseIdentifier, bundle: nil)
        tinyCollectionView.register(nib, forCellWithReuseIdentifier: tinyCellReuseIdentifier)
        tinyPanCollect = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCollectPanGesture(_:)))
        tinyPanCollect.delegate = self
        tinyPanCollect.maximumNumberOfTouches = 1
        tinyCollectionView.addGestureRecognizer(tinyPanCollect)
        tinyTapCollect = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCollectTapGesture(_:)))
        tinyCollectionView.addGestureRecognizer(tinyTapCollect)
        tinyCollectionView.collectionViewLayout = tinyCollectionViewLayout
        view.addSubview(tinyCollectionView)
        
        fullScreenCollectionView.backgroundColor = UIColor.clear
        fullScreenCollectionView.dataSource = self
        fullScreenCollectionView.delegate = self
        nib = UINib(nibName: fullScreenCellReuseIdentifier, bundle: nil)
        fullScreenCollectionView.register(nib, forCellWithReuseIdentifier: fullScreenCellReuseIdentifier)
        fullScreenPanCollect = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCollectPanGesture(_:)))
        fullScreenPanCollect.delegate = self
        fullScreenPanCollect.maximumNumberOfTouches = 1
        fullScreenCollectionView.addGestureRecognizer(fullScreenPanCollect)
        fullScreenCollectionView.collectionViewLayout = fullScreenCollectionViewLayout
        fullScreenCollectionView.alpha = 0.0
        view.addSubview(fullScreenCollectionView)
    }
}

extension ViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tinyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tinyCellReuseIdentifier, for: indexPath) as! TinyNewsDetailCell
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: fullScreenCellReuseIdentifier, for: indexPath) as! BigNewsDetailCell
            cell.bottomViewHeightConstraint.constant = bottomViewDefaultHeight * fullScreenCollectionView.alpha
            cell.coreViewBottomConstraint.constant = 20 + (bottomViewDefaultHeight) * fullScreenCollectionView.alpha
            cell.unfoldWebViewOption = {() in
                self.fullScreenCollectionView.panGestureRecognizer.isEnabled = false
            }
            cell.foldWebViewOption = {() in
                self.fullScreenCollectionView.panGestureRecognizer.isEnabled = true
            }
            return cell
        }
    }
}

