//
//  MGCaptureControlView.m
//  MGCaptureControlView
//
//  Created by MemetGhini on 2018/6/12.
//  Copyright © 2018 MemetGhini. All rights reserved.
//

#import "MGCaptureControlView.h"

#define MG_IN_OUT_RATIO 3.0/4.0
#define MG_IN_BORDER_WIDTH 2.0
#define MG_MAX_CAPTURE_TIME 6.0
#define MG_MINIMUM_PRESS_DURATION 0.15
#define MG_OUTSIDE_VIEW_MAX_SCALE 3.0/2.0
#define MG_INSIDE_VIEW_MIN_SCALE 3.0/4.0
#define MG_PROGRESS_WIDTH 5.0
#define MG_COLOR(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define MG_BUTTON_ANIMATION 0.4
#define MG_MINIMUM_CAPTURE_TIME 0.7
#define MG_PROGRESS_UPDATE_TIME 0.05
#define MG_ADD_PER_UNIT MG_PROGRESS_UPDATE_TIME/MG_MAX_CAPTURE_TIME
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

@interface MGCaptureControlView()
{
    BOOL _isRunning;
    CAShapeLayer *_progressLayer;
    NSTimer *_pressTimer;
    NSTimer *_endTimer;
    CGFloat _pressedTime;
    UILongPressGestureRecognizer *_pressGesture;
}
@property (nonatomic,strong) UIView *outsideView;
@property (nonatomic,strong) UIButton *insideView;

@end

@implementation MGCaptureControlView

- (instancetype)initWithFrame:(CGRect)frame inOutRatio:(CGFloat)inOutRatio {
    self = [self initWithFrame:frame];
    if (self) {
        if (inOutRatio>1) {
            self.insideOutsideRatio = 1.0;
        } else if (inOutRatio<0) {
            self.insideOutsideRatio = 0.0;
        } else {
            self.insideOutsideRatio = inOutRatio;
        }
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commenInit];
    }
    return self;
}

- (void)commenInit {
    self.backgroundColor = [UIColor clearColor];
    [self setDefaultValue];
    [self createUI];
    [self prepareShapeLayer];
}

- (void)setDefaultValue {
    self.insideOutsideRatio = MG_IN_OUT_RATIO;
    self.progressPosition = MGProgressPositionMiddle;
    self.outColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.outBorderColor = [UIColor clearColor];
    self.outBorderWidth = MG_IN_BORDER_WIDTH;
    self.inBorderWidth = MG_IN_BORDER_WIDTH;
    self.inBorderColor = [UIColor clearColor];
    self.inColor = [UIColor whiteColor];
    self.progressColor = MG_COLOR(129, 234, 122, 1);
    self.outMaxScale = MG_OUTSIDE_VIEW_MAX_SCALE;
    self.inMinScale = MG_INSIDE_VIEW_MIN_SCALE;
    self.progressWidth = MG_PROGRESS_WIDTH;
    self.validCaptureTime = MG_MINIMUM_CAPTURE_TIME;
}

- (void)createUI {
    //outside view
    _outsideView = [[UIView alloc] initWithFrame:self.bounds];
    _outsideView.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2.0;
    _outsideView.backgroundColor = _outColor;
    _outsideView.layer.borderWidth = _outBorderWidth;
    _outsideView.layer.borderColor = _outBorderColor.CGColor;
    [self addSubview:_outsideView];
    //inside view
    CGFloat insideWidth = CGRectGetWidth(_outsideView.frame)*_insideOutsideRatio;
    CGFloat insideHeight = CGRectGetHeight(_outsideView.frame)*_insideOutsideRatio;
    _insideView = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-insideWidth)/2.0, (CGRectGetHeight(self.frame)-insideHeight)/2.0, insideWidth, insideHeight)];
    _insideView.backgroundColor = self.inColor;
    _insideView.layer.cornerRadius = MIN(_insideView.frame.size.width, _insideView.frame.size.height)/2.0;
    _insideView.layer.borderWidth = _inBorderWidth;
    _insideView.layer.borderColor = _inBorderColor.CGColor;
    [_insideView addTarget:self action:@selector(insideButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_insideView];
    //pressGesture for capturing
    _pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    _pressGesture.minimumPressDuration = MG_MINIMUM_PRESS_DURATION;
    [_insideView addGestureRecognizer:_pressGesture];
}

