//
//  MGViewController.m
//  MGCaptureControlView
//
//  Created by memetghini@qq.com on 06/13/2018.
//  Copyright (c) 2018 memetghini@qq.com. All rights reserved.
//

#import "MGViewController.h"
#import <MGCaptureControlView/MGCaptureControlView.h>

@interface MGViewController ()<MGCaptureControlViewDelegate>

@end

@implementation MGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	//Demo
    MGCaptureControlView *captureControlView = [[MGCaptureControlView alloc] initWithFrame:CGRectMake(100, 400, 80, 80)];
    captureControlView.delegate = self;
    [self.view addSubview:captureControlView];
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
