//
//  CardScanner.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 12/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <Foundation/Foundation.h>

//#include "scan.h"

@class CardInfo;
@class IplImageUtils;

@interface CardScanner : NSObject

- (void)addFrame:(IplImageUtils *)frame focusScore:(float)focusScore brightnessScore:(float)brightnessScore isoSpeed:(NSInteger)isoSpeed shutterSpeed:(float)shutterSpeed;
- (BOOL)complete;

// these properties are intentionally (superstitiously, anyhow) atomic -- card scanners get passed around between threads
@property(strong, readonly) CardInfo *cardInfo;

@end
