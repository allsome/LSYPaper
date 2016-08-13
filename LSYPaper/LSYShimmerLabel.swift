//
//  LSYShimmerLabel.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/8/16.
//  Copyright © 2016 allsome.love. All rights reserved.

// ********* Heavily refer to MTAnimatedLabel *********

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
    
    var shimmerColor:UIColor = UIColor.white {
        didSet {
            gradientLayer.colors = [textColor.cgColor,shimmerColor.cgColor,shimmerColor.cgColor, textColor.cgColor]
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
            var transform = CGAffineTransform.identity
            let fontRef = CTFontCreateWithName(font.fontName as CFString, font.pointSize, &transform)
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
            gradientLayer.backgroundColor = textColor.cgColor
            gradientLayer.colors = [textColor.cgColor,shimmerColor.cgColor,shimmerColor.cgColor, textColor.cgColor]
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
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.rasterizationScale = UIScreen.main.scale

        font = super.font
        text = super.text
        textAlignment = super.textAlignment
        textColor = super.textColor
        
        gradientLayer.mask = textLayer
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func startAnimate() {
        if (gradientLayer.animation(forKey: shimmerAnimateKey) == nil) {
            let startPointAnimation = CABasicAnimation(keyPath: startPointKeyPath)
            startPointAnimation.fromValue = NSValue(cgPoint:CGPoint(x: -shimmerWidth, y: 0))
            startPointAnimation.toValue = NSValue(cgPoint:CGPoint(x: 1.0, y: 0))
            startPointAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

            let endPointAnimation = CABasicAnimation(keyPath: endPointKeyPath)
            endPointAnimation.fromValue = NSValue(cgPoint:CGPoint(x: 0, y: 0))
            endPointAnimation.toValue = NSValue(cgPoint:CGPoint(x: 1 + shimmerWidth, y: 0))
            endPointAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let group = CAAnimationGroup()
            group.animations = [startPointAnimation, endPointAnimation]
            group.duration = animateDuration
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            group.repeatCount = FLT_MAX
            
            gradientLayer.add(group, forKey: shimmerAnimateKey)
        }
    }
    
    func stopAnimate() {
        if (gradientLayer.animation(forKey: shimmerAnimateKey) != nil) {
            gradientLayer.removeAnimation(forKey: shimmerAnimateKey)
        }
    }
    
    
    func applicationDidEnterBackground(_ note:Notification) {
        stopAnimate()
    }
    
    func applicationWillEnterForeground(_ note:Notification) {
        startAnimate()
    }
    
    class func CAAlignmentFromNSTextAlignment(_ textAlignment: NSTextAlignment) -> String {
        switch textAlignment {
        case NSTextAlignment.left:
            return kCAAlignmentLeft
        case NSTextAlignment.center:
            return kCAAlignmentCenter
        case NSTextAlignment.right:
            return kCAAlignmentRight
        default:
            return kCAAlignmentNatural
        }
    }
    
    override func draw(_ rect: CGRect) {}

    override static var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSublayers(of layer: CALayer) {
        textLayer.frame = self.layer.bounds
    }
    
}
