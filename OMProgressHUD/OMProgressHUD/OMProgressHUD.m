//
//  TMSProgressHUD.m
//  TiMaSuperApp
//
//  Created by 印聪 on 2017/6/29.
//  Copyright © 2017年 tima. All rights reserved.
//

#import "OMProgressHUD.h"

#import "OMProgressConfig.h"

static OMProgressHUD *defaultView = nil;
@interface OMProgressHUD()<CAAnimationDelegate>

@property (nonatomic , strong)UIView *contentView;
@property (nonatomic , strong)UILabel *loadingTextLabel;

//进度效果
@property (nonatomic , strong)CAShapeLayer *loadingLayer;
@property (nonatomic , strong)UILabel *messageLabel;

//菊花效果
@property (nonatomic , strong)UIImageView *loadingImageView;


@property (nonatomic , strong)NSArray <UIView *>*ballViewsArray;
@property (nonatomic , strong)NSArray <NSValue *>*ballViewPositionsArray;
@property (nonatomic , strong)UIView *currentMoveBallView;
@property (nonatomic , strong)UIView *currentBeatBallView;

@property (nonatomic , assign)NSInteger ballCount;
@property (nonatomic , assign)CGFloat duration;

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

- (void)beginLoadAnimation:(CALayer *)animationLayer{
    //动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = [OMProgressConfig sharedInstance].loadingRate;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = ULLONG_MAX;
    [animationLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)endLoadAnimation{
    [self.loadingLayer removeAllAnimations];
    [self.loadingImageView.layer removeAllAnimations];
}

#pragma mark -- public method
+ (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
        [progressHUD showLoading];
    });
}

+ (void)dismiss{
    
    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
    if (progressHUD) {
        progressHUD.messageLabel.text = nil;
        [progressHUD endLoadAnimation];
        [progressHUD removeFromSuperview];
        
        if (progressHUD.messageLabel) {
            [progressHUD.messageLabel removeFromSuperview];
        }
        
//        if (progressHUD.ballViewsArray.count > 0) {
//            for (UIView *view in progressHUD.ballViewsArray) {
//                [view removeFromSuperview];
//            }
//            
//            progressHUD.ballViewsArray = nil;
//            progressHUD.ballViewPositionsArray = nil;
//        }
    }
}


/**
 显示文本消息

 @param message 消息文本
 */
+ (void)show:(NSString *)message{
    
    [OMProgressHUD dismiss];
    
    if ([OMProgressHUD defaultView].messageLabel && [[OMProgressHUD defaultView].messageLabel.text isEqualToString:message]) {
        return;
    }
    
    
    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
    if (window) {
        
        if ([OMProgressHUD defaultView].contentView) {
            [[OMProgressHUD defaultView].contentView removeFromSuperview];
        }
        
        if ([OMProgressHUD defaultView].messageLabel) {
            [[OMProgressHUD defaultView].messageLabel removeFromSuperview];
        }
        
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [OMProgressConfig sharedInstance].font;
        label.backgroundColor = [OMProgressConfig sharedInstance].textContentColor;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = [OMProgressConfig sharedInstance].textCornerRadius;
        label.text = message;
        UIEdgeInsets textEdgeInsets = [OMProgressConfig sharedInstance].textEdgeInsets;
        CGFloat textMaxW = [UIScreen mainScreen].bounds.size.width - 20 - textEdgeInsets.left - textEdgeInsets.right;
        CGSize size = [message sizeWithAttributes:@{NSFontAttributeName:label.font}];
        size = CGSizeMake(size.width + textEdgeInsets.left + textEdgeInsets.right, size.height + textEdgeInsets.top + textEdgeInsets.bottom);
        if (size.width > textMaxW) {
            //最大高度为屏幕高度减去下边距(label距离屏幕底部)高度(40)，再减去上边距高度(40)
            CGFloat maxH = [UIScreen mainScreen].bounds.size.height - [OMProgressConfig sharedInstance].tailSpacing * 2;
            CGRect rect = [message boundingRectWithSize:CGSizeMake(textMaxW, maxH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];
            size = CGSizeMake(textMaxW, rect.size.height + textEdgeInsets.top + textEdgeInsets.bottom);
        }
        if ([OMProgressConfig sharedInstance].position == OMProgressHudTextPositionBottom) {
            label.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width) * 0.5, [UIScreen mainScreen].bounds.size.height - [OMProgressConfig sharedInstance].tailSpacing - size.height, size.width, size.height);
        }
        if ([OMProgressConfig sharedInstance].position == OMProgressHudTextPositionTop) {
            label.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width) * 0.5, [OMProgressConfig sharedInstance].tailSpacing, size.width, size.height);
        }
        if ([OMProgressConfig sharedInstance].position == OMProgressHudTextPositionMiddle) {
            label.bounds = CGRectMake(0, 0, size.width, size.height);
            label.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        }
        
        [window addSubview:label];
        
        [OMProgressHUD defaultView].messageLabel = label;
        
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(dismissInfo:) userInfo:label repeats:NO];
        
    }
}


