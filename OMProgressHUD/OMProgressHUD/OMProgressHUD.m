//
//  TMSProgressHUD.m
//  TiMaSuperApp
//
//  Created by 印聪 on 2017/6/29.
//  Copyright © 2017年 tima. All rights reserved.
//

#import "OMProgressHUD.h"

static OMProgressHUD *defaultView = nil;
@interface OMProgressHUD()

@property (nonatomic , strong)UIView *contentView;
@property (nonatomic , strong)CAShapeLayer *loadingLayer;
@property (nonatomic , strong)UILabel *messageLabel;

@end

@implementation OMProgressHUD


+ (instancetype)defaultView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultView = [[self alloc] init];
    });
    return defaultView;
}



- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
}


#pragma mark -- private method
- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
            return window;
        }
    }
    return nil;
}

- (void)beginLoadAnimation{
    //动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.8;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = ULLONG_MAX;
    [self.loadingLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}


- (void)endLoadAnimation{
    [self.loadingLayer removeAllAnimations];
}

#pragma mark -- public method
+ (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
        [progressHUD showLoading];
    });
}

+ (void)dismiss{
    
    if ([OMProgressHUD defaultView]) {
        [OMProgressHUD defaultView].messageLabel.text = nil;
        [[OMProgressHUD defaultView] endLoadAnimation];
        [[OMProgressHUD defaultView] removeFromSuperview];
        
        if ([OMProgressHUD defaultView].messageLabel) {
            [[OMProgressHUD defaultView].messageLabel removeFromSuperview];
        }
        
    }
}


+ (void)show:(NSString *)message{
    
    if ([OMProgressHUD defaultView].messageLabel && [[OMProgressHUD defaultView].messageLabel.text isEqualToString:message]) {
        return;
    }
    
    
    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
    if (window) {
        
        if ([OMProgressHUD defaultView].messageLabel) {
            [[OMProgressHUD defaultView].messageLabel removeFromSuperview];
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [[UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0] colorWithAlphaComponent:0.8];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 5;
        label.text = message;
        CGFloat textMaxW = [UIScreen mainScreen].bounds.size.width - 20;
        CGSize size = [message sizeWithAttributes:@{NSFontAttributeName:label.font}];
        size = CGSizeMake(size.width + 20, 50);
        if (size.width > textMaxW) {
            //最大高度为屏幕高度减去下边距(label距离屏幕底部)高度(40)，再减去上边距高度(20)
            CGFloat maxH = [UIScreen mainScreen].bounds.size.height - 40 - 20;
            CGRect rect = [message boundingRectWithSize:CGSizeMake(textMaxW, maxH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];
            size = CGSizeMake(textMaxW, rect.size.height + 10);
        }
        label.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width) * 0.5, [UIScreen mainScreen].bounds.size.height - 40 - size.height, size.width, size.height);
        [window addSubview:label];
        
        [OMProgressHUD defaultView].messageLabel = label;
        
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(dismissInfo:) userInfo:label repeats:NO];
        
    }
}

+ (void)dismissInfo:(NSTimer *)timer{
    
    UILabel *label = timer.userInfo;
    [label removeFromSuperview];
    if ([label.text isEqualToString:[OMProgressHUD defaultView].messageLabel.text]) {
        [OMProgressHUD defaultView].messageLabel = nil;
        [[OMProgressHUD defaultView] removeFromSuperview];
    }
}


- (void)showLoading{
    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
    progressHUD.frame = [UIScreen mainScreen].bounds;
    progressHUD.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    UIView *contentView = progressHUD.contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 3.0f;
    contentView.bounds = CGRectMake(0, 0, 80, 80);
    contentView.center = CGPointMake(progressHUD.bounds.size.width * 0.5, progressHUD.bounds.size.height * 0.5);
    contentView.hidden = NO;
    [progressHUD addSubview:contentView];

    CGPoint layerPoint = CGPointMake(contentView.bounds.size.width * 0.5, contentView.bounds.size.height * 0.5);
    CGFloat radius = contentView.bounds.size.width * 0.5 * 0.6;
    CGFloat startAngle = 0;
    CGFloat endAngle = -M_PI * 3/2;
    CGFloat lineWidth = 3;

    [progressHUD.loadingLayer removeFromSuperlayer];
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:layerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.strokeColor = [UIColor redColor].CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.path = circle.CGPath;
    circleLayer.frame = contentView.bounds;
    [contentView.layer addSublayer:circleLayer];

    progressHUD.contentView = contentView;
    progressHUD.loadingLayer = circleLayer;

    progressHUD.messageLabel.hidden = YES;
    
    
    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
    if (window) {
        [window addSubview:progressHUD];
        [progressHUD beginLoadAnimation];
    }
}


#pragma mark -- getters and setters
- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 3.0;
    }
    return _contentView;
}



@end
