//
//  MGCaptureDemoViewController.m
//  MGCaptureControlView_Example
//
//  Created by Memet on 2018/6/13.
//  Copyright © 2018 memetghini@qq.com. All rights reserved.
//

#import "MGCaptureDemoViewController.h"
#import <MGCaptureControlView/MGCaptureControlView.h>

#define DEVICE_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define DEVICE_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define COLOR(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface MGCaptureDemoViewController ()<MGCaptureControlViewDelegate>
@property (nonatomic,strong) NSString *titleString;
@property (nonatomic,strong) UILabel *statusLabel;
@end

@implementation MGCaptureDemoViewController

- (instancetype)initWith:(NSString*)title {
    self = [super init];
    if (self) {
        _titleString = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)createUI {
    //imageView
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = [UIImage imageNamed:@"capture"];
    [self.view addSubview:imageView];
    //button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(30, DEVICE_HEIGHT-100, 40, 40);
    [closeBtn addTarget:self action:@selector(closeDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    //Demo
    MGCaptureControlView *captureControlView = nil;
    //adjustment
    if ([_titleString isEqualToString:@"Wechat"]) {
        imageView.frame = self.view.bounds;
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        captureControlView = [[MGCaptureControlView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-80)/2.0, DEVICE_HEIGHT-80-40, 80, 80)];
        captureControlView.progressPosition = MGProgressPositionIn;
    }else if ([_titleString isEqualToString:@"QQ"]) {
        imageView.frame = self.view.bounds;
        //
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        //
        captureControlView = [[MGCaptureControlView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-80)/2.0, DEVICE_HEIGHT-80-40, 80, 80)];
        captureControlView.inColor = [UIColor clearColor];
        captureControlView.outColor = [UIColor clearColor];
        captureControlView.outBorderColor = [UIColor whiteColor];
        captureControlView.progressColor = COLOR(18, 174, 244, 1);
        captureControlView.progressWidth = 4.0;
        captureControlView.outBorderWidth = 4.0;
        captureControlView.progressWidth = 4.0;
        captureControlView.progressPosition = MGProgressPositionIn;
    }else{
        imageView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-167);
        //
        [closeBtn setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
        //
        captureControlView = [[MGCaptureControlView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-80)/2.0, DEVICE_HEIGHT-80-40, 80, 80) inOutRatio:8.0/10.0];
        captureControlView.progressColor = COLOR(44, 212, 187, 1);
        captureControlView.outBorderWidth = 5;
        captureControlView.outBorderColor = COLOR(245, 245, 245, 1);
        captureControlView.outColor = [UIColor whiteColor];
        captureControlView.inColor = COLOR(44, 212, 187, 1);
        captureControlView.inBorderWidth = 0.0;
        captureControlView.progressPosition = MGProgressPositionIn;
    }
    captureControlView.validCaptureTime = 1.0;
    captureControlView.delegate = self;
    [self.view addSubview:captureControlView];
    //status
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, DEVICE_WIDTH, 44)];
    _statusLabel.backgroundColor = COLOR(0, 0, 0, 0.3);
    _statusLabel.text = @"Ready to Capture";
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightHeavy];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
}

- (void)closeDidClicked:(UIButton*)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MGCaptureControlViewDelegate

- (void)mg_captureControlViewStateDidChangeTo:(MGCaptureState)state {
    __weak typeof(self)weakSelf = self;
    if (state == MGCaptureStateBegin) {
        NSLog(@"Capturing started.");
        _statusLabel.text = @"Capturing started.";
    } else if (state == MGCaptureStateCancel) {
        NSLog(@"Capturing canceled.");
        _statusLabel.text = @"Capturing canceled.";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.statusLabel.text = @"";
        });
    }else if (state == MGCaptureStateEnd) {
        NSLog(@"Capturing ended.");
        _statusLabel.text = @"Capturing ended.";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.statusLabel.text = @"";
        });
    }
}

- (void)mg_captureControlViewDidClicked {
    __weak typeof(self)weakSelf = self;
    _statusLabel.text = @"Capture button did clicked.";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.statusLabel.text = @"";
    });
}

- (void)mg_captureControlViewDidTouched {
    NSLog(@"User did touch capture view");
}

@end
