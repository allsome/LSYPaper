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
private let anchorPointGap:CGFloat = 4
private let maxShadowLimit:CGFloat = -27
private let hideShadowReachY:CGFloat = -50
private let triangleHeight:CGFloat = 8
private var triangleScale:CGFloat = 0
let commentPopViewHeight:CGFloat = 438
let sharePopViewHeight:CGFloat = 357

class LSYPaperPopView: UIView {
    
    private var fatherView:UIView = UIView()
    private var targetFrame:CGRect = CGRectZero
    private var isReachLimit:Bool = false
    private var isTranslate:Bool = false
    private var normalTopConstraint:CGFloat = 0
    private var revokeOption:(() -> Void)?

    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentLabel: LSYShimmerLabel!
    @IBOutlet weak var triangleImage: UIImageView!
    @IBOutlet weak var triangleImageTopConstraint: NSLayoutConstraint!
    private var panPop:UIPanGestureRecognizer = UIPanGestureRecognizer()

    override func layoutSubviews() {
        frame = targetFrame
    }
    
    class func showPopViewWith(frame:CGRect,viewMode:LSYPaperPopViewMode,inView:UIView,frontView:UIView,revokeOption:(() -> Void)) {
        var name:String = ""
        if viewMode == LSYPaperPopViewMode.Share {
            name = "LSYPaperPopView"
        }else if viewMode == LSYPaperPopViewMode.Comment {
            name = "LSYPaperPopViewComment"
        }
        let objs = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        let PopView = objs.last as! LSYPaperPopView
        if viewMode == LSYPaperPopViewMode.Share {
            PopView.layer.anchorPoint = CGPointMake(128 / SCREEN_WIDTH,  (sharePopViewHeight - 8) / sharePopViewHeight)
            PopView.normalTopConstraint = 0
            PopView.addGesture()
        }else if viewMode == LSYPaperPopViewMode.Comment {
            PopView.layer.anchorPoint = CGPointMake((SCREEN_WIDTH - 88) / SCREEN_WIDTH, (commentPopViewHeight - 8) / commentPopViewHeight)
            PopView.normalTopConstraint = -1
            PopView.commentLabel.shimmerColor = UIColor(white: 1.0, alpha: 0.7)
            PopView.commentLabel.startAnimate()
            PopView.addGesture()
        }
        PopView.revokeOption = revokeOption
        PopView.targetFrame = frame
        PopView.frame = frame
        PopView.topView.setSpecialCornerWith(frame: CGRectMake(0, 0, SCREEN_WIDTH, PopView.topView.frame.size.height), cornerOption: [UIRectCorner.TopLeft,UIRectCorner.TopRight])
        PopView.bottomView.setSpecialCornerWith(frame: CGRectMake(0, 0, SCREEN_WIDTH, PopView.bottomView.frame.size.height), cornerOption: [UIRectCorner.BottomLeft,UIRectCorner.BottomRight])

        PopView.cornerView.layer.shadowColor = UIColor.blackColor().CGColor
        PopView.cornerView.layer.shadowOffset = CGSizeMake(0, 4)
        PopView.cornerView.layer.shadowOpacity = 0.3
        PopView.cornerView.layer.shadowRadius = 4.0
        PopView.transform = CGAffineTransformMakeScale(0, 0)
        PopView.fatherView = inView
        
        inView.bringSubviewToFront(frontView)
        inView.addSubview(PopView)

        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            PopView.transform = CGAffineTransformMakeScale(1, 1)
            }) { (stop:Bool) -> Void in
        }
    }
    
    private func addGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        pan.delegate = self
        self.addGestureRecognizer(pan)
        self.panPop = pan
    }
    
    func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            if recognizer.velocityInView(self).y > 0 {
                isTranslate = false
            }else {
                isTranslate = true
                triangleImage.layer.anchorPoint = CGPointMake(0.5, 1)
                triangleImageTopConstraint.constant = normalTopConstraint + anchorPointGap
            }
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            if isTranslate == true {
                if recognizer.translationInView(self).y > maxShadowLimit {
                    isReachLimit = false
                    if recognizer.translationInView(self).y <= 0 {
                        triangleImage.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, (triangleHeight - recognizer.translationInView(self).y) / triangleHeight, 1.01)
                    }
                    cornerView.transform = CGAffineTransformMakeTranslation(0, recognizer.translationInView(self).y)
                }else if recognizer.translationInView(self).y >= hideShadowReachY && recognizer.translationInView(self).y <= maxShadowLimit && isReachLimit == false {
                    isReachLimit = true
                    triangleScale = (triangleHeight - recognizer.translationInView(self).y) / triangleHeight
                    if recognizer.velocityInView(self).y <= 0 {
                        UIView.animateWithDuration(animationDuration / 3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                            self.triangleImage.layer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 1, triangleScale, 1.01), 0, (hideShadowReachY - triangleHeight) / triangleScale, 0)
                            self.cornerView.transform = CGAffineTransformMakeTranslation(0, hideShadowReachY)
                            }, completion: { (stop:Bool) -> Void in
                        })
                    }else {
                        UIView.animateWithDuration(animationDuration / 3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                            self.triangleImage.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, (triangleHeight - maxShadowLimit) / triangleHeight, 1.01)
                            self.cornerView.transform = CGAffineTransformMakeTranslation(0, maxShadowLimit)
                            }, completion: { (stop:Bool) -> Void in
                        })
                    }
                }else if recognizer.translationInView(self).y < hideShadowReachY {
                    isReachLimit = false
                    triangleImage.layer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 1, triangleScale, 1.01), 0, (recognizer.translationInView(self).y - triangleHeight) / triangleScale, 0)
                    cornerView.transform = CGAffineTransformMakeTranslation(0, recognizer.translationInView(self).y)
                }
            }else {
                let scale:CGFloat = (self.targetFrame.size.height - recognizer.translationInView(self.fatherView).y) / self.targetFrame.size.height
                self.transform = CGAffineTransformMakeScale(scale, scale)
            }
        } else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            if isTranslate == true {
                if recognizer.velocityInView(self).y <= 0 {
                    if revokeOption != nil {
                        revokeOption!()
                    }
                }else {
                    UIView.animateWithDuration(animationDuration / 2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        self.cornerView.transform = CGAffineTransformIdentity
                        self.triangleImage.layer.transform = CATransform3DIdentity
                        }, completion: { (stop:Bool) -> Void in
                    })
                }
            }else {
                if recognizer.velocityInView(self).y >= 0 {
                    if revokeOption != nil {
                        revokeOption!()
                    }
                }else {
                    UIView.animateWithDuration(animationDuration / 2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        self.transform = CGAffineTransformIdentity
                        }, completion: { (stop:Bool) -> Void in
                    })
                }
            }
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
    
    private class func getPopViewFrom(fromView:UIView) -> LSYPaperPopView {
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
    
    private class func getBackgroundFrom(fromView:UIView) -> UIView {
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

extension LSYPaperPopView:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panPop {
            if fabs(panPop.velocityInView(self).x) >= fabs(panPop.velocityInView(self).y) {
                return false
            }else {
                return true
            }
        }else {
            return true
        }
    }
}