//+ (void)showMoveBall{
//
//    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
//    progressHUD.frame = [UIScreen mainScreen].bounds;
//    progressHUD.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
//    progressHUD.duration = 2.0;
//    progressHUD.ballCount = 5;
//    if (progressHUD.loadingLayer) {
//        [progressHUD.loadingLayer removeFromSuperlayer];
//    }
//
//
//
//    UIView *contentView = progressHUD.contentView;
//    contentView.backgroundColor = [UIColor whiteColor];
//    contentView.layer.masksToBounds = YES;
//    contentView.layer.cornerRadius = 3.0f;
//    contentView.center = CGPointMake(progressHUD.bounds.size.width * 0.5, progressHUD.bounds.size.height * 0.5);
//    contentView.hidden = NO;
//    [progressHUD addSubview:contentView];
//
//
//    NSInteger ballCount = progressHUD.ballCount;
//    CGFloat ballWidth = 15;
//    CGFloat interBallSpace = 15;
//    CGFloat ballContentW = ballWidth * ballCount + interBallSpace  * (ballCount - 1);
//    contentView.bounds = CGRectMake(0, 0, ballContentW + 40 * 2, 100);
//    CGFloat firstBallX = (contentView.bounds.size.width  - ballContentW) * 0.5;
//
//    NSMutableArray *tmpBallViewMArray = [[NSMutableArray alloc] init];
//    NSMutableArray *tmpBallPositionMArray = [[NSMutableArray alloc] init];
//    for (NSInteger index = 0; index < ballCount; index++) {
//
//
//        UIView *ballView = [[UIView alloc] init];
//        ballView.backgroundColor = [UIColor colorWithRed:217/255.0 green:73/255.0 blue:127/255.0 alpha:1.0];
//        ballView.frame = CGRectMake(firstBallX + (ballWidth + interBallSpace) * index, contentView.bounds.size.height * 0.5 - ballWidth * 0.5, ballWidth, ballWidth);
//        ballView.layer.masksToBounds = YES;
//        ballView.layer.cornerRadius = ballWidth * 0.5;
//        ballView.tag = index;
//        [contentView addSubview:ballView];
//
//        if (index == 0) {
//            progressHUD.currentMoveBallView = ballView;
//        }
//
//        [tmpBallViewMArray addObject:ballView];
//        [tmpBallPositionMArray addObject:[NSValue valueWithCGPoint:ballView.center]];
//
//    }
//    progressHUD.ballViewsArray = tmpBallViewMArray.copy;
//    progressHUD.ballViewPositionsArray = tmpBallPositionMArray.copy;
//
//    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
//    if (window) {
//        [window addSubview:progressHUD];
//        if (progressHUD.currentMoveBallView) {
//            [progressHUD setMoveAnimation:YES];
//        }
//    }
//
//}
//
//- (void)setMoveAnimation:(BOOL)moveRight{
//
//    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
//    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    //在动画设置一些变量
//    pathAnimation.calculationMode = kCAAnimationPaced;
//    //我们希望动画持续
//    //如果我们动画从左到右的东西——我们想要呆在新位置,
//    //然后我们需要这些参数
//    pathAnimation.fillMode = kCAFillModeForwards;
//    pathAnimation.removedOnCompletion = NO;
//    pathAnimation.duration = progressHUD.duration;//完成动画的时间
//    //让循环连续演示
//    pathAnimation.repeatCount = 1;
//    pathAnimation.delegate = self;
//
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    if (moveRight) {
//        [path moveToPoint:[progressHUD.ballViewPositionsArray.firstObject CGPointValue]];
//        [path addLineToPoint:[progressHUD.ballViewPositionsArray.lastObject CGPointValue]];
//    }else{
//        [path moveToPoint:[progressHUD.ballViewPositionsArray.lastObject CGPointValue]];
//        [path addLineToPoint:[progressHUD.ballViewPositionsArray.firstObject CGPointValue]];
//    }
//    pathAnimation.path = path.CGPath;
//    NSString *key = moveRight?@"RightMoveAnimation":@"LeftMoveAnimation";
//    [pathAnimation setValue:key forKey:@"AnimationKey"];
//    [progressHUD.currentMoveBallView.layer addAnimation:pathAnimation forKey:key];
//}
//
//
//- (void)setBeatAnimation:(BOOL)moveRight{
//
//    UIView *view = self.currentBeatBallView;
//    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
//    CGFloat radius = ([progressHUD.ballViewPositionsArray[1] CGPointValue].x - [progressHUD.ballViewPositionsArray[0] CGPointValue].x) * 0.5;
//    CGPoint center = CGPointMake([progressHUD.ballViewPositionsArray[view.tag] CGPointValue].x - radius, [progressHUD.ballViewPositionsArray[0] CGPointValue].y);
//
//    //贝塞尔曲线路径
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    CGPoint startPoint = [progressHUD.ballViewPositionsArray[view.tag] CGPointValue];
//    CGPoint endPoint = [progressHUD.ballViewPositionsArray[view.tag - 1] CGPointValue];
//    if (!moveRight) {
//        CGPoint tmpPoint = startPoint;
//        startPoint = endPoint;
//        endPoint = tmpPoint;
//    }
//    [path moveToPoint:startPoint];
//    [path addQuadCurveToPoint:endPoint controlPoint:CGPointMake(center.x, center.y - radius - 30)];
//
//    //圆弧路径
////    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:moveRight?0:-M_PI endAngle:moveRight?-M_PI:0 clockwise:!moveRight];
//    //球往右滚动时，小球往左跳动，反之往右跳动
//    NSString *key = moveRight?@"LeftBeatAnimation":@"RightBeatAnimation";
//    if (moveRight) {
//        [progressHUD setBeatAnimationForView:view path:path animationKey:key];
//    }else{
//        [progressHUD setBeatAnimationForView:view path:path animationKey:key];
//    }
//
//
//}
//
//- (void)setBeatAnimationForView:(UIView *)view path:(UIBezierPath *)path animationKey:(NSString *)key{
//
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    //在动画设置一些变量
//    animation.calculationMode = kCAAnimationPaced;
//    //我们希望动画持续
//    //如果我们动画从左到右的东西——我们想要呆在新位置,
//    //然后我们需要这些参数
//    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = NO;
//    CGFloat duration = self.duration/([OMProgressHUD defaultView].ballCount - 1);
//    animation.duration = duration; //完成动画的时间
//    animation.repeatCount = 1;
//    animation.delegate = self;
//    animation.path = path.CGPath;
//    [animation setValue:key forKey:@"AnimationKey"];
//    [view.layer addAnimation:animation forKey:key];
//
//}




#pragma mark -- CAAnimationDelegate
//- (void)animationDidStart:(CAAnimation *)anim{
//    CAKeyframeAnimation *keyAnimation = (CAKeyframeAnimation *)anim;
//    if ([[keyAnimation valueForKey:@"AnimationKey"] isEqualToString:@"RightMoveAnimation"]) {
//        self.currentBeatBallView = [OMProgressHUD defaultView].ballViewsArray[1];
//        [self setBeatAnimation:YES];
//    }
//    if ([[keyAnimation valueForKey:@"AnimationKey"] isEqualToString:@"LeftMoveAnimation"]) {
//        self.currentBeatBallView = [OMProgressHUD defaultView].ballViewsArray.lastObject;
//        [self setBeatAnimation:NO];
//    }
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    
//    [self.currentMoveBallView.layer removeAnimationForKey:@"AnimationKey"];
//    [self.currentBeatBallView.layer removeAnimationForKey:@"AnimationKey"];
//    
//    if (flag) {
//        CAKeyframeAnimation *keyAnimation = (CAKeyframeAnimation *)anim;
//        if ([[keyAnimation valueForKey:@"AnimationKey"] isEqualToString:@"RightMoveAnimation"]) {
//            [self setMoveAnimation:NO];
//        }
//        if ([[keyAnimation valueForKey:@"AnimationKey"] isEqualToString:@"LeftMoveAnimation"]) {
//            
//            [self setMoveAnimation:YES];
//        }
//        
//        if ([[keyAnimation valueForKey:@"AnimationKey"] isEqualToString:@"LeftBeatAnimation"]) {
//            self.currentBeatBallView.center = [self.ballViewPositionsArray[self.currentBeatBallView.tag - 1] CGPointValue];
//            if (self.currentBeatBallView.tag < self.ballViewsArray.count - 1) {
//                self.currentBeatBallView = self.ballViewsArray[self.currentBeatBallView.tag + 1];
//                [self setBeatAnimation:YES];
//            }
//        }
//        
//        if ([[keyAnimation valueForKey:@"AnimationKey"] isEqualToString:@"RightBeatAnimation"]) {
//            self.currentBeatBallView.center = [self.ballViewPositionsArray[self.currentBeatBallView.tag] CGPointValue];
//            if (self.currentBeatBallView.tag > 1) {
//                self.currentBeatBallView = self.ballViewsArray[self.currentBeatBallView.tag - 1];
//                [self setBeatAnimation:NO];
//            }
//           
//        }
//        
//        
//    }
//}
//


#pragma mark -- private method
+ (void)dismissInfo:(NSTimer *)timer{
    
    UILabel *label = timer.userInfo;
    [label removeFromSuperview];
    if ([label.text isEqualToString:[OMProgressHUD defaultView].messageLabel.text]) {
        [OMProgressHUD defaultView].messageLabel = nil;
        [[OMProgressHUD defaultView] removeFromSuperview];
    }
    [timer invalidate];
    timer = nil;
}

//显示进度条loading
- (void)showLoading{
    
    [OMProgressHUD dismiss];
    
    OMProgressConfig *config = [OMProgressConfig sharedInstance];
    
    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
    progressHUD.frame = [UIScreen mainScreen].bounds;
    progressHUD.backgroundColor = config.loadingMaskColor;
    
    
    UIView *contentView = progressHUD.contentView;
    contentView.bounds = CGRectMake(0, 0, config.loadingContentSize.width, config.loadingContentSize.height);
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
    circleLayer.strokeColor = [UIColor colorWithRed:78/255.0 green:173/255.0 blue:222/255.0 alpha:1.0].CGColor;
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
        [progressHUD beginLoadAnimation:self.loadingLayer];
    }
}

