//
//  CardView.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>

#import "CardView.h"
#import "CardScanner.h"
#import "CameraView.h"
#import "Utilities.h"
#import "VideoFrame.h"

@interface CardView () <VideoStreamDelegate>

@property(nonatomic, strong, readwrite) CameraView *cameraView;

@property(nonatomic, assign, readwrite) BOOL isSessionRunning;

@end

@implementation CardView

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.cameraView sizeThatFits:size];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.cameraView setFrame:self.bounds];
    [self.cameraView sizeToFit];
    [self.cameraView setCenter:CGPointMake(CGRectGetMidX(CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)), CGRectGetMidY(CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)))];
    
    [self.cameraView layoutIfNeeded];
}

#pragma mark - Potential disappearance

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stop];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (!newWindow) {
        [self stop];
    }
    
    [super willMoveToWindow:newWindow];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self start];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window) {
        [self start];
    }
}

#pragma mark - Controls

- (void)start {
    if (!self.isSessionRunning &&
        !self.hidden &&
        self.window &&
        self.superview) {
        if (![Utilities isCameraAvailable]) {
            return;
        }
    
        self.isSessionRunning = YES;
        
        self.cameraView = [[CameraView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) delegate:self];
        
        [self addSubview:self.cameraView];
        [self performSelector:@selector(startSession) withObject:nil afterDelay:0.0f];
    }
}

- (void)stop {
    if (self.isSessionRunning) {
        self.isSessionRunning = NO;
        
        [self stopSession];
        [self.cameraView removeFromSuperview];
        
        self.cameraView = nil; // destroy
    }
}

#pragma mark - Video controls

- (void)startSession {
    if (self.cameraView) {
        [self.cameraView startVideoStreamSession];
    }
}

- (void)stopSession {
    if (self.cameraView) {
        [self.cameraView stopVideoStreamSession];
    }
}


#pragma mark - Actions

- (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark - CardIOVideoStreamDelegate methods

- (void)videoStream:(VideoStream *)stream didProcessFrame:(VideoFrame *)frame {
    if ([self.delegate respondsToSelector:@selector(didReceiveFocusScore:)]) {
        [self.delegate didReceiveFocusScore:frame.focusScore];
    }
    
    if (frame.scanner.complete) {
        [self stopSession];
        [self vibrate];
        
        [self.delegate didScanCard:frame.scanner.cardInfo];
    }
}

@end
