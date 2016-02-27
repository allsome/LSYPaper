//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit
import AVFoundation

public let bottomViewDefaultHeight:CGFloat = 55
private let transform3Dm34D:CGFloat = 1900.0
private let newsViewWidth:CGFloat = (SCREEN_WIDTH - 50) / 2
private let shiningImageHeight:CGFloat = (SCREEN_WIDTH - 50) * 296 / 325
private let newsViewY:CGFloat = SCREEN_HEIGHT - 20 - bottomViewDefaultHeight - newsViewWidth * 2
private let endAngle:CGFloat = CGFloat(M_PI) / 2.5
private let startAngle:CGFloat = CGFloat(M_PI) / 3.3
private let animateDuration:Double = 0.25
private let minScale:CGFloat = 0.97
private let maxFoldAngle:CGFloat = 1.0
private let minFoldAngle:CGFloat = 0.75
private let translationYForView:CGFloat = SCREEN_WIDTH - newsViewY
private let normalScale:CGFloat = SCREEN_WIDTH / (newsViewWidth * 2)
private let baseShadowRedius:CGFloat = 50.0
private let emitterWidth:CGFloat = 35.0

private let realShiningBGColor:UIColor = UIColor(white: 0.0, alpha: 0.4)

class BigNewsDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var upperScreenShot: UIImageView!
    @IBOutlet weak var baseScreenShot: UIImageView!
    @IBOutlet weak var baseLayerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var realShiningView: UIView!
    @IBOutlet weak var realBaseView: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var shiningViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var newsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var coreViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var shiningView: UIView!
    @IBOutlet weak private var shiningImage: UIImageView!
    @IBOutlet weak private var baseLayerView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    private var panNewsView:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var panWebView:UIPanGestureRecognizer = UIPanGestureRecognizer()

    private var topLayer:CALayer = CALayer()
    private var bottomLayer:CALayer = CALayer()
    private var isHasRequest:Bool = false
    private var isLike:Bool = false
    private var isShare:Bool = false
    private var isDarkMode:Bool = false {
        didSet {
            if isDarkMode == true {
                if isLike == false {
                    likeButton.setImage(UIImage(named: "LikePhoto"), forState: UIControlState.Normal)
                }
                commentButton.setImage(UIImage(named: "CommentPhoto"), forState: UIControlState.Normal)
                shareButton.setImage(UIImage(named: "SharePhoto"), forState: UIControlState.Normal)
                summaryLabel.textColor = UIColor.whiteColor()
                commentLabel.textColor = UIColor.whiteColor()
            }else {
                if isLike == false {
                    likeButton.setImage(UIImage(named: "Like"), forState: UIControlState.Normal)
                }
                commentButton.setImage(UIImage(named: "Comment"), forState: UIControlState.Normal)
                shareButton.setImage(UIImage(named: "Share"), forState: UIControlState.Normal)
                summaryLabel.textColor = UIColor.lightGrayColor()
                commentLabel.textColor = UIColor.lightGrayColor()
            }
        }
    }

    private var locationInSelf:CGPoint = CGPointZero
    private var translationInSelf:CGPoint = CGPointZero
    private var velocityInSelf:CGPoint = CGPointZero
    private var transform3D:CATransform3D = CATransform3DIdentity
    private var transformConcat:CATransform3D {
        return CATransform3DConcat(CATransform3DRotate(transform3D, transform3DAngle, 1, 0, 0), CATransform3DMakeTranslation(translationInSelf.x, 0, 0))
    }
    private var foldScale:CGFloat {
        let a = (normalScale - 1) / ((maxFoldAngle - minFoldAngle) * CGFloat(M_PI))
        let b = 1 - (normalScale - 1) * minFoldAngle / (maxFoldAngle - minFoldAngle)
        return a * transform3DAngleFold + b <= 1 ? 1 : a * transform3DAngleFold + b
    }
    private var transformConcatFold:CATransform3D {
        return CATransform3DConcat(CATransform3DConcat(CATransform3DRotate(transform3D, transform3DAngleFold, 1, 0, 0), CATransform3DMakeTranslation(translationInSelf.x / foldScale, translationYForView / foldScale, 0)), CATransform3DMakeScale(foldScale, foldScale, 1))
    }
    private var transformEndedConcat:CATransform3D {
        let scale = normalScale
        return CATransform3DConcat(CATransform3DConcat(CATransform3DRotate(transform3D, CGFloat(M_PI), 1, 0, 0), CATransform3DMakeTranslation(0, translationYForView / scale, 0)), CATransform3DMakeScale(scale, scale, 1))
    }
    private var transform3DAngle:CGFloat {
        let cosUpper = locationInSelf.y - newsViewY >= (newsViewWidth * 2) ? (newsViewWidth * 2) : locationInSelf.y - newsViewY
        return acos(cosUpper / (newsViewWidth * 2))
            + asin((locationInSelf.y - newsViewY) / transform3Dm34D)
    }
    private var transform3DAngleFold:CGFloat {
        let cosUpper = locationInSelf.y - SCREEN_WIDTH
        return acos(cosUpper / SCREEN_WIDTH)
    }
    private var webViewRequest:NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "https://baidu.com")!)
    }
    
    private var soundID:SystemSoundID {
        var soundID:SystemSoundID = 0
        let path = NSBundle.mainBundle().pathForResource("Pop", ofType: "wav")
        let baseURL = NSURL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        return soundID
    }
    @IBOutlet weak var likeView: UIView!
    private var explosionLayer:CAEmitterLayer = CAEmitterLayer()
    private var chargeLayer:CAEmitterLayer = CAEmitterLayer()
    
    var unfoldWebViewOption:(() -> Void)?
    var foldWebViewOption:(() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        totalView.layer.masksToBounds = true
        totalView.layer.cornerRadius = cellGap * 2
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 1.0
        baseLayerView.layer.shadowColor = UIColor.blackColor().CGColor
        baseLayerView.layer.shadowOffset = CGSizeMake(0, baseShadowRedius)
        baseLayerView.layer.shadowOpacity = 0.8
        baseLayerView.layer.shadowRadius = baseShadowRedius
        baseLayerView.alpha = 0.0
        newsView.layer.shadowColor = UIColor.clearColor().CGColor
        newsView.layer.shadowOffset = CGSizeMake(0, baseShadowRedius)
        newsView.layer.shadowOpacity = 0.4
        newsView.layer.shadowRadius = baseShadowRedius
        upperScreenShot.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1, 0, 0)
        let pan = UIPanGestureRecognizer(target: self, action: "handleNewsPanGesture:")
        pan.delegate = self
        newsView.addGestureRecognizer(pan)
        panNewsView = pan
        let tap = UITapGestureRecognizer(target: self, action: "handleNewsTapGesture:")
        newsView.addGestureRecognizer(tap)
        transform3D.m34 = -1 / transform3Dm34D
        webViewHeightConstraint.constant = SCREEN_WIDTH * 2
        webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, SCREEN_WIDTH * 2 - SCREEN_HEIGHT, 0)
        let webViewPan = UIPanGestureRecognizer(target: self, action: "handleWebPanGesture:")
        webViewPan.delegate = self
        webView.addGestureRecognizer(webViewPan)
        panWebView = webViewPan
        
        // heavily refer to MCFireworksView by Matthew Cheok
        let explosionCell = CAEmitterCell()
        explosionCell.name = "explosion"
        explosionCell.alphaRange = 0.2
        explosionCell.alphaSpeed = -1.0
        explosionCell.lifetime = 0.5
        explosionCell.lifetimeRange = 0.0
        explosionCell.birthRate = 0
        explosionCell.velocity = 44.00
        explosionCell.velocityRange = 7.00
        explosionCell.contents = UIImage(named: "Sparkle")?.CGImage
        explosionCell.scale = 0.05
        explosionCell.scaleRange = 0.02
        
        let explosionLayer = CAEmitterLayer()
        explosionLayer.name = "emitterLayer"
        explosionLayer.emitterShape = kCAEmitterLayerCircle
        explosionLayer.emitterMode = kCAEmitterLayerOutline
        explosionLayer.emitterSize = CGSizeMake(emitterWidth, 0)
        let center = CGPointMake(CGRectGetMidX(likeView.bounds), CGRectGetMidY(likeView.bounds))
        
        explosionLayer.emitterPosition = center
        explosionLayer.emitterCells = [explosionCell]
        explosionLayer.masksToBounds = false
        
        likeView.layer.addSublayer(explosionLayer)
        self.explosionLayer = explosionLayer
        
        let chargeCell = CAEmitterCell()
        chargeCell.name = "charge"
        chargeCell.alphaRange = 0.20
        chargeCell.alphaSpeed = -1.0
        
        chargeCell.lifetime = 0.3
        chargeCell.lifetimeRange = 0.1
        chargeCell.birthRate = 0
        chargeCell.velocity = -60.0
        chargeCell.velocityRange = 0.00
        chargeCell.contents = UIImage(named: "Sparkle")?.CGImage
        chargeCell.scale = 0.05
        chargeCell.scaleRange = 0.02
        
        let chargeLayer = CAEmitterLayer()
        chargeLayer.name = "emitterLayer"
        chargeLayer.emitterShape = kCAEmitterLayerCircle
        chargeLayer.emitterMode = kCAEmitterLayerOutline
        chargeLayer.emitterSize = CGSizeMake(emitterWidth - 10, 0)
        
        chargeLayer.emitterPosition = center
        chargeLayer.emitterCells = [chargeCell]
        chargeLayer.masksToBounds = false
        likeView.layer.addSublayer(chargeLayer)
        self.chargeLayer = chargeLayer
    }
    
    func handleNewsTapGesture(recognizer:UITapGestureRecognizer) {
        anchorPointSetting()
        baseLayerView.alpha = 1.0
        realBaseView.alpha = 0.5
        locationInSelf = CGPointMake(0, SCREEN_HEIGHT - 9.5)
        gestureStateChangedSetting(transform3DAngle)
        tapNewsView()
    }
    
    func handleWebPanGesture(recognizer:UIPanGestureRecognizer) {
        locationInSelf = recognizer.locationInView(self)
        translationInSelf = recognizer.translationInView(self)
        if recognizer.state == UIGestureRecognizerState.Began {
            baseScreenShot.image = self.getSubImageFrom(self.getWebViewScreenShot(), frame: CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, SCREEN_WIDTH))
            upperScreenShot.image = self.getSubImageFrom(self.getWebViewScreenShot(), frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH))
            webView.scrollView.panGestureRecognizer.enabled = false
            webView.alpha = 0.0
            let ratio = (M_PI - Double(transform3DAngleFold)) / M_PI
            let alpha:CGFloat = transform3DAngleFold / CGFloat(M_PI) >= 0.5 ? 1.0 : 0.0
            UIView.animateWithDuration((animateDuration * 2 + 0.2) * ratio, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.newsView.layer.transform = self.transformConcatFold
                self.shiningView.layer.transform = self.transformConcatFold
                self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(self.foldScale, self.foldScale, 1), CATransform3DMakeTranslation(self.translationInSelf.x, translationYForView, 0))
                
                self.newsView.layer.shadowColor = UIColor.blackColor().CGColor
                self.realBaseView.alpha = 0.5
                self.realShiningView.alpha = 0.5
                self.upperScreenShot.alpha = alpha
                }, completion: { (stop:Bool) -> Void in
            })
        }else if recognizer.state == UIGestureRecognizerState.Changed && webView.scrollView.panGestureRecognizer.enabled == false {
            newsView.layer.transform = transformConcatFold
            shiningView.layer.transform = transformConcatFold
            baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(foldScale, foldScale, 1), CATransform3DMakeTranslation(translationInSelf.x, translationYForView, 0))
            shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (transform3DAngleFold - startAngle) / (endAngle - startAngle))
            gestureStateChangedSetting(transform3DAngleFold)
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended) && webView.scrollView.panGestureRecognizer.enabled == false{
            webView.scrollView.panGestureRecognizer.enabled = true
            velocityInSelf = recognizer.velocityInView(self)
            if self.velocityInSelf.y < 0 {
                if transform3DAngleFold / CGFloat(M_PI) < 0.5 {
                    UIView.animateWithDuration(animateDuration * Double((CGFloat(M_PI) - transform3DAngleFold) / CGFloat(M_PI * 2)), delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        self.newsView.layer.transform = CATransform3DConcat(CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0),CATransform3DMakeTranslation(self.translationInSelf.x, translationYForView, 0))
                        self.shiningView.layer.transform = CATransform3DConcat(CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0),CATransform3DMakeTranslation(self.translationInSelf.x, translationYForView, 0))
                        }, completion: { (stop:Bool) -> Void in
                            self.upperScreenShot.alpha = 1.0
                            self.shiningImage.alpha = 0.0
                            self.realShiningView.alpha = 1.0
                            self.shiningView.backgroundColor = UIColor.whiteColor()
                            self.realShiningView.backgroundColor = realShiningBGColor
                            self.newsView.layer.shadowColor = UIColor.blackColor().CGColor
                            self.shadowView.layer.shadowColor = UIColor.clearColor().CGColor
                            self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(self.foldScale, self.foldScale, 1), CATransform3DMakeTranslation(self.translationInSelf.x, translationYForView / ((normalScale)), 0))
                            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                                self.newsView.layer.transform = self.transformEndedConcat
                                self.shiningView.layer.transform = self.transformEndedConcat
                                self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, translationYForView / ((normalScale)), 0),CATransform3DMakeScale(normalScale, normalScale, 1))
                                self.realBaseView.alpha = 0.0
                                self.realShiningView.alpha = 0.0
                                self.newsView.layer.shadowColor = UIColor.clearColor().CGColor
                                }, completion: { (stop:Bool) -> Void in
                                    if self.velocityInSelf.y <= 0 {
                                        if (self.unfoldWebViewOption != nil) {
                                            self.unfoldWebViewOption!()
                                        }
                                        self.webView.alpha = 1.0
                                        self.loadWebViewRequest()
                                    }
                            })
                    })
                }else {
                    baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(foldScale, foldScale, 1), CATransform3DMakeTranslation(translationInSelf.x, translationYForView / ((normalScale)), 0))
                    UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        self.newsView.layer.transform = self.transformEndedConcat
                        self.shiningView.layer.transform = self.transformEndedConcat
                        self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, translationYForView / ((normalScale)), 0),CATransform3DMakeScale(normalScale, normalScale, 1))
                        self.shiningImage.alpha = 0.0
                        self.realBaseView.alpha = 0.0
                        self.realShiningView.alpha = 0.0
                        self.newsView.layer.shadowColor = UIColor.clearColor().CGColor
                        },completion: { (stop:Bool) -> Void in
                            if self.velocityInSelf.y <= 0 {
                                if (self.unfoldWebViewOption != nil) {
                                    self.unfoldWebViewOption!()
                                }
                                self.webView.alpha = 1.0
                                self.loadWebViewRequest()
                            }
                    })
                }
            }else {
                self.normalLayoutNewsView()
            }
        }
    }

    func handleNewsPanGesture(recognizer:UIPanGestureRecognizer) {
        locationInSelf = recognizer.locationInView(self)
        if recognizer.state == UIGestureRecognizerState.Began {
            anchorPointSetting()
            translationInSelf = recognizer.translationInView(self)
            UIView.animateWithDuration(animateDuration * 2 + 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.newsView.layer.transform = self.transformConcat
                self.shiningView.layer.transform = self.transformConcat
                self.shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (self.transform3DAngle - startAngle) / (endAngle - startAngle))
                self.totalView.transform = CGAffineTransformMakeScale(minScale, minScale)
                self.baseLayerView.alpha = 1.0
                self.realBaseView.alpha = 0.5
                }, completion: { (stop:Bool) -> Void in
            })
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            translationInSelf = recognizer.translationInView(self)
            newsView.layer.transform = transformConcat
            shiningView.layer.transform = transformConcat
            baseLayerView.layer.transform = CATransform3DMakeTranslation(translationInSelf.x, 0, 0)
            shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (transform3DAngle - startAngle) / (endAngle - startAngle))
            gestureStateChangedSetting(transform3DAngle)
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            velocityInSelf = recognizer.velocityInView(self)
            if self.velocityInSelf.y <= 0 {
                if transform3DAngle / CGFloat(M_PI) < 0.5 {
                    tapNewsView()
                }else {
                    UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        self.newsView.layer.transform = self.transformEndedConcat
                        self.shiningView.layer.transform = self.transformEndedConcat
                        self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(normalScale, normalScale, 1), CATransform3DMakeTranslation(0, translationYForView, 0))
                        self.shiningImage.alpha = 0.0
                        self.realBaseView.alpha = 0.0
                        self.realShiningView.alpha = 0.0
                        self.newsView.layer.shadowColor = UIColor.clearColor().CGColor
                        },completion: { (stop:Bool) -> Void in
                            if (self.unfoldWebViewOption != nil) {
                                self.unfoldWebViewOption!()
                            }
                            self.webView.alpha = 1.0
                            self.loadWebViewRequest()
                    })
                }
            }else {
               self.normalLayoutNewsView()
            }
        }
    }
    
}