-(void)prepareShapeLayer{
    //Create CAShapeLayer
    CGFloat shapeLayerWidth = CGRectGetWidth(self.frame)*_outMaxScale;
    CGFloat shapeLayerHeight = CGRectGetHeight(self.frame)*_outMaxScale;
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = CGRectMake(0, 0, shapeLayerWidth, shapeLayerHeight);
    _progressLayer.position = _insideView.center;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 0.0);
    _progressLayer.lineWidth = _progressWidth*_outMaxScale;
    _progressLayer.strokeColor = self.progressColor.CGColor;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    //Create BezierPath
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_progressLayer.bounds cornerRadius:MIN(shapeLayerWidth, shapeLayerHeight)/2];
    circlePath.lineCapStyle = kCGLineCapRound;
    //CAShapeLayer Path
    _progressLayer.path = circlePath.CGPath;
}

#pragma mark - Setter

- (void)setInsideOutsideRatio:(CGFloat)insideOutsideRatio {
    _insideOutsideRatio = insideOutsideRatio;
    CGFloat insideWidth = CGRectGetWidth(_outsideView.frame)*_insideOutsideRatio;
    CGFloat insideHeight = CGRectGetHeight(_outsideView.frame)*_insideOutsideRatio;
    _insideView.frame = CGRectMake((CGRectGetWidth(self.frame)-insideWidth)/2.0, (CGRectGetHeight(self.frame)-insideHeight)/2.0, insideWidth, insideHeight);
    _insideView.layer.cornerRadius = MIN(_insideView.frame.size.width, _insideView.frame.size.height)/2.0;
}

- (void)setOutColor:(UIColor *)outColor {
    _outColor = outColor;
    self.outsideView.backgroundColor = _outColor;
}

- (void)setInColor:(UIColor *)inColor {
    _inColor = inColor;
    self.insideView.backgroundColor = _inColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    if (_progressLayer) {
        _progressLayer.strokeColor = _progressColor.CGColor;
    }
}

- (void)setInBorderWidth:(CGFloat)inBorderWidth {
    _inBorderWidth = inBorderWidth;
    _insideView.layer.borderWidth = _inBorderWidth;
}

- (void)setInBorderColor:(UIColor *)inBorderColor {
    _inBorderColor = inBorderColor;
    _insideView.layer.borderColor = _inBorderColor.CGColor;
}

- (void)setOutBorderColor:(UIColor *)outBorderColor {
    _outBorderColor = outBorderColor;
    _outsideView.layer.borderColor = _outBorderColor.CGColor;
}

- (void)setOutBorderWidth:(CGFloat)outBorderWidth {
    _outBorderWidth = outBorderWidth;
    _outsideView.layer.borderWidth = _outBorderWidth;
}

- (void)setOutMaxScale:(CGFloat)outMaxScale {
    _outMaxScale = outMaxScale;
    CGFloat shapeLayerWidth = CGRectGetWidth(self.frame)*_outMaxScale;
    CGFloat shapeLayerHeight = CGRectGetHeight(self.frame)*_outMaxScale;
    _progressLayer.frame = CGRectMake(0, 0, shapeLayerWidth, shapeLayerHeight);
    _progressLayer.position = _insideView.center;
    //Create BezierPath
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_progressLayer.bounds cornerRadius:MIN(shapeLayerWidth, shapeLayerHeight)/2];
    circlePath.lineCapStyle = kCGLineCapRound;
    //CAShapeLayer Path
    _progressLayer.path = circlePath.CGPath;
}

- (void)setInMinScale:(CGFloat)inMinScale {
    _inMinScale = inMinScale;
}

- (void)setProgressWidth:(CGFloat )progressWidth {
    _progressWidth = progressWidth;
    if (_progressLayer) {
        _progressLayer.lineWidth = _progressWidth*_outMaxScale;
    }
}

- (void)setProgressPosition:(MGProgressPosition)progressPosition {
    _progressPosition = progressPosition;
    CGFloat shapeLayerWidth = CGRectGetWidth(self.frame)*_outMaxScale;
    CGFloat shapeLayerHeight = CGRectGetHeight(self.frame)*_outMaxScale;
    if (_progressPosition == MGProgressPositionOut) {
        shapeLayerWidth += _progressWidth*_outMaxScale;
        shapeLayerHeight += _progressWidth*_outMaxScale;
    }else if (_progressPosition == MGProgressPositionIn) {
        shapeLayerWidth -= _progressWidth*_outMaxScale;
        shapeLayerHeight -= _progressWidth*_outMaxScale;
    }
    _progressLayer.frame = CGRectMake(0, 0, shapeLayerWidth, shapeLayerHeight);
    _progressLayer.position = _insideView.center;
    //Create BezierPath
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:_progressLayer.bounds cornerRadius:MIN(shapeLayerWidth, shapeLayerHeight)/2];
    circlePath.lineCapStyle = kCGLineCapRound;
    //CAShapeLayer Path
    _progressLayer.path = circlePath.CGPath;
}

