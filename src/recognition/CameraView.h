//
//  CameraView.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoStream.h"

@interface CameraView : UIView<VideoStreamDelegate>

- (id)initWithFrame:(CGRect)frame delegate:(id<VideoStreamDelegate>)delegate;

- (void)startVideoStreamSession;
- (void)stopVideoStreamSession;

@property(nonatomic, weak, readwrite) id<VideoStreamDelegate>delegate;

@end
