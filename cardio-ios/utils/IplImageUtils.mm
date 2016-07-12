//
//  IplImageUtils.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/2016.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "IplImageUtils.h"

#import "dmz.h"

@interface IplImageUtils ()

@property(nonatomic, assign, readwrite) CVImageBufferRef imageBuffer;

@end

@implementation IplImageUtils

+ (IplImageUtils *)imageFromYCbCrBuffer:(CVImageBufferRef)imageBuffer plane:(size_t)plane {
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    char *address = (char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, plane);
    
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, plane);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, plane);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, plane);
    
    int numChannels = plane == 0 ? 1 : 2;
    
    IplImage *colocatedImage = cvCreateImageHeader(cvSize((int)width, (int)height), IPL_DEPTH_8U, numChannels);
    
    colocatedImage->imageData = address;
    colocatedImage->widthStep = (int)bytesPerRow;
    
    return [[self alloc] initWithIplImage:colocatedImage imageBuffer:imageBuffer];
}

+ (id)initWithIplImage:(IplImage *)image {
    return [[self alloc] initWithIplImage:image];
}

- (id)initWithIplImage:(IplImage *)image {
    return [self initWithIplImage:image imageBuffer:NULL];
}

- (id)initWithIplImage:(IplImage *)image imageBuffer:(CVImageBufferRef)imageBuffer {
    self = [super init];
    
    if (self) {
        _image = image;
        
        self.imageBuffer = imageBuffer;
        
        if (imageBuffer != NULL) {
            CFRetain(imageBuffer);
        }
    }
    
    return self;
}

- (NSArray *)split {
    if (self.image->nChannels == 1) {
        return [NSArray arrayWithObject:self];
    }
    
    assert(self.image->nChannels == 2);
    
    IplImage *channel1;
    IplImage *channel2;
    
    dmz_deinterleave_uint8_c2(self.image, &channel1, &channel2);
    
    IplImageUtils *image1 = [self initWithIplImage:channel1];
    IplImageUtils *image2 = [self initWithIplImage:channel2];
    
    return [NSArray arrayWithObjects:image1, image2, nil];
}

@end
