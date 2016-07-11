//
//  VideoStream.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoFrame.h"

@protocol VideoStreamDelegate;

@interface VideoStream : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

- (BOOL)hasAutoFocus;

- (void)focus;

- (void)startSession;
- (void)stopSession;

@property(nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic, weak, readwrite) id<VideoStreamDelegate> delegate;

@end

@protocol VideoStreamDelegate <NSObject>

@required
- (void)videoStream:(VideoStream *)stream didProcessFrame:(VideoFrame *)frame;

@end
