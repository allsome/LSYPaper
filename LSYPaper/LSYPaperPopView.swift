//
//  LSYPaperPopView.swift
//  LSYPaper
//
//  Created by 梁树元 on 2/27/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

enum LSYPaperPopViewMode : Int {
    case share
    case comment
}

private let backgroundViewTag:Int = -250
private let animationDuration:TimeInterval = 0.6
private let anchorPointGap:CGFloat = 4
private let maxShadowLimit:CGFloat = -27
private let hideShadowReachY:CGFloat = -50
private let triangleHeight:CGFloat = 8
private var triangleScale:CGFloat = 0
let commentPopViewHeight:CGFloat = 438
let sharePopViewHeight:CGFloat = 357

class LSYPaperPopView: UIView {
    
    private var fatherView:UIView = UIView()
    private var targetFrame:CGRect = CGRect.zero
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
    
    class func showPopViewWith(_ frame:CGRect,viewMode:LSYPaperPopViewMode,inView:UIView,frontView:UIView,revokeOption:(() -> Void)) {
        var name:String = ""
        if viewMode == LSYPaperPopViewMode.share {
            name = "LSYPaperPopView"
        }else if viewMode == LSYPaperPopViewMode.comment {
            name = "LSYPaperPopViewComment"
        }
        let objs = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        let PopView = objs?.last as! LSYPaperPopView
        if viewMode == LSYPaperPopViewMode.share {
            PopView.layer.anchorPoint = CGPoint(x: 128 / SCREEN_WIDTH,  y: (sharePopViewHeight - 8) / sharePopViewHeight)
            PopView.normalTopConstraint = 0
            PopView.addGesture()
        }else if viewMode == LSYPaperPopViewMode.comment {
            PopView.layer.anchorPoint = CGPoint(x: (SCREEN_WIDTH - 88) / SCREEN_WIDTH, y: (commentPopViewHeight - 8) / commentPopViewHeight)
            PopView.normalTopConstraint = -1
            PopView.commentLabel.shimmerColor = UIColor(white: 1.0, alpha: 0.7)
            PopView.commentLabel.startAnimate()
            PopView.addGesture()
        }
        PopView.revokeOption = revokeOption
        PopView.targetFrame = frame
        PopView.frame = frame
        PopView.topView.setSpecialCornerWith(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: PopView.topView.frame.size.height), cornerOption: [UIRectCorner.topLeft,UIRectCorner.topRight])
        PopView.bottomView.setSpecialCornerWith(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: PopView.bottomView.frame.size.height), cornerOption: [UIRectCorner.bottomLeft,UIRectCorner.bottomRight])

        PopView.cornerView.layer.shadowColor = UIColor.black.cgColor
        PopView.cornerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        PopView.cornerView.layer.shadowOpacity = 0.3
        PopView.cornerView.layer.shadowRadius = 4.0
        PopView.transform = CGAffineTransform(scaleX: 0, y: 0)
        PopView.fatherView = inView
        
        inView.bringSubview(toFront: frontView)
        inView.addSubview(PopView)

        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            PopView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (stop:Bool) -> Void in
        }
    }
    
    private func addGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(LSYPaperPopView.handlePanGesture(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
        self.panPop = pan
    }
    
    func handlePanGesture(_ recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            if recognizer.velocity(in: self).y > 0 {
                isTranslate = false
            }else {
                isTranslate = true
                triangleImage.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
                triangleImageTopConstraint.constant = normalTopConstraint + anchorPointGap
            }
        } else if recognizer.state == UIGestureRecognizerState.changed {
            if isTranslate == true {
                if recognizer.translation(in: self).y > maxShadowLimit {
                    isReachLimit = false
                    if recognizer.translation(in: self).y <= 0 {
                        triangleImage.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, (triangleHeight - recognizer.translation(in: self).y) / triangleHeight, 1.01)
                    }
                    cornerView.transform = CGAffineTransform(translationX: 0, y: recognizer.translation(in: self).y)
                }else if recognizer.translation(in: self).y >= hideShadowReachY && recognizer.translation(in: self).y <= maxShadowLimit && isReachLimit == false {
                    isReachLimit = true
                    triangleScale = (triangleHeight - recognizer.translation(in: self).y) / triangleHeight
                    if recognizer.velocity(in: self).y <= 0 {
                        UIView.animate(withDuration: animationDuration / 3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                            self.triangleImage.layer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 1, triangleScale, 1.01), 0, (hideShadowReachY - triangleHeight) / triangleScale, 0)
                            self.cornerView.transform = CGAffineTransform(translationX: 0, y: hideShadowReachY)
                            }, completion: { (stop:Bool) -> Void in
                        })
                    }else {
                        UIView.animate(withDuration: animationDuration / 3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                            self.triangleImage.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, (triangleHeight - maxShadowLimit) / triangleHeight, 1.01)
                            self.cornerView.transform = CGAffineTransform(translationX: 0, y: maxShadowLimit)
                            }, completion: { (stop:Bool) -> Void in
                        })
                    }
                }else if recognizer.translation(in: self).y < hideShadowReachY {
                    isReachLimit = false
                    triangleImage.layer.transform = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 1, triangleScale, 1.01), 0, (recognizer.translation(in: self).y - triangleHeight) / triangleScale, 0)
                    cornerView.transform = CGAffineTransform(translationX: 0, y: recognizer.translation(in: self).y)
                }
            }else {
                let scale:CGFloat = (self.targetFrame.size.height - recognizer.translation(in: self.fatherView).y) / self.targetFrame.size.height
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else if (recognizer.state == UIGestureRecognizerState.cancelled || recognizer.state == UIGestureRecognizerState.ended){
            if isTranslate == true {
                if recognizer.velocity(in: self).y <= 0 {
                    if revokeOption != nil {
                        revokeOption!()
                    }
                }else {
                    UIView.animate(withDuration: animationDuration / 2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                        self.cornerView.transform = CGAffineTransform.identity
                        self.triangleImage.layer.transform = CATransform3DIdentity
                        }, completion: { (stop:Bool) -> Void in
                    })
                }
            }else {
                if recognizer.velocity(in: self).y >= 0 {
                    if revokeOption != nil {
                        revokeOption!()
                    }
                }else {
                    UIView.animate(withDuration: animationDuration / 2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                        self.transform = CGAffineTransform.identity
                        }, completion: { (stop:Bool) -> Void in
                    })
                }
            }
         }
    }
    
    class func showBackgroundView(_ inView:UIView) {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        backgroundView.alpha = 0.0
        backgroundView.isUserInteractionEnabled = false
        backgroundView.tag = backgroundViewTag
        
        inView.addSubview(backgroundView)

        UIView.animate(withDuration: animationDuration / 2) { () -> Void in
            backgroundView.alpha = 1.0
        }
    }
    
    class func hideBackgroundView(_ fromView:UIView,completion: (() -> Void)?) {
        let backgroundView = LSYPaperPopView.getBackgroundFrom(fromView)
        UIView.animate(withDuration: 0.20, animations: { () -> Void in
            backgroundView.alpha = 0.0
            }) { (stop:Bool) -> Void in
                backgroundView.removeFromSuperview()
                if completion != nil {
                    completion!()
                }
        }
    }
    
    class func hidePopView(_ fromView:UIView) {
        let subViewsEnum = fromView.subviews.reversed()
        var popView = LSYPaperPopView()
        for subView in subViewsEnum {
            if subView.isKind(of: self) {
                popView = subView as! LSYPaperPopView
            }
        }
        UIView.animate(withDuration: 0.20, animations: { () -> Void in
            popView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            }) { (stop:Bool) -> Void in
                popView.removeFromSuperview()
        }
    }
    
    private class func getPopViewFrom(_ fromView:UIView) -> LSYPaperPopView {
        let subViewsEnum = fromView.subviews.reversed()
        var popView = LSYPaperPopView()
        for subView in subViewsEnum {
            if subView.isKind(of: self) {
                popView = subView as! LSYPaperPopView
                return popView
            }
        }
        return popView
    }
    
    private class func getBackgroundFrom(_ fromView:UIView) -> UIView {
        let subViewsEnum = fromView.subviews.reversed()
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
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panPop {
            if fabs(panPop.velocity(in: self).x) >= fabs(panPop.velocity(in: self).y) {
                return false
            }else {
                return true
            }
        }else {
            return true
        }
    }
}
