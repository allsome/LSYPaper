//
//  MTAnimatedLabel.m
//
//
//  Created by Michael Turner on 8/3/12.
//  Copyright (c) 2012 Michael Turner. All rights reserved.
//

/*
 Copyright (c) 2012 Michael Turner. All rights reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MTAnimatedLabel.h"

#define kGradientSize           0.45f
#define kAnimationDuration      2.25f
#define kGradientTint           [UIColor whiteColor]

#define kAnimationKey           @"gradientAnimation"
#define kGradientStartPointKey  @"startPoint"
#define kGradientEndPointKey    @"endPoint"

@interface MTAnimatedLabel ()

@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation MTAnimatedLabel

#pragma mark - Initialization

- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer == nil) {
        _gradientLayer = (CAGradientLayer *)self.layer;
    }
    return _gradientLayer;
}

- (void)initializeLayers
{
    /* set Defaults */
    self.tint               = kGradientTint;
    self.animationDuration  = kAnimationDuration;
    self.gradientWidth      = kGradientSize;
    
    
    self.gradientLayer.backgroundColor   = [super.textColor CGColor];
    self.gradientLayer.startPoint        = CGPointMake(-self.gradientWidth, 0.);
    self.gradientLayer.endPoint          = CGPointMake(0., 0.);
    self.gradientLayer.colors            = @[(id)[[UIColor purpleColor] CGColor],(id)[self.tint CGColor], (id)[self.textColor CGColor]];
    
    self.textLayer                      = [CATextLayer layer];
    self.textLayer.backgroundColor      = [[UIColor clearColor] CGColor];
    self.textLayer.contentsScale        = [[UIScreen mainScreen] scale];
    self.textLayer.rasterizationScale   = [[UIScreen mainScreen] scale];
    //    self.textLayer.bounds               = self.bounds;
    //    self.textLayer.anchorPoint          = CGPointZero;
    
    /* set initial values for the textLayer because they may have been loaded from a nib */
    [self setFont:          super.font];
    [self setTextAlignment: super.textAlignment];
    [self setText:          super.text];
    [self setTextColor:     super.textColor];
    
    /*
     finally set the textLayer as the mask of the gradientLayer, this requires offscreen rendering
     and therefore this label subclass should ONLY BE USED if animation is required
     */
    self.gradientLayer.mask = self.textLayer;
    //    [gradientLayer addSublayer:self.textLayer];
}

- (void)startAnimating
{
    if([self.gradientLayer animationForKey:kAnimationKey] == nil)
    {
        CABasicAnimation *startPointAnimation = [CABasicAnimation animationWithKeyPath:kGradientStartPointKey];
        startPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 0)];
        startPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *endPointAnimation = [CABasicAnimation animationWithKeyPath:kGradientEndPointKey];
        endPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1+self.gradientWidth, 0)];
        endPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[startPointAnimation, endPointAnimation];
        group.duration = self.animationDuration;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.repeatCount = FLT_MAX;
        
        [self.gradientLayer addAnimation:group forKey:kAnimationKey];
    }
}

- (void)stopAnimating
{
    if([self.gradientLayer animationForKey:kAnimationKey])
        [self.gradientLayer removeAnimationForKey:kAnimationKey];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeLayers];
    }
    return self;
}

#pragma mark - UILabel Accessor overrides

- (void)setTextColor:(UIColor *)textColor
{
    self.gradientLayer.backgroundColor   = [textColor CGColor];
    self.gradientLayer.colors            = @[(id)[textColor CGColor],(id)[self.tint CGColor], (id)[textColor CGColor]];
}

- (void)setText:(NSString *)text
{
    self.textLayer.string = text;
}


- (void)setFont:(UIFont *)font
{
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)(font.fontName), font.pointSize, &CGAffineTransformIdentity);
    self.textLayer.font = fontRef;
    self.textLayer.fontSize = font.pointSize;
    CFRelease(fontRef);
}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    [self setNeedsDisplay];
//}

//- (UITextAlignment)textAlignment
//{
//    return [MTAnimatedLabel UITextAlignmentFromCAAlignment:self.textLayer.alignmentMode];
//}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.textLayer.alignmentMode = [MTAnimatedLabel CAAlignmentFromUITextAlignment:textAlignment];
}

#pragma mark - UILabel Layer override

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

/* Stop UILabel from drawing because we are using a CATextLayer for that! */
- (void)drawRect:(CGRect)rect {}

#pragma mark - Utility Methods

+ (NSString *)CAAlignmentFromUITextAlignment:(NSTextAlignment)textAlignment
{
    switch (textAlignment) {
        case NSTextAlignmentLeft:   return kCAAlignmentLeft;
        case NSTextAlignmentCenter: return kCAAlignmentCenter;
        case NSTextAlignmentRight:  return kCAAlignmentRight;
        default:                    return kCAAlignmentNatural;
    }
}

//+ (UITextAlignment)UITextAlignmentFromCAAlignment:(NSString *)alignment
//{
//    if ([alignment isEqualToString:kCAAlignmentLeft])       return UITextAlignmentLeft;
//    if ([alignment isEqualToString:kCAAlignmentCenter])     return UITextAlignmentCenter;
//    if ([alignment isEqualToString:kCAAlignmentRight])      return UITextAlignmentRight;
//    if ([alignment isEqualToString:kCAAlignmentNatural])    return UITextAlignmentLeft;
//    return UITextAlignmentLeft;
//}

#pragma mark - LayoutSublayers

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.textLayer.frame = self.layer.bounds;
}

#pragma mark - MTAnimated Label Public Methods

//- (void)setTint:(UIColor *)tint
//{
//    _tint = tint;
//
//    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
//    gradientLayer.colors            = @[(id)[self.textColor CGColor],(id)[_tint CGColor], (id)[self.textColor CGColor]];
//    [self setNeedsDisplay];
//}



@end
