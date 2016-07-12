//
//  VideoFrame.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

#include "dmz.h"

@class CardInfo;
@class CardScanner;

@interface VideoFrame : NSObject

- (id)initWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)process;

@property(nonatomic, assign, readwrite) NSInteger isoSpeed;
@property(nonatomic, assign, readwrite) float shutterSpeed;

@property(nonatomic, strong, readwrite) CardInfo *cardInfo; // Will be nil unless frame processing completes with a successful scan
@property(nonatomic, strong, readwrite) CardScanner *scanner;

@property(assign) dmz_context *dmz;

@end
