//
//  IplImageUtils.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/2016.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>

#include "opencv2/imgproc/imgproc_c.h"

@interface IplImageUtils : NSObject

+ (IplImageUtils *)imageFromYCbCrBuffer:(CVImageBufferRef)imageBuffer plane:(size_t)plane;
+ (IplImageUtils *)initWithIplImage:(IplImage *)image;

- (NSArray *)split;

@property(nonatomic, assign, readonly) IplImage *image;

@end
