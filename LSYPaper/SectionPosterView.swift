//
//  SectionPosterView.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/6/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

class SectionPosterView: UIView {

    @IBOutlet weak var titleLabel: LSYShimmerLabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var shadowImage: UIImageView!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var posterImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shadowImageHeightConstraint: NSLayoutConstraint!
    private var sectionData:SectionData?
    private var targetFrame:CGRect = CGRectZero

    override func awakeFromNib() {
        posterImageHeightConstraint.constant = POSTER_HEIGHT
        shadowImageHeightConstraint.constant = POSTER_HEIGHT
        shadowImage.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1, 0, 0)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 2 * POSTER_HEIGHT - SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - POSTER_HEIGHT)
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 1.0).CGColor,UIColor.clearColor().CGColor]
        gradientLayer.startPoint = CGPointMake(0.5, 0.3)
        gradientLayer.endPoint = CGPointMake(0.5, 1.0)
        shadowImage.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        frame = targetFrame
    }
    
    class func sectionPosterViewWith(data data:SectionData, frame:CGRect) -> SectionPosterView {
        let objs = NSBundle.mainBundle().loadNibNamed("SectionPosterView", owner: nil, options: nil)
        let posterView = objs.last as! SectionPosterView
        posterView.posterImage.image = UIImage(named: data.standByIcon)
        posterView.shadowImage.image = UIImage(named: data.standByIcon)
        posterView.titleLabel.text = data.title
        posterView.titleLabel.startAnimate()
        posterView.subTitleLabel.text = data.subTitle
        posterView.targetFrame = frame
        posterView.frame = frame
        
        return posterView
    }
}
