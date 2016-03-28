//
//  Extension.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/2/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

public extension NSObject {
    public func delay(delay:Double, closure:(() -> Void)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), closure)
    }
}

public extension UIView {
    public func setSpecialCorner(cornerOption:UIRectCorner) {
        self.setSpecialCornerWith(frame: self.bounds, cornerOption: cornerOption)
    }
    
    public func setSpecialCornerWith(frame frame:CGRect,cornerOption:UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: frame, byRoundingCorners: cornerOption, cornerRadii: CGSizeMake(CORNER_REDIUS, CORNER_REDIUS))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        self.layer.mask = maskLayer
    }
    
    public func safeSetAnchorPoint(anchorPoint:CGPoint) {
        let oldFrame = self.frame
        self.layer.anchorPoint = anchorPoint
        self.frame = oldFrame
    }
    
    public func addSpringAnimation(duration:NSTimeInterval,durationArray:[Double],delayArray:[Double],scaleArray:[CGFloat]) {
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: { () -> Void in
            var startTime:Double = 0
            for index in 0..<durationArray.count {
                let relativeDuration = durationArray[index]
                let scale = scaleArray[index]
                let delay = delayArray[index]
                UIView.addKeyframeWithRelativeStartTime(startTime + delay, relativeDuration: relativeDuration, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(scale, scale)
                })
                startTime += relativeDuration
            }
            }, completion: { (stop:Bool) -> Void in
        })
    }
    
    public func addSpringAnimation() {
        self.addSpringAnimation(0.6, durationArray: [0.20,0.275,0.275,0.25], delayArray: [0.0,0.0,0.0,0.0], scaleArray: [0.7,1.05,0.95,1.0])
    }
    
    public func addPopSpringAnimation() {
        self.addSpringAnimation(0.8, durationArray: [0.20,0.275,0.275,0.25], delayArray: [0.0,0.0,0.0,0.0], scaleArray: [1.4,0.8,1.2,1.0])
    }
    
    public func addFadeAnimation() {
        let anim = CATransition()
        anim.type = kCATransitionFade
        anim.duration = 0.2
        self.layer.addAnimation(anim, forKey: nil)
    }
}

public extension UIColor {
    
    public convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }

    public convenience init?(hexString: String, alpha: Float) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        if (hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) != nil) {
            
            if hex.characters.count == 3 {
                let redHex   = hex.substringToIndex(hex.startIndex.advancedBy(1))
                let greenHex = hex.substringWithRange(Range<String.Index>(hex.startIndex.advancedBy(1)..<hex.startIndex.advancedBy(2)))
                let blueHex  = hex.substringFromIndex(hex.startIndex.advancedBy(2))
                
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            
            let redHex = hex.substringToIndex(hex.startIndex.advancedBy(2))
            let greenHex = hex.substringWithRange(Range<String.Index>(hex.startIndex.advancedBy(2)..<hex.startIndex.advancedBy(4)))
            let blueHex = hex.substringWithRange(Range<String.Index>(hex.startIndex.advancedBy(4)..<hex.startIndex.advancedBy(6)))
            
            var redInt:   CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt:  CUnsignedInt = 0
            
            NSScanner(string: redHex).scanHexInt(&redInt)
            NSScanner(string: greenHex).scanHexInt(&greenInt)
            NSScanner(string: blueHex).scanHexInt(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
        }
        else {
            self.init()
            return nil
        }
    }
    
    public convenience init?(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    public convenience init?(hex: Int, alpha: Float) {
        let hexString = NSString(format: "%2X", hex)
        self.init(hexString: hexString as String , alpha: alpha)
    }
}
