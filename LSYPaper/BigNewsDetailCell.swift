//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

public let bottomViewDefaultHeight:CGFloat = 55
private let transform3Dm34D:CGFloat = 1900.0
private let newsViewWidth:CGFloat = (SCREEN_WIDTH - 50) / 2
private let shiningImageHeight:CGFloat = (SCREEN_WIDTH - 50) * 296 / 325
private let newsViewY:CGFloat = SCREEN_HEIGHT - 20 - bottomViewDefaultHeight - newsViewWidth * 2
private let endAngle:CGFloat = CGFloat(M_PI) / 2.0
private let startAngle:CGFloat = CGFloat(M_PI) / 7.0
private let animateDuration:Double = 0.25
class BigNewsDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var shiningView: UIView!
    @IBOutlet weak var shiningImage: UIImageView!
    @IBOutlet weak var shiningViewBottimConstraint: NSLayoutConstraint!
    @IBOutlet weak private var newsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var layerView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    private var panNewsView:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var topLayer:CALayer = CALayer()
    private var bottomLayer:CALayer = CALayer()
    private var locationInSelf:CGPoint = CGPointZero
    private var transform3D:CATransform3D = CATransform3DIdentity
    private var transform3DAngle:CGFloat {
        return acos((locationInSelf.y - newsViewY) / (newsViewWidth * 2))
            + asin((locationInSelf.y - newsViewY) / transform3Dm34D)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = cellGap
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 1.0
        let pan = UIPanGestureRecognizer(target: self, action: "handleCollectPanGesture:")
        pan.delegate = self
        newsView.addGestureRecognizer(pan)
        panNewsView = pan
        transform3D.m34 = -1 / transform3Dm34D
    }
    
    func handleCollectPanGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            newsView.layer.anchorPoint = CGPointMake(0.5, 0)
            newsViewBottomConstraint.constant = newsViewWidth + 20
            shiningView.layer.anchorPoint = CGPointMake(0.5, 0)
            shiningViewBottimConstraint.constant = newsViewWidth + 20
            locationInSelf = recognizer.locationInView(self)
            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.newsView.layer.transform = CATransform3DRotate(self.transform3D, self.transform3DAngle, 1, 0, 0)
                self.shiningView.layer.transform = CATransform3DRotate(self.transform3D, self.transform3DAngle, 1, 0, 0)
                self.shiningImage.transform = CGAffineTransformMakeTranslation(0, (shiningImageHeight + newsViewWidth * 2 - startAngle) * self.transform3DAngle / (endAngle - startAngle))
                }, completion: { (stop:Bool) -> Void in
            })
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            locationInSelf = recognizer.locationInView(self)
            self.newsView.layer.transform = CATransform3DRotate(self.transform3D, self.transform3DAngle, 1, 0, 0)
            self.shiningView.layer.transform = CATransform3DRotate(self.transform3D, self.transform3DAngle, 1, 0, 0)
            self.shiningImage.transform = CGAffineTransformMakeTranslation(0, (shiningImageHeight + newsViewWidth * 2) * (self.transform3DAngle - startAngle) / (endAngle - startAngle))
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.newsView.layer.transform = CATransform3DIdentity
                self.shiningView.layer.transform = CATransform3DIdentity
                self.shiningImage.transform = CGAffineTransformIdentity
                },completion: { (stop:Bool) -> Void in
            })
        }
    }
}

extension BigNewsDetailCell:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panNewsView && (panNewsView.velocityInView(self).y >= 0) || fabs(panNewsView.velocityInView(self).x) >= fabs(panNewsView.velocityInView(self).y) {
            return false
        }else {
            return true
        }
    }
}
