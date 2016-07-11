//
//  VideoFrame.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

#import "dmz.h"

@interface VideoFrame : NSObject

- (id)initWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)process;

@property(assign) dmz_context *dmz;

@end
