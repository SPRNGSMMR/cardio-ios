//
//  Utilities.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (BOOL)isCameraAvailable {
    return YES;
}

# pragma mark - Platform

+ (NSString *)getSystemInfoByName:(char *)infoSpecifier {
    size_t size;
    
    sysctlbyname(infoSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(infoSpecifier, answer, &size, NULL, 0);
    
    NSString *result = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    
    free(answer);
    
    return result;
}

+ (NSString *)getPlatformName {
    return [self getSystemInfoByName:"hw.machine"];
}

+ (BOOL)is3GS {
    return [[self getPlatformName] hasPrefix:@"iPhone2"];
}

+ (BOOL)shouldSetPixelFormat {
    // The 3GS chokes when you set the pixel format!?
    // Fortunately, the default is the one we want anyway.
    return ![self is3GS];
}

@end
