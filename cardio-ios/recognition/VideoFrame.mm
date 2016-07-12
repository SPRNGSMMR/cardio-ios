//
//  VideoFrame.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "VideoFrame.h"
#import "CardScanner.h"
#import "IplImageUtils.h"

#define kMinFallbackFocusScore 6

@interface VideoFrame ()

@property(nonatomic, assign, readwrite) CMSampleBufferRef buffer;

@property(nonatomic, assign, readwrite) float focusScore;
@property(nonatomic, strong, readwrite) IplImageUtils *ySample;

@property (nonatomic, assign, readwrite) dmz_edges found_edges;
@property (nonatomic, assign, readwrite) dmz_corner_points corner_points;

@end

@implementation VideoFrame

- (id)initWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    self = [super init];
    
    if (self) {
        _buffer = sampleBuffer;
        
        CFRetain(_buffer);
    }
    
    return self;
}

- (void)dealloc {
    CFRelease(_buffer);
}

- (void)process {
    cvSetErrMode(CV_ErrModeParent);
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(self.buffer);
    
    // Lock address
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    self.ySample = [IplImageUtils imageFromYCbCrBuffer:imageBuffer plane:0];
    
    self.focusScore = dmz_focus_score(self.ySample.image, NO);
    
    if (self.focusScore > kMinFallbackFocusScore) {
        NSArray *samples = [[IplImageUtils imageFromYCbCrBuffer:imageBuffer plane:0] split];
        
        [self detectCard:samples];
    }
    
    // Release address
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)detectCard:(NSArray<IplImageUtils *> *)samples {
    bool foundCard = dmz_detect_edges(self.ySample.image, [samples[0] image], [samples[1] image], FrameOrientationPortrait, &_found_edges, &_corner_points);
    
    if (foundCard) {
        IplImage *foundCardY = NULL;
        
        dmz_transform_card(self.dmz, self.ySample.image, self.corner_points, FrameOrientationPortrait, false, &foundCardY);
        
        if ((foundCardY != NULL) && (foundCardY->nSize == sizeof(IplImage))) {
            IplImageUtils *cardY = [IplImageUtils initWithIplImage:foundCardY];
            
            [self.scanner addFrame:cardY focusScore:self.focusScore brightnessScore:0.0f isoSpeed:0 shutterSpeed:0.0f];
            
            if (self.scanner.complete) {
                self.cardInfo = self.scanner.cardInfo;
            }
        }
    }
}

@end
