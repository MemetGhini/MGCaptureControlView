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
- (void)captureControlViewStateDidChangeTo:(MGCaptureState)state;

/**
 Mainly used to feedback capture button click.
 */
- (void)captureControlViewDidClicked;
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

@property (nonatomic,weak) id<MGCaptureControlViewDelegate> delegate;

/**
 Default instantiation method with MGProgressPositionMiddle for progress circel positon and 1 for ratio.
 @param frame view frame .
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 Instantiation method with custom progress circel positon.
 @param frame view frame .
 @param progressPosition progress position support with MGProgressPosition enum.
 */
- (instancetype)initWithFrame:(CGRect)frame progressPosition:(MGProgressPosition)progressPosition;

/**
 Instantiation method with custom progress circel positon and inside outside view size ratio.
 @param frame view frame .
 @param progressPosition progress position support with MGProgressPosition enum.
 @param inOutRatio inside outside view size ratio.
 */
- (instancetype)initWithFrame:(CGRect)frame progressPosition:(MGProgressPosition)progressPosition inOutRatio:(CGFloat)inOutRatio;

@end
