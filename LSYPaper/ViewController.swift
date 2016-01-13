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
private let collectionViewFrame = CGRectMake(0, POSTER_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - POSTER_HEIGHT)


class ViewController: UIViewController {
    private let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: NewsDetailLayout(cellWidth: (SCREEN_WIDTH - cellGap - 36) / 2, cellHeight: SCREEN_HEIGHT - POSTER_HEIGHT, cellGap: cellGap))
    private var panCollect:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
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
        if recognizer.state == UIGestureRecognizerState.Began {
            
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            if recognizer.translationInView(view).y >= 0 {
                print(recognizer.translationInView(view))
            }
        } else if recognizer.state == UIGestureRecognizerState.Ended {
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
            if index == 0 {
                setTopRoundCorner(forView: view, cornerOption: UIRectCorner.TopLeft)
            }
            
            if index == 9 {
                setTopRoundCorner(forView: view, cornerOption: UIRectCorner.TopRight)
            }
            views.append(view)
        }
        
        let pageControl = LSYPageControl.pageControlWith(CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT), views: views)
        pageControl.pageControlBottomConstraint.constant = SCREEN_HEIGHT - POSTER_HEIGHT
        pageControl.didScrollOption = {(targetPage:NSInteger,views:[UIView]) in
            let view = views[targetPage] as! SectionPosterView
            let frame = view.titleLabel.convertRect(view.titleLabel.bounds, toView: self.view)
            
            let rightEdge = SCREEN_WIDTH - 20
            let leftEdge = SCREEN_WIDTH - 151
            if frame.origin.x > rightEdge {
                view.titleLabel.alpha = (frame.origin.x - rightEdge) / view.titleLabel.bounds.width
            }else if frame.origin.x <= rightEdge && frame.origin.x >= leftEdge {
                view.titleLabel.alpha = 0.0;
            }else {
                view.titleLabel.alpha = (leftEdge - frame.origin.x) / view.titleLabel.bounds.width
            }
        }
        
        pageControl.pageDidChangeOption = {(currentPage:Int,changeDirection:PageChangeDirectionType) in
            self.collectionView.setContentOffset(CGPointZero, animated: false)
            let anim = CATransition()
            anim.type = kCATransitionPush
            anim.subtype = changeDirection == PageChangeDirectionType.Left ? kCATransitionFromLeft : kCATransitionFromRight
            anim.duration = 0.25;
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.collectionView.layer.addAnimation(anim, forKey: nil)
        }
        view.addSubview(pageControl)
        
        setTopRoundCorner(forView: view, cornerOption: [UIRectCorner.TopLeft,UIRectCorner.TopRight])
    }
    
    private func setTopRoundCorner(forView view:UIView,cornerOption:UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: cornerOption, cornerRadii: CGSizeMake(6, 6))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds;
        maskLayer.path = maskPath.CGPath;
        view.layer.mask = maskLayer;
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
        collectionView.layer.shadowColor = UIColor.blackColor().CGColor
        collectionView.layer.shadowOffset = CGSizeMake(0, -cellGap)
        collectionView.layer.shadowRadius = cellGap
        collectionView.layer.shadowOpacity = 0.5
//        panCollect = UIPanGestureRecognizer(target: self, action: "handleCollectPanGesture:")
//        panCollect.delegate = self
//        collectionView.addGestureRecognizer(panCollect)
        collectionView.panGestureRecognizer.addTarget(self, action: "handleCollectPanGesture:")
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
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        return cell
    }
}

