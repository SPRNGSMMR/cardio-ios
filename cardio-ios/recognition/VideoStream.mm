//
//  VideoStream.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "VideoStream.h"
#import "CardScanner.h"
#import "VideoFrame.h"
#import "Utilities.h"

@interface VideoStream () {
    dmz_context *dmz;
}

@property(nonatomic, strong, readwrite) CardScanner *scanner;

@property(nonatomic, strong, readwrite) AVCaptureSession *captureSession;
@property(nonatomic, strong, readwrite) AVCaptureDevice *camera;
@property(nonatomic, strong, readwrite) AVCaptureDeviceInput *cameraInput;
@property(nonatomic, strong, readwrite) AVCaptureVideoDataOutput *videoOutput;

@property(nonatomic, assign, readwrite) BOOL isRunning;
@property(nonatomic, assign, readwrite) BOOL isAdjustingFocus;

// This semaphore is intended to prevent a crash which was recorded with this exception message:
// "AVCaptureSession can't stopRunning between calls to beginConfiguration / commitConfiguration"
@property(nonatomic, strong, readwrite) dispatch_semaphore_t cameraConfigurationSemaphore;

@end

@implementation VideoStream

- (id)init {
    self = [super init];
    
    if (self) {
        self.captureSession = [[AVCaptureSession alloc] init];
        self.camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.scanner = [[CardScanner alloc] init];
        
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        
        self.cameraConfigurationSemaphore = dispatch_semaphore_create(1);
        
        dmz = dmz_context_create();
    }
    
    return self;
}

- (void)dealloc {
    [self stopSession];
}

#pragma mark - Session

// Consistent with <https://devforums.apple.com/message/887783#887783>, under iOS 7 it
// appears that our captureSession's input and output linger in memory even after the
// captureSession itself is dealloc'ed, unless we explicitly call removeInput: and
// removeOutput:.
//
// Moreover, it can be a long time from when we are fully released until we are finally dealloc'ed.
//
// The result is that if a user triggers a series of camera sessions, especially without long pauses
// in between, we start clogging up memory with our cameraInput and videoOutput objects.
//
// So I've now moved the creation and adding of input and output objects from [self init] to
// [self startSession]. And in [self stopSession] I'm now removing those objects.
// This seems to have solved the problem (for now, anyways).

- (BOOL)addInputAndOutput {
    NSError *sessionError = nil;
    
    self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&sessionError];
    
    if (sessionError || !self.cameraInput) {
        NSLog(@"Camera input error: %@", sessionError);
        return NO;
    }
    
    [self.captureSession addInput:self.cameraInput];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];

    if ([Utilities shouldSetPixelFormat]) {
        NSDictionary *outputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
        
        [self.videoOutput setVideoSettings:outputSettings];
    }
    
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // NB: DO NOT USE minFrameDuration. minFrameDuration causes focusing to
    // slow down dramatically, which causes significant ux pain.
    dispatch_queue_t queue = dispatch_queue_create("io.card.ios.videostream", NULL);
    [self.videoOutput setSampleBufferDelegate:self queue:queue];
    
    [self.captureSession addOutput:self.videoOutput];
    
    return YES;
}

- (void)removeInputAndOutput {
    [self.captureSession removeInput:self.cameraInput];
    [self.videoOutput setSampleBufferDelegate:nil queue:NULL];
    [self.captureSession removeOutput:self.videoOutput];
}

- (BOOL)changeCameraConfiguration:(void(^)())changeBlock {
    dispatch_semaphore_wait(self.cameraConfigurationSemaphore, DISPATCH_TIME_FOREVER);
    
    BOOL success = NO;
    
    NSError *lockError = nil;
    
    [self.captureSession beginConfiguration];
    [self.camera lockForConfiguration:&lockError];
    
    if (!lockError) {
        changeBlock();
        
        [self.camera unlockForConfiguration];
        
        success = YES;
    }
    
    [self.captureSession commitConfiguration];
    
    dispatch_semaphore_signal(self.cameraConfigurationSemaphore);
    
    return success;
}

- (void)startSession {
    if ([self addInputAndOutput]) {
        [self.camera addObserver:self forKeyPath:@"adjustingFocus" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:nil];
        [self.camera addObserver:self forKeyPath:@"adjustingExposure" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:nil];
        
        [self.captureSession startRunning];
        
        [self changeCameraConfiguration:^{
            if ([self.camera respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)]) {
                if (self.camera.autoFocusRangeRestrictionSupported) {
                    self.camera.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
                }
            }
            
            if ([self.camera respondsToSelector:@selector(isFocusPointOfInterestSupported)]) {
                if (self.camera.focusPointOfInterestSupported) {
                    self.camera.focusPointOfInterest = CGPointMake(0.5, 0.5);
                }
            }
        }];
        
        self.isRunning = YES;
    }
}

- (void)stopSession {
    if (self.isRunning) {
        [self changeCameraConfiguration:^{
            if ([self.camera respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)]) {
                if (self.camera.autoFocusRangeRestrictionSupported) {
                    self.camera.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNone;
                }
            }
        }];
        
        dispatch_semaphore_wait(self.cameraConfigurationSemaphore, DISPATCH_TIME_FOREVER);
        
        [self.camera removeObserver:self forKeyPath:@"adjustingFocus"];
        [self.camera removeObserver:self forKeyPath:@"adjustingExposure"];
        
        [self.captureSession stopRunning];
        
        [self removeInputAndOutput];
        
        self.isRunning = NO;
    }
}

- (void)sendFrameToDelegate:(VideoFrame *)frame {
    if (self.isRunning) {
        [self.delegate videoStream:self didProcessFrame:frame];
    }
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        self.isAdjustingFocus = [change[NSKeyValueChangeNewKey] boolValue];
    } else if ([keyPath isEqualToString:@"adjustingExposure"]) {
        self.isAdjustingFocus = [change[NSKeyValueChangeNewKey] boolValue];
    }
}

#pragma mark - Focus

- (BOOL)hasAutoFocus {
    return [self.camera isFocusModeSupported:AVCaptureFocusModeAutoFocus];
}

- (void)focus {
    [self autoFocusOnce];
    [self performSelector:@selector(resumeContinuousAutoFocusing) withObject:nil afterDelay:0.1f];
}

- (void)autoFocusOnce {
    [self changeCameraConfiguration:^{
        if ([self hasAutoFocus]) {
            [self.camera setFocusMode:AVCaptureFocusModeAutoFocus];
        }
    }];
}

- (void)resumeContinuousAutoFocusing {
    [self changeCameraConfiguration:^{
        if ([self.camera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.camera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
    }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        VideoFrame *frame = [[VideoFrame alloc] initWithSampleBuffer:sampleBuffer];
        
        frame.dmz = dmz;
        frame.scanner = self.scanner;
        
        if (self.isRunning) {
            NSDictionary *exifDict = (__bridge NSDictionary *)((CFDictionaryRef)CMGetAttachment(sampleBuffer, (CFStringRef)@"{Exif}", NULL));
            
            if (exifDict != nil) {
                frame.isoSpeed = [exifDict[@"ISOSpeedRatings"][0] integerValue];
                frame.shutterSpeed = [exifDict[@"ShutterSpeedValue"] floatValue];
            } else {
                frame.isoSpeed = 10000;
                frame.shutterSpeed = 0;
            }
            
            [frame process];
        }
        
        [self performSelectorOnMainThread:@selector(sendFrameToDelegate:) withObject:frame waitUntilDone:NO];
    }
}

@end
