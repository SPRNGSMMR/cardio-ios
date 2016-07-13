//
//  Utilities.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/sysctl.h>

@interface Utilities : NSObject

+ (BOOL)isCameraAvailable;

+ (NSString *)getSystemInfoByName:(char *)infoSpecifier;
+ (NSString *)getPlatformName;

+ (BOOL)is3GS;

+ (BOOL)shouldSetPixelFormat;

@end
