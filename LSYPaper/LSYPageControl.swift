//
//  LSYPageControl.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/2/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

enum PageChangeDirectionType : Int {
    case right
    case left
}

class LSYPageControl: UIView,UIScrollViewDelegate{
    
    @IBOutlet weak var makeRealView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    
    var didScrollOption:((NSInteger,[UIView],CGFloat) -> Void)?
    var didEndDeceleratingOption:((NSInteger) -> Void)?
    var pageDidChangeOption:((NSInteger,PageChangeDirectionType) -> Void)?
    var didScrollCrossLeftEdge:((CGFloat) -> Void)?
    var didScrollCrossRightEdge:((CGFloat,UIView) -> Void)?
    var backFromLeftEdge:(() -> Void)?
    
    private var lastPage:Int = 0
    private var targetFrame:CGRect = CGRect.zero
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
    
    override func awakeFromNib() {
        makeRealView.layer.masksToBounds = true
        makeRealView.layer.cornerRadius = CORNER_REDIUS
    }
    
    class func pageControlWith(_ frame:CGRect, views:[UIView]) -> LSYPageControl {
        let objs = Bundle.main.loadNibNamed("LSYPageControl", owner: nil, options: nil)
        let pageControl = objs?.last as! LSYPageControl
        pageControl.targetFrame = frame
        pageControl.layer.masksToBounds = true
        pageControl.layer.cornerRadius = CORNER_REDIUS
        pageControl.views = views
        return pageControl
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = NSInteger((scrollView.contentOffset.x + SCREEN_WIDTH / 2) / SCREEN_WIDTH)
        let targetPage = NSInteger((scrollView.contentOffset.x - 0.1) / SCREEN_WIDTH) + 1
        if targetPage < views.count {
            if (didScrollOption != nil) {
                didScrollOption!(targetPage,views,scrollView.contentOffset.x)
            }
        }
        
        if scrollView.contentOffset.x <= 0 {
            makeRealView.transform = CGAffineTransform(translationX: -scrollView.contentOffset.x, y: 0)
            if (didScrollCrossLeftEdge != nil) {
                didScrollCrossLeftEdge!(scrollView.contentOffset.x)
            }
        }
        
        let translation = containerViewWidthConstraint.constant - scrollView.contentOffset.x - SCREEN_WIDTH
        if translation <= 0{
            makeRealView.transform = CGAffineTransform(translationX: translation, y: 0)
            if (didScrollCrossRightEdge != nil) {
                didScrollCrossRightEdge!(translation,views.last!)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (didEndDeceleratingOption != nil) {
            didEndDeceleratingOption!(pageControl.currentPage)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetContentOffsetX = targetContentOffset.pointee.x
        let currentPage = NSInteger((targetContentOffsetX + SCREEN_WIDTH / 2) / SCREEN_WIDTH)
        if lastPage != currentPage {
            if (pageDidChangeOption != nil) {
                let changeDirection = currentPage > lastPage ? PageChangeDirectionType.right : PageChangeDirectionType.left
                pageDidChangeOption!(currentPage,changeDirection)
                lastPage = currentPage
            }
        }
        if targetContentOffsetX == 0 && scrollView.contentOffset.x < 0 {
            if (backFromLeftEdge != nil) {
                backFromLeftEdge!()
            }
        }
    }
}
