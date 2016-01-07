//
//  LSYPageControl.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/2/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

class LSYPageControl: UIView,UIScrollViewDelegate{
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    var didScrollOption:((NSInteger,[UIView]) -> Void)?
    private var targetFrame:CGRect = CGRectZero
    private var views:[UIView] = [] {
        didSet {
            let count = views.count
            containerViewWidthConstraint.constant = CGFloat(count) * SCREEN_WIDTH
            pageControl.numberOfPages = count
            for view in views {
                containerView.addSubview(view)
            }
        }
    }
    
    override func layoutSubviews() {
        frame = targetFrame
    }
    
    class func pageControlWith(frame:CGRect, views:[UIView]) -> LSYPageControl {
        let objs = NSBundle.mainBundle().loadNibNamed("LSYPageControl", owner: nil, options: nil)
        let pageControl = objs.last as! LSYPageControl
        pageControl.targetFrame = frame
        pageControl.views = views
        return pageControl
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = NSInteger((scrollView.contentOffset.x + SCREEN_WIDTH / 2) / SCREEN_WIDTH)
        let targetPage = NSInteger((scrollView.contentOffset.x - 0.1) / SCREEN_WIDTH) + 1
        if targetPage < views.count {
            if (didScrollOption != nil) {
                didScrollOption!(targetPage,views)
            }
        }
    }
    
}