+ (void)showImageLoading{
    OMProgressConfig *config = [OMProgressConfig sharedInstance];
    [OMProgressHUD showImageLoading:config.loadingText];
}

//系统默认的菊花loading效果
+ (void)showImageLoading:(NSString *)loadingText{
    
    [OMProgressHUD dismiss];
    
    OMProgressConfig *config = [OMProgressConfig sharedInstance];
    
    OMProgressHUD *progressHUD = [OMProgressHUD defaultView];
    progressHUD.frame = [UIScreen mainScreen].bounds;
    progressHUD.backgroundColor = config.loadingMaskColor;
    
    UIView *contentView = progressHUD.contentView;
    contentView.bounds = CGRectMake(0, 0, config.loadingContentSize.width, config.loadingContentSize.height);
    contentView.center = CGPointMake(progressHUD.bounds.size.width * 0.5, progressHUD.bounds.size.height * 0.5);
    contentView.hidden = NO;
    [progressHUD addSubview:contentView];
    
    UIImageView *loadingImageView = progressHUD.loadingImageView;
    UILabel *loadingTextLabel = progressHUD.loadingTextLabel;
    loadingTextLabel.text = loadingText;
    [contentView addSubview:loadingImageView];
    [contentView addSubview:loadingTextLabel];
    
    //加载文本高度
    UIEdgeInsets loadTextEdgeInsets = UIEdgeInsetsMake(0, 10, 20, 10);
    CGFloat loadingTextWidth = contentView.bounds.size.width - loadTextEdgeInsets.left - loadTextEdgeInsets.right;
    CGFloat loadingTextHeight = config.loadingTextFont.pointSize;
    if (loadingText.length > 0) {
        CGRect rect = [loadingText boundingRectWithSize:CGSizeMake(loadingTextWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:loadingTextLabel.font} context:nil];
        loadingTextHeight = rect.size.height;
    }
    
    //加载图片+图片与文本间距+文本高度
    CGFloat contentHeight = config.loadingImageSize.height + config.interLoadingImageTextSpacing + loadingTextHeight;
    if (contentHeight > contentView.bounds.size.height - 20 - loadTextEdgeInsets.bottom) {
        contentView.bounds = CGRectMake(0, 0, config.loadingContentSize.width, contentHeight + 20 + loadTextEdgeInsets.bottom);
    }
//    //加载图片+图片与文本间距+文本高度
//    CGFloat contentHeight = config.loadingImageSize.height + config.interLoadingImageTextSpacing + loadingTextHeight;
    //计算图片Y轴位置
    CGFloat loadingImageViewY = contentView.bounds.size.height * 0.5 - contentHeight * 0.5;
    loadingImageView.frame = CGRectMake(contentView.bounds.size.width * 0.5 - config.loadingImageSize.width * 0.5, loadingImageViewY, config.loadingImageSize.width, config.loadingImageSize.height);
    loadingTextLabel.frame = CGRectMake(loadTextEdgeInsets.left, CGRectGetMaxY(loadingImageView.frame) + config.interLoadingImageTextSpacing, loadingTextWidth, loadingTextHeight);

    
    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
    if (window) {
        [window addSubview:progressHUD];
        [progressHUD beginLoadAnimation:loadingImageView.layer];
    }
}


#pragma mark -- getters and setters
- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [OMProgressConfig sharedInstance].loadingContentColor;
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 3.0;
    }
    return _contentView;
}

- (UIImageView *)loadingImageView{
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.image = [OMProgressConfig sharedInstance].loadImage;
    }
    return _loadingImageView;
}

- (UILabel *)loadingTextLabel{
    if (_loadingTextLabel == nil) {
        OMProgressConfig *config = [OMProgressConfig sharedInstance];
        _loadingTextLabel = [[UILabel alloc] init];
        _loadingTextLabel.textColor = config.loadingTextColor;
        _loadingTextLabel.font = config.loadingTextFont;
        _loadingTextLabel.textAlignment = NSTextAlignmentCenter;
        _loadingTextLabel.numberOfLines = 0;
        [_loadingTextLabel sizeToFit];
    }
    return _loadingTextLabel;
}


@end
