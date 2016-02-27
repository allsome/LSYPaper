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

class LSYPaperPopView: UIView {
    
    private var targetFrame:CGRect = CGRectZero
    private var backgroundView:UIView = UIView()
    
    override func layoutSubviews() {
        frame = targetFrame
    }
    
    class func showPaperPopViewWith(frame:CGRect,viewMode:LSYPaperPopViewMode,inView:UIView,frontView:UIView) {
        let objs = NSBundle.mainBundle().loadNibNamed("LSYPaperPopView", owner: nil, options: nil)
        let PopView = objs.last as! LSYPaperPopView
        PopView.targetFrame = frame
        PopView.frame = frame
        
        let backgroundView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        backgroundView.alpha = 0.0
        backgroundView.userInteractionEnabled = false
        PopView.backgroundView = backgroundView
        PopView.transform = CGAffineTransformMakeScale(0, 0)
        
        inView.addSubview(PopView.backgroundView)
        inView.bringSubviewToFront(frontView)
        inView.addSubview(PopView)

        UIView.animateWithDuration(0.25) { () -> Void in
            PopView.backgroundView.alpha = 1.0
            PopView.transform = CGAffineTransformMakeScale(1, 1)
        }
    }
    
    class func hidePaperPopView(fromView:UIView) {
        let subViewsEnum = fromView.subviews.reverse()
        var popView = LSYPaperPopView()
        for subView in subViewsEnum {
            if subView.isKindOfClass(self) {
                popView = subView as! LSYPaperPopView
            }
        }
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            popView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            popView.backgroundView.alpha = 0.0
            }) { (stop:Bool) -> Void in
                popView.removeFromSuperview()
                popView.backgroundView.removeFromSuperview()
        }
    }

}
