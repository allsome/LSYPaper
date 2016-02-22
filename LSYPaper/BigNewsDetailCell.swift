//
//  NewsDetailCell.swift
//  LSYPaper
//
//  Created by 梁树元 on 1/9/16.
//  Copyright © 2016 allsome.love. All rights reserved.
//

import UIKit

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

private let baseShadowRedius:CGFloat = 50.0
private let realShiningBGColor:UIColor = UIColor(red: 210.0 / 255.0, green: 210.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0)
class BigNewsDetailCell: UICollectionViewCell {
    
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
    
    private var panNewsView:UIPanGestureRecognizer = UIPanGestureRecognizer()
    private var panWebView:UIPanGestureRecognizer = UIPanGestureRecognizer()

    private var topLayer:CALayer = CALayer()
    private var bottomLayer:CALayer = CALayer()
    private var isHasRequest:Bool = false
    private var locationInSelf:CGPoint = CGPointZero
    private var translationInSelf:CGPoint = CGPointZero
    private var velocityInSelf:CGPoint = CGPointZero
    private var transform3D:CATransform3D = CATransform3DIdentity
    private var transformConcat:CATransform3D {
        return CATransform3DConcat(CATransform3DRotate(transform3D, transform3DAngle, 1, 0, 0), CATransform3DMakeTranslation(translationInSelf.x, 0, 0))
    }
    private var foldScale:CGFloat {
        let a = (SCREEN_WIDTH / (newsViewWidth * 2) - 1) / ((maxFoldAngle - minFoldAngle) * CGFloat(M_PI))
        let b = 1 - (SCREEN_WIDTH / (newsViewWidth * 2) - 1) * minFoldAngle / (maxFoldAngle - minFoldAngle)
        return a * transform3DAngleFold + b <= 1 ? 1 : a * transform3DAngleFold + b
    }
    private var transformConcatFold:CATransform3D {
        return CATransform3DConcat(CATransform3DConcat(CATransform3DRotate(transform3D, transform3DAngleFold, 1, 0, 0), CATransform3DMakeTranslation(translationInSelf.x, (SCREEN_WIDTH - newsViewY), 0)), CATransform3DMakeScale(foldScale, foldScale, 1))
    }
    private var transformEndedConcat:CATransform3D {
        return CATransform3DConcat(CATransform3DConcat(CATransform3DRotate(transform3D, CGFloat(M_PI), 1, 0, 0), CATransform3DMakeTranslation(0, (SCREEN_WIDTH - newsViewY) - 20, 0)), CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1))
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
        let pan = UIPanGestureRecognizer(target: self, action: "handleNewsPanGesture:")
        pan.delegate = self
        newsView.addGestureRecognizer(pan)
        panNewsView = pan
        transform3D.m34 = -1 / transform3Dm34D
        webViewHeightConstraint.constant = SCREEN_WIDTH * 2
        webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, SCREEN_WIDTH * 2 - SCREEN_HEIGHT, 0)
        let webViewPan = UIPanGestureRecognizer(target: self, action: "handleWebPanGesture:")
        webViewPan.delegate = self
        webView.addGestureRecognizer(webViewPan)
        panWebView = webViewPan
    }
    
    func loadWebViewRequest() {
        if self.isHasRequest == false {
            self.webView.loadRequest(self.webViewRequest)
            self.isHasRequest = true
        }
    }
    func handleWebPanGesture(recognizer:UIPanGestureRecognizer) {
        locationInSelf = recognizer.locationInView(self)
        translationInSelf = recognizer.translationInView(self)
        if recognizer.state == UIGestureRecognizerState.Began {
            webView.scrollView.panGestureRecognizer.enabled = false
            webView.alpha = 0.0
            UIView.animateWithDuration(animateDuration * 2 + 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.newsView.layer.transform = self.transformConcatFold
                self.shiningView.layer.transform = self.transformConcatFold
                self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(self.foldScale, self.foldScale, 1), CATransform3DMakeTranslation(self.translationInSelf.x, SCREEN_WIDTH - newsViewY, 0))
                
                self.newsView.layer.shadowColor = UIColor.blackColor().CGColor
                self.realBaseView.alpha = 1.0
                self.realShiningView.alpha = 1.0
                }, completion: { (stop:Bool) -> Void in
            })
        }else if recognizer.state == UIGestureRecognizerState.Changed && webView.scrollView.panGestureRecognizer.enabled == false {
            newsView.layer.transform = transformConcatFold
            shiningView.layer.transform = transformConcatFold
            baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(foldScale, foldScale, 1), CATransform3DMakeTranslation(translationInSelf.x, SCREEN_WIDTH - newsViewY, 0))
            shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (transform3DAngleFold - startAngle) / (endAngle - startAngle))
            
            if transform3DAngleFold / CGFloat(M_PI) >= 0.5 {
                shiningImage.alpha = 0
                realShiningView.alpha = 1.0
                shiningView.backgroundColor = UIColor.whiteColor()
                realShiningView.backgroundColor = realShiningBGColor
                newsView.layer.shadowColor = UIColor.blackColor().CGColor
                shadowView.layer.shadowColor = UIColor.clearColor().CGColor
            }else {
                shiningImage.alpha = 1
                realShiningView.alpha = 0.0
                shiningView.backgroundColor = UIColor.clearColor()
                newsView.layer.shadowColor = UIColor.clearColor().CGColor
                shadowView.layer.shadowColor = UIColor.blackColor().CGColor
            }
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended) && webView.scrollView.panGestureRecognizer.enabled == false{
            webView.scrollView.panGestureRecognizer.enabled = true
            velocityInSelf = recognizer.velocityInView(self)
            if self.velocityInSelf.y < 0 {
                if transform3DAngle / CGFloat(M_PI) < 0.5 {
                    UIView.animateWithDuration(animateDuration * Double(transform3DAngleFold / CGFloat(M_PI)), delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        self.newsView.layer.transform = CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0)
                        self.shiningView.layer.transform = CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0)
                        }, completion: { (stop:Bool) -> Void in
                            self.shiningImage.alpha = 0.0
                            self.realShiningView.alpha = 1.0
                            self.shiningView.backgroundColor = UIColor.whiteColor()
                            self.realShiningView.backgroundColor = realShiningBGColor
                            self.newsView.layer.shadowColor = UIColor.blackColor().CGColor
                            self.shadowView.layer.shadowColor = UIColor.clearColor().CGColor
                            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                                self.newsView.layer.transform = self.transformEndedConcat
                                self.shiningView.layer.transform = self.transformEndedConcat
                                self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1), CATransform3DMakeTranslation(0, SCREEN_WIDTH - newsViewY, 0))
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
                    UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        self.newsView.layer.transform = self.transformEndedConcat
                        self.shiningView.layer.transform = self.transformEndedConcat
                        self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1), CATransform3DMakeTranslation(0, SCREEN_WIDTH - newsViewY, 0))
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
            }
        }
    }

    
    func handleNewsPanGesture(recognizer:UIPanGestureRecognizer) {
        locationInSelf = recognizer.locationInView(self)
        if recognizer.state == UIGestureRecognizerState.Began {
            newsView.layer.anchorPoint = CGPointMake(0.5, 0)
            newsViewBottomConstraint.constant = newsViewWidth
            shiningView.layer.anchorPoint = CGPointMake(0.5, 0)
            shiningViewBottomConstraint.constant = newsViewWidth
            translationInSelf = recognizer.translationInView(self)
            UIView.animateWithDuration(animateDuration * 2 + 0.2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.newsView.layer.transform = self.transformConcat
                self.shiningView.layer.transform = self.transformConcat
                self.shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (self.transform3DAngle - startAngle) / (endAngle - startAngle))
                self.totalView.transform = CGAffineTransformMakeScale(minScale, minScale)
                self.baseLayerView.alpha = 1.0
                self.realBaseView.alpha = 1.0
                }, completion: { (stop:Bool) -> Void in
            })
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            translationInSelf = recognizer.translationInView(self)
            newsView.layer.transform = transformConcat
            shiningView.layer.transform = transformConcat
            baseLayerView.layer.transform = CATransform3DMakeTranslation(translationInSelf.x, 0, 0)
            shiningImage.transform = CGAffineTransformMakeTranslation(0, shiningImageHeight + newsViewWidth * 2 * (transform3DAngle - startAngle) / (endAngle - startAngle))
            if transform3DAngle / CGFloat(M_PI) >= 0.5 {
                shiningImage.alpha = 0
                realShiningView.alpha = 1.0
                shiningView.backgroundColor = UIColor.whiteColor()
                realShiningView.backgroundColor = realShiningBGColor
                newsView.layer.shadowColor = UIColor.blackColor().CGColor
                shadowView.layer.shadowColor = UIColor.clearColor().CGColor
            }else {
                shiningImage.alpha = 1
                realShiningView.alpha = 0.0
                shiningView.backgroundColor = UIColor.clearColor()
                newsView.layer.shadowColor = UIColor.clearColor().CGColor
                shadowView.layer.shadowColor = UIColor.blackColor().CGColor
            }
        }else if (recognizer.state == UIGestureRecognizerState.Cancelled || recognizer.state == UIGestureRecognizerState.Ended){
            velocityInSelf = recognizer.velocityInView(self)
            if self.velocityInSelf.y <= 0 {
                if transform3DAngle / CGFloat(M_PI) < 0.5 {
                    UIView.animateWithDuration(animateDuration * Double(transform3DAngle / CGFloat(M_PI)), delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        self.newsView.layer.transform = CATransform3DConcat(CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0),CATransform3DMakeTranslation(self.translationInSelf.x, 0, 0))
                        self.shiningView.layer.transform = CATransform3DConcat(CATransform3DRotate(self.transform3D, CGFloat(M_PI_2), 1, 0, 0),CATransform3DMakeTranslation(self.translationInSelf.x, 0, 0))
                        }, completion: { (stop:Bool) -> Void in
                            self.shiningImage.alpha = 0.0
                            self.realShiningView.alpha = 1.0
                            self.shiningView.backgroundColor = UIColor.whiteColor()
                            self.realShiningView.backgroundColor = realShiningBGColor
                            self.newsView.layer.shadowColor = UIColor.blackColor().CGColor
                            self.shadowView.layer.shadowColor = UIColor.clearColor().CGColor
                            UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                                self.newsView.layer.transform = self.transformEndedConcat
                                self.shiningView.layer.transform = self.transformEndedConcat
                                self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1), CATransform3DMakeTranslation(0, SCREEN_WIDTH - newsViewY, 0))
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
                    UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                        self.newsView.layer.transform = self.transformEndedConcat
                        self.shiningView.layer.transform = self.transformEndedConcat
                        self.baseLayerView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(SCREEN_WIDTH / (newsViewWidth * 2), SCREEN_WIDTH / (newsViewWidth * 2), 1), CATransform3DMakeTranslation(0, SCREEN_WIDTH - newsViewY, 0))
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
                    },completion: { (stop:Bool) -> Void in})
            }
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
