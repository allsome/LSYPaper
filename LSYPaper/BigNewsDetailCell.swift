//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

public let bottomViewDefaultHeight:CGFloat = 55
private let newsViewWidth:CGFloat = (SCREEN_WIDTH - 40) / 2
class BigNewsDetailCell: UICollectionViewCell {
    
    @IBOutlet weak private var newsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var layerView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    private var panNewsView:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var topLayer:CALayer = CALayer()
    private var bottomLayer:CALayer = CALayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = cellGap
        newsView.layer.shadowColor = UIColor.blackColor().CGColor
        newsView.layer.shadowOffset = CGSizeMake(0, 2)
        newsView.layer.shadowOpacity = 0.5
        newsView.layer.shadowRadius = 1.0
        let pan = UIPanGestureRecognizer(target: self, action: "handleCollectPanGesture:")
        pan.delegate = self
        newsView.addGestureRecognizer(pan)
        panNewsView = pan
    }
    
    func handleCollectPanGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            newsView.layer.anchorPoint = CGPointMake(0.5, 0)
            newsViewBottomConstraint.constant = newsViewWidth + 20
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            let translation = recognizer.translationInView(self)
            var transform3D = CATransform3DIdentity;
            transform3D.m34 = -1 / 3000.0;
            let angle = -translation.y / 400.0 * CGFloat(M_PI)
//            if translation.y <= -100 {
//                imageView.alpha = 0.0
//            }else {
//                imageView.alpha = 1.0
//            }
            print(angle)
            newsView.layer.transform = CATransform3DRotate(transform3D, angle, 1, 0, 0)
//            tmpTransform3D.m34 = -1 / 1000.0;
//            topWebView.layer.transform = CATransform3DRotate(tmpTransform3D, -angle, 1, 0, 0)
        }
    }
}

extension BigNewsDetailCell:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panNewsView && panNewsView.velocityInView(self).y >= 0 {
            return false
        }else {
            return true
        }
    }
}
