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
{
    NSString *_titleString;
}
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
    //imageView
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    if ([_titleString isEqualToString:@"Custom"]) {
        imageView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT-167);
    }else{
        imageView.frame = self.view.bounds;
    }
    
    imageView.image = [UIImage imageNamed:@"capture"];
    [self.view addSubview:imageView];
    //button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(30, DEVICE_HEIGHT-100, 40, 40);
    if ([_titleString isEqualToString:@"Custom"]) {
        [closeBtn setImage:[UIImage imageNamed:@"close_black"] forState:UIControlStateNormal];
    }else{
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    }
    [closeBtn addTarget:self action:@selector(closeDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    //Demo
    MGCaptureControlView *captureControlView = nil;
    if ([_titleString isEqualToString:@"Custom"]) {
        captureControlView = [[MGCaptureControlView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-80)/2.0, DEVICE_HEIGHT-80-40, 80, 80) inOutRatio:8.0/10.0];
    }else{
        captureControlView = [[MGCaptureControlView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-80)/2.0, DEVICE_HEIGHT-80-40, 80, 80)];
    }
    captureControlView.delegate = self;
    if ([_titleString isEqualToString:@"Wechat"]) {
        captureControlView.progressPosition = MGProgressPositionIn;
    }else if ([_titleString isEqualToString:@"QQ"]) {
        captureControlView.inColor = [UIColor clearColor];
        captureControlView.outColor = [UIColor clearColor];
        captureControlView.outBorderColor = [UIColor whiteColor];
        captureControlView.progressColor = COLOR(18, 174, 244, 1);
        captureControlView.progressWidth = 4.0;
        captureControlView.outBorderWidth = 4.0;
        captureControlView.progressWidth = 4.0;
        captureControlView.progressPosition = MGProgressPositionIn;
    }else{
        captureControlView.progressColor = COLOR(44, 212, 187, 1);
        captureControlView.outBorderWidth = 5;
        captureControlView.outBorderColor = COLOR(245, 245, 245, 1);
        captureControlView.outColor = [UIColor whiteColor];
        captureControlView.inColor = COLOR(44, 212, 187, 1);
        captureControlView.inBorderWidth = 0.0;
        captureControlView.progressPosition = MGProgressPositionIn;
    }
    [self.view addSubview:captureControlView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)closeDidClicked:(UIButton*)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)captureControlViewStateDidChangeTo:(MGCaptureState)state {
    if (state == MGCaptureStateBegin) {
        NSLog(@"Capturing started.");
    } else if (state == MGCaptureStateCancel) {
        NSLog(@"Capturing canceled.");
    }else if (state == MGCaptureStateEnd) {
        NSLog(@"Capturing ended.");
    }
}

- (void)captureControlViewDidClicked {
    NSLog(@"Capture button did clicked.");
}

@end
