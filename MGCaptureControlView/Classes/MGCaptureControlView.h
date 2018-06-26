//
//  MGCaptureControlView.h
//  MGCaptureControlView
//
//  Created by MemetGhini on 2018/6/12.
//  Copyright © 2018 MemetGhini. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Indicates capture status.
 */
typedef enum : NSUInteger {
    MGCaptureStateBegin,
    MGCaptureStateCancel,
    MGCaptureStateEnd,
} MGCaptureState;

/**
 Indicates where the circular progress bar is to be displayed.
 */
typedef enum : NSUInteger {
    MGProgressPositionOut,
    MGProgressPositionMiddle,
    MGProgressPositionIn,
} MGProgressPosition;


@protocol MGCaptureControlViewDelegate<NSObject>
@optional
/**
 Mainly used to feedback changes in recording status.
 Currently Support Start, Cancel, End statuses.
 */
- (void)mg_captureControlViewStateDidChangeTo:(MGCaptureState)state;

/**
 Mainly used to feedback capture button click.
 */
- (void)mg_captureControlViewDidClicked;

/**
 Mainly used to feedback user touch on capture view.
 NOTE: this method will be called every time user touch the view by pressing.
 */
- (void)mg_captureControlViewDidTouched;
@end

IB_DESIGNABLE

@interface MGCaptureControlView : UIView
/**
 ProgressView customization properties.
*/
@property (nonatomic, strong)IBInspectable UIColor *progressColor;
@property (nonatomic, strong)IBInspectable UIColor *progressFillInColor;
@property (nonatomic, assign)IBInspectable CGFloat progressWidth;
/**
 Outside view customization properties.
 */
@property (nonatomic, strong)IBInspectable UIColor *outColor;
@property (nonatomic, strong)IBInspectable UIColor *outBorderColor;
@property (nonatomic, assign)IBInspectable CGFloat outBorderWidth;
@property (nonatomic, assign)IBInspectable CGFloat outMaxScale;
/**
 Inside view customization properties.
 */
@property (nonatomic, strong)IBInspectable UIColor *inColor;
@property (nonatomic, strong)IBInspectable UIColor *inBorderColor;
@property (nonatomic, assign)IBInspectable CGFloat inBorderWidth;
@property (nonatomic, assign)IBInspectable CGFloat inMinScale;
/**
 Outside view and outside view default size ratio.
 */
@property (nonatomic, assign)IBInspectable CGFloat insideOutsideRatio;
/**
 Progress circle position.
 */
@property (nonatomic, assign) MGProgressPosition progressPosition;
/**
 Minimum capture time for video record, if recorded time is less then valid capture time capturation will be cancled.
 */
@property (nonatomic, assign) IBInspectable CGFloat validCaptureTime;
/**
 Maximum capture time for video record, if recorded time is more then VideoLength capturation will be ended. Default value is 10 second.
 */
@property (nonatomic, assign) IBInspectable CGFloat videoLength;

@property (nonatomic,weak) id<MGCaptureControlViewDelegate> delegate;

/**
 Default instantiation method with MGProgressPositionMiddle for progress circel positon and 1 for ratio.
 @param frame view frame .
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 Instantiation method with custom progress circel positon and inside outside view size ratio.
 @param frame view frame .
 @param inOutRatio inside outside view size ratio.
 */
- (instancetype)initWithFrame:(CGRect)frame inOutRatio:(CGFloat)inOutRatio;

@end