#pragma mark - Others

-(void)longPressGestureRecognizer:(UILongPressGestureRecognizer*)gesture{
    @WeakObj(self)
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(mg_captureControlViewDidTouched)]) {
            [self.delegate mg_captureControlViewDidTouched];
        }
        [UIView animateWithDuration:MG_BUTTON_ANIMATION animations:^{
            selfWeak.outsideView.transform = CGAffineTransformScale(selfWeak.outsideView.transform, selfWeak.outMaxScale, selfWeak.outMaxScale);
            selfWeak.insideView.transform = CGAffineTransformScale(selfWeak.insideView.transform, selfWeak.inMinScale, selfWeak.inMinScale);
        }];
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:MG_PROGRESS_UPDATE_TIME target:self selector:@selector(calculatePressedTime) userInfo:nil repeats:YES];
        _endTimer = [NSTimer scheduledTimerWithTimeInterval:MG_BUTTON_ANIMATION+MG_MAX_CAPTURE_TIME target:self selector:@selector(captureShouldEnd) userInfo:nil repeats:YES];
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        [self resetToDefaultState];
        //If it is too short, click Cancel
        if (_pressedTime<=MG_BUTTON_ANIMATION+_validCaptureTime) {
            _isRunning = NO;
            if ([self.delegate respondsToSelector:@selector(mg_captureControlViewStateDidChangeTo:)]) {
                [self.delegate mg_captureControlViewStateDidChangeTo:MGCaptureStateCancel];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(mg_captureControlViewStateDidChangeTo:)]) {
                [self.delegate mg_captureControlViewStateDidChangeTo:MGCaptureStateEnd];
            }
        }
        [self invalidatePressTimer];
    }else if (gesture.state == UIGestureRecognizerStateCancelled) {
        //In order to avoid the animation is not finished
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetToDefaultState];
        });
    }
}

- (void)resetToDefaultState {
    @WeakObj(self)
    if (_isRunning) {
        [_progressLayer removeFromSuperlayer];
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
    }
    _isRunning = NO;
    [UIView animateWithDuration:MG_BUTTON_ANIMATION animations:^{
        selfWeak.outsideView.transform = CGAffineTransformScale(selfWeak.outsideView.transform, 1.0/selfWeak.outMaxScale, 1.0/selfWeak.outMaxScale);
        selfWeak.insideView.transform = CGAffineTransformScale(selfWeak.insideView.transform, 1.0/selfWeak.inMinScale, 1.0/selfWeak.inMinScale);
    }];
    _pressGesture.enabled = YES;
}

-(void)invalidatePressTimer{
    if (_pressTimer) {
        [_pressTimer invalidate];
        _pressTimer = nil;
    }
    if (_endTimer) {
        [_endTimer invalidate];
        _endTimer = nil;
    }
    _pressedTime = 0.0;
}

-(void)calculatePressedTime{
    _pressedTime += MG_PROGRESS_UPDATE_TIME;
    //Draw progress circel
    if (_pressedTime>MG_BUTTON_ANIMATION) {
        if (!_isRunning) {
            _isRunning = YES;
            //Add shapeLayer
            if (_progressLayer) {
                [self.layer addSublayer:_progressLayer];
            }
            //Notice start capturing
            if ([self.delegate respondsToSelector:@selector(mg_captureControlViewStateDidChangeTo:)]) {
                [self.delegate mg_captureControlViewStateDidChangeTo:MGCaptureStateBegin];
            }
        }
        [self drawCircleWithAnimation];
    }
}

- (void)captureShouldEnd {
    //Notice end capturing
    if ([self.delegate respondsToSelector:@selector(mg_captureControlViewStateDidChangeTo:)]) {
        [self.delegate mg_captureControlViewStateDidChangeTo:MGCaptureStateEnd];
    }
    _pressGesture.enabled = NO;
    [self invalidatePressTimer];
}

- (void)drawCircleWithAnimation{
    _progressLayer.strokeEnd += MG_ADD_PER_UNIT;
}

#pragma mark - Oprations

- (void)insideButtonDidClicked:(UIButton*)button {
    if ([self.delegate respondsToSelector:@selector(mg_captureControlViewDidClicked)]) {
        [self.delegate mg_captureControlViewDidClicked];
    }
}

@end
