//
//  CardScanner.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 12/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "scan.h"

@class CardInfo;
@class CardIOIplImage;

@interface CardScanner : NSObject

- (void)addFrame:(CardIOIplImage *)frame focusScore:(float)focusScore brightnessScore:(float)brightnessScore isoSpeed:(NSInteger)isoSpeed shutterSpeed:(float)shutterSpeed;
- (BOOL)complete;

// these properties are intentionally (superstitiously, anyhow) atomic -- card scanners get passed around between threads
@property(strong, readonly) CardInfo *cardInfo;

@end
