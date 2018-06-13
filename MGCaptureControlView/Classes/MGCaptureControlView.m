//
//  MGCaptureControlView.m
//  buttonTest
//
//  Created by Memet on 2018/6/12.
//  Copyright © 2018 Memet. All rights reserved.
//

#import "MGCaptureControlView.h"

#define MG_IN_OUT_RATIO 3.0/4.0
#define MG_IN_BORDER_WIDTH 2.0
#define MG_MAX_CAPTURE_TIME 10.0
#define MG_MINIMUM_PRESS_DURATION 0.15
#define MG_OUTSIDE_VIEW_MAX_SCALE 3.0/2.0
#define MG_INSIDE_VIEW_MIN_SCALE 3.0/4.0
#define MG_PROGRESS_WIDTH 5.0
#define MG_COLOR(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define MG_BUTTON_ANIMATION 0.4
#define MG_MINIMUM_CAPTURE_TIME 0.7
#define MG_PROGRESS_UPDATE_TIME 0.05
#define MG_ADD_PER_SECOND MG_PROGRESS_UPDATE_TIME/MG_MAX_CAPTURE_TIME
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

@interface MGCaptureControlView()
{
    CAShapeLayer *_shapeLayer;
    BOOL isRunning;
    //拍摄相关
    CGFloat pressedTime;
    NSTimer *pressTimer;
    CGFloat _inOutRatio;
}
@property (nonatomic,strong) UIView *outsideView;
@property (nonatomic,strong) UIButton *insideView;
@property (nonatomic, assign) MGProgressPosition progressPosition;

@end

@implementation MGCaptureControlView

- (instancetype)initWithFrame:(CGRect)frame progressPosition:(MGProgressPosition)progressPosition inOutRatio:(CGFloat)inOutRatio {
    self = [self initWithFrame:frame];
    if (self) {
        if (inOutRatio>1) {
            _inOutRatio = 1.0;
        } else if (inOutRatio<0) {
            _inOutRatio = 0.0;
        } else {
            _inOutRatio = inOutRatio;
        }
        _progressPosition = progressPosition;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame progressPosition:(MGProgressPosition)progressPosition {
    self = [self initWithFrame:frame];
    if (self) {
        self.progressPosition = progressPosition;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commenInit];
    }
    return self;
}

- (void)commenInit {
    [self setDefaultValue];
    [self createUI];
    [self prepareShapeLayer];
}

- (void)setDefaultValue {
    self.insideOutsideRatio = MG_IN_OUT_RATIO;
    self.outColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.inBorderWidth = MG_IN_BORDER_WIDTH;
    self.inBorderColor = [UIColor clearColor];
    self.inColor = [UIColor whiteColor];
    self.progressColor = MG_COLOR(129, 234, 122, 1);
    self.outMaxScale = MG_OUTSIDE_VIEW_MAX_SCALE;
    self.inMinScale = MG_INSIDE_VIEW_MIN_SCALE;
    self.progressWidth = MG_PROGRESS_WIDTH;
}

- (void)createUI {
    //outside view
    _outsideView = [[UIView alloc] initWithFrame:self.bounds];
    _outsideView.layer.cornerRadius = self.bounds.size.width/2.0;
    _outsideView.backgroundColor = _outColor;
    [self addSubview:_outsideView];
    //inside view
    CGFloat insideWidth = CGRectGetWidth(_outsideView.frame)*_insideOutsideRatio;
    CGFloat insideHeight = CGRectGetHeight(_outsideView.frame)*_insideOutsideRatio;
    _insideView = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-insideWidth)/2.0, (CGRectGetHeight(self.frame)-insideHeight)/2.0, insideWidth, insideHeight)];
    _insideView.backgroundColor = self.inColor;
    _insideView.layer.cornerRadius = _insideView.frame.size.width/2.0;
    _insideView.layer.borderWidth = _inBorderWidth;
    _insideView.layer.borderColor = _inBorderColor.CGColor;
    [_insideView addTarget:self action:@selector(insideButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_insideView];
    //pressGesture for capturing
    UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    pressGesture.minimumPressDuration = MG_MINIMUM_PRESS_DURATION;
    [_insideView addGestureRecognizer:pressGesture];
}

-(void)prepareShapeLayer{
    //Create CAShapeLayer
    CGFloat shapeLayerWidth = CGRectGetWidth(self.frame)*_outMaxScale;
    CGFloat shapeLayerHeight = CGRectGetHeight(self.frame)*_outMaxScale;
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.frame = CGRectMake(0, 0, shapeLayerWidth, shapeLayerHeight);
    _shapeLayer.position = _insideView.center;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 0.0);
    _shapeLayer.lineWidth = _progressWidth;
    _shapeLayer.strokeColor = self.progressColor.CGColor;
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd = 0;
    //Create BezierPath
    //减掉顶部两个角
