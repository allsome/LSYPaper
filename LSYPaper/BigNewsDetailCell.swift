//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

public let bottomViewDefaultHeight:CGFloat = 55

class BigNewsDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    private var panNewsView:UIPanGestureRecognizer = UIPanGestureRecognizer()

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
        print(recognizer.locationInView(self))
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
