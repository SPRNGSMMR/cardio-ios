//
//  VideoFrame.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "VideoFrame.h"

@interface VideoFrame ()

@property (nonatomic, assign, readwrite) CMSampleBufferRef buffer;

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
    
}

@end