private extension BigNewsDetailCell {
    
    @IBAction func showShareOrNot(sender: AnyObject) {
        if isShare == false {
            isDarkMode = true
            self.contentView.bringSubviewToFront(self.totalView)
            LSYPaperPopView.showPaperPopViewWith(CGRectMake(0, SCREEN_HEIGHT - 55 - 350, SCREEN_WIDTH, 350), viewMode: LSYPaperPopViewMode.Share, inView: self.totalView, frontView: self.bottomView)
        }else {
            isDarkMode = false
            LSYPaperPopView.hidePaperPopView(self.totalView)
            self.contentView.sendSubviewToBack(self.totalView)
        }
        shareButton.addSpringAnimation()
        isShare = !isShare
    }
    
    @IBAction func likeOrNot(sender: AnyObject) {
        if isLike == false {
            likeButton.addSpringAnimation(1.3, durationArray: [0.05,0.1,0.23,0.195,0.155,0.12], delayArray: [0.0,0.0,0.1,0.0,0.0,0.0], scaleArray: [0.75,1.8,0.8,1.0,0.95,1.0])
            chargeLayer.setValue(100, forKeyPath: "emitterCells.charge.birthRate")
            delay((0.05 + 0.1 + 0.23) * 1.3, closure: { () -> Void in
                self.chargeLayer.setValue(0, forKeyPath: "emitterCells.charge.birthRate")
                self.explosionLayer.setValue(1000, forKeyPath: "emitterCells.explosion.birthRate")
                self.delay(0.1, closure: { () -> Void in
                    self.explosionLayer.setValue(0, forKeyPath: "emitterCells.explosion.birthRate")
                })
                AudioServicesPlaySystemSound(self.soundID)
            })
            likeButton.setImage(UIImage(named: "Like-Blue"), forState: UIControlState.Normal)
            self.commentLabel.text = "Awesome!"
            self.commentLabel.addFadeAnimation()
        }else {
            likeButton.addSpringAnimation()
            let image = isDarkMode == false ? UIImage(named: "Like") : UIImage(named: "LikePhoto")
            likeButton.setImage(image, forState: UIControlState.Normal)
            self.commentLabel.text = "Write a comment"
            self.commentLabel.addFadeAnimation()
        }
        isLike = !isLike
    }
    
