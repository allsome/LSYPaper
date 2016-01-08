//
//  LSYShimmerLabel.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/8/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

private let shimmerAnimateKey = "shimmerAnimateKey"
private let startPointKeyPath = "startPoint"
private let endPointKeyPath = "endPoint"

class LSYShimmerLabel: UILabel {

    private var textLayer:CATextLayer = CATextLayer()
    
    private var gradientLayer:CAGradientLayer {
        get {
            return self.layer as! CAGradientLayer
        }
    }
    
    var shimmerWidth:CGFloat = 1.0 {
        didSet {
            
        }
    }
    
    var shimmerColor:UIColor = UIColor.whiteColor() {
        didSet {
            gradientLayer.colors = [textColor.CGColor,shimmerColor.CGColor, textColor.CGColor];
        }
    }
    
    var animateDuration:Double = 2.0 {
        didSet {
            
        }
    }
    
    override var text:String? {
        didSet {
            textLayer.string = text
        }
    }
    
    override var font:UIFont! {
        didSet {
            var transform = CGAffineTransformIdentity
            let fontRef = CTFontCreateWithName(font.fontName as CFStringRef, font.pointSize, &transform)
            textLayer.font = fontRef
            textLayer.fontSize = font.pointSize
        }
    }
    
    override var textAlignment:NSTextAlignment {
        didSet {
            textLayer.alignmentMode = LSYShimmerLabel.CAAlignmentFromNSTextAlignment(textAlignment)
        }
    }
    
    override var textColor:UIColor! {
        didSet {
            gradientLayer.backgroundColor = textColor.CGColor
            gradientLayer.colors = [textColor.CGColor,shimmerColor.CGColor, textColor.CGColor];
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetting()
    }

    private func initialSetting() {
        textLayer.backgroundColor = UIColor.clearColor().CGColor
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.rasterizationScale = UIScreen.mainScreen().scale

        font = super.font
        text = super.text
        textAlignment = super.textAlignment
        textColor = super.textColor
        
        gradientLayer.mask = textLayer
    }
    
    func startAnimate() {
        if (gradientLayer.animationForKey(shimmerAnimateKey) == nil) {
            let startPointAnimation = CABasicAnimation(keyPath: startPointKeyPath)
            startPointAnimation.fromValue = NSValue(CGPoint:CGPointMake(-shimmerWidth, 0))
            startPointAnimation.toValue = NSValue(CGPoint:CGPointMake(1.0, 0))
            startPointAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

            let endPointAnimation = CABasicAnimation(keyPath: endPointKeyPath)
            endPointAnimation.fromValue = NSValue(CGPoint:CGPointMake(0, 0))
            endPointAnimation.toValue = NSValue(CGPoint:CGPointMake(1 + shimmerWidth, 0))
            endPointAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let group = CAAnimationGroup()
            group.animations = [startPointAnimation, endPointAnimation]
            group.duration = animateDuration
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            group.repeatCount = FLT_MAX;
            
            gradientLayer.addAnimation(group, forKey: shimmerAnimateKey)
        }
    }
    
    func stopAnimate() {
        if (gradientLayer.animationForKey(shimmerAnimateKey) != nil) {
            gradientLayer.removeAnimationForKey(shimmerAnimateKey)
        }
    }
    
    class func CAAlignmentFromNSTextAlignment(textAlignment: NSTextAlignment) -> String {
        switch textAlignment {
        case NSTextAlignment.Left:
            return kCAAlignmentLeft
        case NSTextAlignment.Center:
            return kCAAlignmentCenter
        case NSTextAlignment.Right:
            return kCAAlignmentRight
        default:
            return kCAAlignmentNatural
        }
    }
    
    override func drawRect(rect: CGRect) {}
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        textLayer.frame = self.layer.bounds
    }
    
}