//    UIBezierPath *circlePath = [UIBezierPath
//                              bezierPathWithRoundedRect:_shapeLayer.bounds
//                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight)
//                              cornerRadii:CGSizeMake(shapeLayerWidth/2, shapeLayerHeight/2)
//                              ];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds cornerRadius:shapeLayerWidth/2];
    //+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius; // rounds all corners with the same horizontal and vertical radius
    //UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, _shapeLayer.frame.size.width, _shapeLayer.frame.size.height)];
    circlePath.lineCapStyle = kCGLineCapRound;
    //CAShapeLayer Path
    _shapeLayer.path = circlePath.CGPath;
}

#pragma mark - Setter

- (void)setOutColor:(UIColor *)outColor {
    _outColor = outColor;
    self.outsideView.backgroundColor = _outColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    if (_shapeLayer) {
        _shapeLayer.strokeColor = _progressColor.CGColor;
    }
}

- (void)setInBorderWidth:(CGFloat)inBorderWidth {
    _inBorderWidth = inBorderWidth;
    if (_shapeLayer) {
        _insideView.layer.borderWidth = _inBorderWidth;
    }
}

- (void)setInBorderColor:(UIColor *)inBorderColor {
    _inBorderColor = inBorderColor;
    if (_shapeLayer) {
        _insideView.layer.borderColor = _inBorderColor.CGColor;
    }
}

- (void)setOutMaxScale:(CGFloat)outMaxScale {
    _outMaxScale = outMaxScale;
}

- (void)setInMinScale:(CGFloat)inMinScale {
    _inMinScale = inMinScale;
}

- (void)setProgressWidth:(CGFloat )progressWidth {
    _progressWidth = progressWidth;
    if (_shapeLayer) {
        _shapeLayer.lineWidth = _progressWidth;
    }
}

-(void)longPressGestureRecognizer:(UILongPressGestureRecognizer*)gesture{
    @WeakObj(self)
    if (_shapeLayer) {
        [self.layer addSublayer:_shapeLayer];
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(captureControlViewStateDidChangeTo:)]) {
            [self.delegate captureControlViewStateDidChangeTo:MGCaptureStateBegin];
        }
        //开始放大
        [UIView animateWithDuration:MG_BUTTON_ANIMATION animations:^{
            selfWeak.outsideView.transform = CGAffineTransformScale(selfWeak.outsideView.transform, selfWeak.outMaxScale, selfWeak.outMaxScale);
            selfWeak.insideView.transform = CGAffineTransformScale(selfWeak.insideView.transform, selfWeak.inMinScale, selfWeak.inMinScale);
        }];
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:MG_PROGRESS_UPDATE_TIME target:self selector:@selector(calculatePressedTime) userInfo:nil repeats:YES];
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        //结束动画
        if (isRunning) {
            [_shapeLayer removeFromSuperlayer];
            _shapeLayer.strokeStart = 0;
            _shapeLayer.strokeEnd = 0;
        }
        isRunning = NO;
        
        [UIView animateWithDuration:MG_BUTTON_ANIMATION animations:^{
            selfWeak.outsideView.transform = CGAffineTransformScale(selfWeak.outsideView.transform, 1.0/selfWeak.outMaxScale, 1.0/selfWeak.outMaxScale);
            selfWeak.insideView.transform = CGAffineTransformScale(selfWeak.insideView.transform, 1.0/selfWeak.inMinScale, 1.0/selfWeak.inMinScale);
        }];
        //判断结束原因
        if (pressedTime<=MG_BUTTON_ANIMATION+MG_MINIMUM_CAPTURE_TIME) {
            isRunning = NO;
            if ([self.delegate respondsToSelector:@selector(captureControlViewStateDidChangeTo:)]) {
                [self.delegate captureControlViewStateDidChangeTo:MGCaptureStateCancel];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(captureControlViewStateDidChangeTo:)]) {
                [self.delegate captureControlViewStateDidChangeTo:MGCaptureStateEnd];
            }
        }
        [self invalidatePressTimer];
    }
}

-(void)invalidatePressTimer{
    [pressTimer invalidate];
    pressTimer = nil;
    pressedTime = 0.0;
}

-(void)calculatePressedTime{
    //记录点击时长
    pressedTime += MG_PROGRESS_UPDATE_TIME;
    //画圈圈
    if (pressedTime>MG_BUTTON_ANIMATION) {
        if (!isRunning) {
            isRunning = YES;
//            if ([self.delegate respondsToSelector:@selector(captureControlViewDidStartCapturing)]) {
//                [self.delegate captureControlViewDidStartCapturing];
//            }
        }
        [self drawCircleWithAnimation];
    }
    //停止拍摄
    if (pressedTime >= MG_MAX_CAPTURE_TIME+MG_BUTTON_ANIMATION) {
        [self invalidatePressTimer];
//        if ([self.delegate respondsToSelector:@selector(captureControlViewDidEndCapturing)]) {
//            [self.delegate captureControlViewDidEndCapturing];
//        }
    }
}

- (void)drawCircleWithAnimation{
    _shapeLayer.strokeEnd += MG_ADD_PER_SECOND;
}

#pragma mark - Oprations

- (void)insideButtonDidClicked:(UIButton*)button {
    NSLog(@"按钮被点击");
}

@end