    private func loadWebViewRequest() {
        if self.isHasRequest == false {
            self.webView.loadRequest(self.webViewRequest)
            self.isHasRequest = true
        }
    }
    private func anchorPointSetting() {
        newsView.layer.anchorPoint = CGPointMake(0.5, 0)
        newsViewBottomConstraint.constant = newsViewWidth
        shiningView.layer.anchorPoint = CGPointMake(0.5, 0)
        shiningViewBottomConstraint.constant = newsViewWidth
        baseLayerView.layer.anchorPoint = CGPointMake(0.5, 0)
        baseLayerViewBottomConstraint.constant = newsViewWidth
    }
    private func getWebViewScreenShot() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(webView.frame.size, false, 1.0)
        webView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func getSubImageFrom(originImage:UIImage,frame:CGRect) -> UIImage {
        let imageRef = originImage.CGImage
        let subImageRef = CGImageCreateWithImageInRect(imageRef, frame)
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, frame, subImageRef)
        let subImage = UIImage(CGImage: subImageRef!)
        UIGraphicsEndImageContext();
        return subImage;
    }
    
    private func tapNewsView() {
        UIView.animateWithDuration(animateDuration * Double((CGFloat(M_PI) - transform3DAngleFold) / CGFloat(M_PI * 2)), delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.newsView.layer.transform = CATransform3DConcat(CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0),CATransform3DMakeTranslation(self.translationInSelf.x, 0, 0))
            self.shiningView.layer.transform = CATransform3DConcat(CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0),CATransform3DMakeTranslation(self.translationInSelf.x, 0, 0))
            self.shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (self.transform3DAngle - startAngle) / (endAngle - startAngle))
            }, completion: { (stop:Bool) -> Void in
                self.shiningImage.alpha = 0.0
                self.realShiningView.alpha = 0.5
                self.upperScreenShot.alpha = 1.0
                self.shiningView.backgroundColor = UIColor.whiteColor()
                self.realShiningView.backgroundColor = realShiningBGColor
                self.newsView.layer.shadowColor = UIColor.blackColor().CGColor
                self.shadowView.layer.shadowColor = UIColor.clearColor().CGColor
                UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self.newsView.layer.transform = self.transformEndedConcat
                    self.shiningView.layer.transform = self.transformEndedConcat
                    self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(normalScale, normalScale, 1), CATransform3DMakeTranslation(0, translationYForView, 0))
                    self.realBaseView.alpha = 0.0
                    self.realShiningView.alpha = 0.0
                    self.newsView.layer.shadowColor = UIColor.clearColor().CGColor
                    }, completion: { (stop:Bool) -> Void in
                        if (self.unfoldWebViewOption != nil) {
                            self.unfoldWebViewOption!()
                        }
                        self.webView.alpha = 1.0
                        self.loadWebViewRequest()
                })
        })
    }
    
    private func normalLayoutNewsView() {
        UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.newsView.layer.transform = CATransform3DIdentity
            self.shiningView.layer.transform = CATransform3DIdentity
            self.shiningImage.transform = CGAffineTransformIdentity
            self.totalView.transform = CGAffineTransformIdentity
            self.baseLayerView.layer.transform = CATransform3DIdentity
            self.shiningImage.alpha = 1.0
            self.baseLayerView.alpha = 0.0
            self.realShiningView.alpha = 0.0
            self.shiningView.backgroundColor = UIColor.clearColor()
            self.newsView.layer.shadowColor = UIColor.clearColor().CGColor
            self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
            },completion: { (stop:Bool) -> Void in
                if (self.foldWebViewOption != nil) {
                    self.foldWebViewOption!()
                }
        })
    }
    
    private func gestureStateChangedSetting(targetAngle:CGFloat) {
        if targetAngle / CGFloat(M_PI) >= 0.5 {
            upperScreenShot.alpha = 1.0
            shiningImage.alpha = 0
            realShiningView.alpha = 0.5
            shiningView.backgroundColor = UIColor.whiteColor()
            realShiningView.backgroundColor = realShiningBGColor
            newsView.layer.shadowColor = UIColor.blackColor().CGColor
            shadowView.layer.shadowColor = UIColor.clearColor().CGColor
        }else {
            upperScreenShot.alpha = 0.0
            shiningImage.alpha = 1
            realShiningView.alpha = 0.0
            shiningView.backgroundColor = UIColor.clearColor()
            newsView.layer.shadowColor = UIColor.clearColor().CGColor
            shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        }
    }
}

extension BigNewsDetailCell:UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panWebView && otherGestureRecognizer == webView.scrollView.panGestureRecognizer {
            if (webView.scrollView.contentOffset.y <= 0 && webView.scrollView.panGestureRecognizer.velocityInView(self).y >= 0) || webView.scrollView.panGestureRecognizer.locationInView(self).y <= 100 {
                return true
            }else {
                return false
            }
        } else {
            return false
        }
    }
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panNewsView {
            if (panNewsView.velocityInView(self).y >= 0) || fabs(panNewsView.velocityInView(self).x) >= fabs(panNewsView.velocityInView(self).y) {
                return false
            }else {
                return true
            }
        }else {
            return true
        }
    }
}
