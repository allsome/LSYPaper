//
//  TinyNewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/27/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

public let tinyBottomViewDefaultHeight:CGFloat = TINY_RATIO * bottomViewDefaultHeight

class TinyNewsDetailCell: UICollectionViewCell {

    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = cellGap
        newsView.layer.shadowColor = UIColor.black.cgColor
        newsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        newsView.layer.shadowOpacity = 0.5
        newsView.layer.shadowRadius = 0.5
    }

}
