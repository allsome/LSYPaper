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
    private var targetFrame:CGRect = CGRect.zero

    override func awakeFromNib() {
        posterImageHeightConstraint.constant = POSTER_HEIGHT
        shadowImageHeightConstraint.constant = POSTER_HEIGHT
        shadowImage.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1, 0, 0)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 2 * POSTER_HEIGHT - SCREEN_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - POSTER_HEIGHT)
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 1.0).cgColor,UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        shadowImage.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        frame = targetFrame
    }
    
    class func sectionPosterViewWith(data:SectionData, frame:CGRect) -> SectionPosterView {
        let objs = Bundle.main.loadNibNamed("SectionPosterView", owner: nil, options: nil)
        let posterView = objs?.last as! SectionPosterView
        posterView.posterImage.image = UIImage(named: data.icon)
        posterView.shadowImage.image = UIImage(named: data.icon)
        posterView.titleLabel.text = data.title
        posterView.titleLabel.startAnimate()
        posterView.subTitleLabel.text = data.subTitle
        posterView.targetFrame = frame
        posterView.frame = frame
        
        return posterView
    }
}
