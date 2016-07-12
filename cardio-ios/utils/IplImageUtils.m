//
//  IplImageUtils.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/2016.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "IplImageUtils.h"

@implementation IplImageUtils

+ (IplImageUtils *)imageFromYCbCrBuffer:(CVImageBufferRef)imageBuffer plane:(size_t)plane {
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    char *address = (char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, plane);
    
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, plane);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, plane);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, plane);
    
    int numChannels = plane == 0 ? 1 : 2;
    
    Ipl
}

@end
