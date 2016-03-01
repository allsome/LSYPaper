//
//  LSYPaperPopView.swift
//  LSYPaper
//
//  Created by 梁树元 on 2/27/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

enum LSYPaperPopViewMode : Int {
    case Share
    case Comment
}

private let backgroundViewTag:Int = -250
private let animationDuration:NSTimeInterval = 0.6

class LSYPaperPopView: UIView {
    
    private var targetFrame:CGRect = CGRectZero
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentLabel: LSYShimmerLabel!
    
    override func layoutSubviews() {
        frame = targetFrame
    }
    
    class func showPopViewWith(frame:CGRect,viewMode:LSYPaperPopViewMode,inView:UIView,frontView:UIView) {
        var name:String = ""
        if viewMode == LSYPaperPopViewMode.Share {
            name = "LSYPaperPopView"
        }else if viewMode == LSYPaperPopViewMode.Comment {
            name = "LSYPaperPopViewComment"
        }
        let objs = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        let PopView = objs.last as! LSYPaperPopView
        if viewMode == LSYPaperPopViewMode.Share {
            PopView.layer.anchorPoint = CGPointMake(130 / SCREEN_WIDTH, 1)
        }else if viewMode == LSYPaperPopViewMode.Comment {
            PopView.layer.anchorPoint = CGPointMake((SCREEN_WIDTH - 91) / SCREEN_WIDTH, (448 - 10) / 448)
            PopView.commentLabel.shimmerColor = UIColor(white: 1.0, alpha: 0.7)
            PopView.commentLabel.startAnimate()
        }
        PopView.targetFrame = frame
        PopView.frame = frame
        PopView.topView.setSpecialCornerWith(frame: CGRectMake(0, 0, SCREEN_WIDTH, PopView.topView.frame.size.height), cornerOption: [UIRectCorner.TopLeft,UIRectCorner.TopRight])
        PopView.bottomView.setSpecialCornerWith(frame: CGRectMake(0, 0, SCREEN_WIDTH, PopView.bottomView.frame.size.height), cornerOption: [UIRectCorner.BottomLeft,UIRectCorner.BottomRight])

        PopView.cornerView.layer.shadowColor = UIColor.blackColor().CGColor
        PopView.cornerView.layer.shadowOffset = CGSizeMake(0, 4)
        PopView.cornerView.layer.shadowOpacity = 0.3
        PopView.cornerView.layer.shadowRadius = 4.0
        PopView.transform = CGAffineTransformMakeScale(0, 0)
        
        inView.bringSubviewToFront(frontView)
        inView.addSubview(PopView)

        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            PopView.transform = CGAffineTransformMakeScale(1, 1)
            }) { (stop:Bool) -> Void in
        }
    }
    
    class func showBackgroundView(inView:UIView) {
        let backgroundView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        backgroundView.alpha = 0.0
        backgroundView.userInteractionEnabled = false
        backgroundView.tag = backgroundViewTag
        
        inView.addSubview(backgroundView)

        UIView.animateWithDuration(animationDuration / 2) { () -> Void in
            backgroundView.alpha = 1.0
        }
    }
    
    class func hideBackgroundView(fromView:UIView,completion: (() -> Void)?) {
        let backgroundView = LSYPaperPopView.getBackgroundFrom(fromView)
        UIView.animateWithDuration(0.20, animations: { () -> Void in
            backgroundView.alpha = 0.0
            }) { (stop:Bool) -> Void in
                backgroundView.removeFromSuperview()
                if completion != nil {
                    completion!()
                }
        }
    }
    
    class func hidePopView(fromView:UIView) {
        let subViewsEnum = fromView.subviews.reverse()
        var popView = LSYPaperPopView()
        for subView in subViewsEnum {
            if subView.isKindOfClass(self) {
                popView = subView as! LSYPaperPopView
            }
        }
        UIView.animateWithDuration(0.20, animations: { () -> Void in
            popView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            }) { (stop:Bool) -> Void in
                popView.removeFromSuperview()
        }
    }
    
    class func getPopViewFrom(fromView:UIView) -> LSYPaperPopView {
        let subViewsEnum = fromView.subviews.reverse()
        var popView = LSYPaperPopView()
        for subView in subViewsEnum {
            if subView.isKindOfClass(self) {
                popView = subView as! LSYPaperPopView
                return popView
            }
        }
        return popView
    }
    
    class func getBackgroundFrom(fromView:UIView) -> UIView {
        let subViewsEnum = fromView.subviews.reverse()
        let backgroundView = UIView()
        for subView in subViewsEnum {
            if subView.tag == backgroundViewTag {
                return subView
            }
        }
        return backgroundView
    }
}
