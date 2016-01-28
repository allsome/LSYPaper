//
//  TinyNewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/27/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

class TinyNewsDetailCell: UICollectionViewCell {

    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var testLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = cellGap
        newsView.layer.shadowColor = UIColor.blackColor().CGColor
        newsView.layer.shadowOffset = CGSizeMake(0, 1)
        newsView.layer.shadowOpacity = 0.5
        newsView.layer.shadowRadius = 0.5
    }

}
