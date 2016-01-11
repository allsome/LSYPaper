//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

class NewsDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        trailingConstraint.constant = cellGap
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = cellGap
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, -cellGap)
        layer.shadowRadius = cellGap
        layer.shadowOpacity = 0.5
    }

}
