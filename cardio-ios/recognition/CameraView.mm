//
//  CameraView.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "CameraView.h"

@interface CameraView ()

@property(nonatomic, strong, readwrite) VideoStream *videoStream;

@end

@implementation CameraView

- (instancetype)initWithFrame:(CGRect)frame {
    [NSException raise:@"Wrong initializer" format:@"Designated initializer is initWithFrame:delegate:"];
    return nil;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<VideoStreamDelegate>)delegate {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        self.delegate = delegate;
        
        self.videoStream = [[VideoStream alloc] init];
        self.videoStream.delegate = self;
        self.videoStream.previewLayer.needsDisplayOnBoundsChange = YES;
        self.videoStream.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
        self.videoStream.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [self.layer addSublayer:self.videoStream.previewLayer];
        
        if ([self.videoStream hasAutoFocus]) {
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus)];
            [self addGestureRecognizer:tapRecognizer];
        }
    }
    
    return self;
}

# pragma mark - Stream session control

- (void)startVideoStreamSession {
    [self.videoStream startSession];
}

- (void)stopVideoStreamSession {
    [self.videoStream stopSession];
}

- (void)focus {
    [self.videoStream focus];
}

# pragma mark - VideoStreamDelegate methods

- (void)videoStream:(VideoStream *)stream didProcessFrame:(VideoFrame *)frame {
    [self.delegate videoStream:stream didProcessFrame:frame];
}

@end
