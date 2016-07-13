//
//  VideoFrame.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "VideoFrame.h"
#import "CardIOIplImage.h"
#import "CardScanner.h"

#define kMinFallbackFocusScore 6

@interface VideoFrame ()

@property(nonatomic, assign, readwrite) CMSampleBufferRef buffer;

@property(nonatomic, strong, readwrite) CardIOIplImage *ySample;
@property(nonatomic, strong, readwrite) CardIOIplImage *cbSample;
@property(nonatomic, strong, readwrite) CardIOIplImage *crSample;

@property(nonatomic, assign, readwrite) float focusScore;
@property(nonatomic, assign, readwrite) dmz_edges found_edges;
@property(nonatomic, assign, readwrite) dmz_corner_points corner_points;

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
    
    self.ySample = [CardIOIplImage imageFromYCbCrBuffer:imageBuffer plane:0];
    
    self.focusScore = dmz_focus_score(self.ySample.image, NO);
    
    if (self.focusScore > kMinFallbackFocusScore) {
        NSArray *samples = [[CardIOIplImage imageFromYCbCrBuffer:imageBuffer plane:1] split];
        
        self.cbSample = samples[0];
        self.crSample = samples[1];
        
        [self detectCard];
    }
    
    // Release address
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)detectCard {
    bool foundCard = dmz_detect_edges(self.ySample.image, self.cbSample.image, self.crSample.image, FrameOrientationPortrait, &_found_edges, &_corner_points);
    
    if (foundCard) {
        IplImage *foundCardY = NULL;
        
        dmz_transform_card(self.dmz, self.ySample.image, self.corner_points, FrameOrientationPortrait, false, &foundCardY);
        
        if ((foundCardY != NULL) && (foundCardY->nSize == sizeof(IplImage))) {
            CardIOIplImage *cardY = [CardIOIplImage imageWithIplImage:foundCardY];
            
            [self.scanner addFrame:cardY focusScore:self.focusScore brightnessScore:0.0f isoSpeed:0 shutterSpeed:0.0f];
            
            if (self.scanner.complete) {
                self.cardInfo = self.scanner.cardInfo;
            }
        }
    }
}

@end
