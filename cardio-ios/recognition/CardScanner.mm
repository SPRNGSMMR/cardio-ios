//
//  CardScanner.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 12/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "CardScanner.h"
#import "CardInfo.h"
#import "IplImageUtils.h"

//#import "scan/scan.h"

#include "opencv2/imgproc/imgproc_c.h"

@interface CardScanner ()

// intentionally atomic -- card scanners get passed around between threads
//@property(assign, readwrite) ScannerState scannerState;
@property(strong, readwrite) CardInfo *cardInfoCache;

@property(assign, readwrite) BOOL cardInfoCacheDirty;
@property(assign, readwrite) BOOL lastFrameWasUsable;
@property(assign, readwrite) BOOL lastFrameWasUpsideDown;
@property(assign, readwrite) BOOL isScanComplete;

@end

@implementation CardScanner

- (id)init {
    self = [super init];
    
    if (self) {
//        scanner_initialize(&_scannerState);
        
        [self marksCachesDirty];
    }
    
    return self;
}

- (void)dealloc {
//    scanner_destroy(&_scannerState);
}

- (void)addFrame:(IplImageUtils *)frame focusScore:(float)focusScore brightnessScore:(float)brightnessScore isoSpeed:(NSInteger)isoSpeed shutterSpeed:(float)shutterSpeed {
//    if (self.isScanComplete) {
//        return;
//    }
//    
//    FrameScanResult result;
//    
//    result.focus_score = focusScore;
//    result.brightness_score = brightnessScore;
//    result.iso_speed = (uint16_t)isoSpeed;
//    result.shutter_speed = shutterSpeed;
//    result.torch_is_on = NO;
//    result.flipped = NO;
//    
//    BOOL scanExpiry = NO;
//    
//    scanner_add_frame_with_expiry(&_scannerState, frame.image, scanExpiry, &result);
//    
//    self.lastFrameWasUsable = result.usable;
//    
//    [self marksCachesDirty];
}

- (CardInfo *)cardInfo {
    return nil;
    //    if (self.isScanComplete) {
//        return self.cardInfoCache;
//    }
//    
//    if (!self.cardInfoCacheDirty) {
//        return nil;
//    }
//    
//    if (self.cardInfoCacheDirty) {
//        ScannerResult result;
//        
//        scanner_result(&_scannerState, &result);
//        
//        if (result.complete) {
//            NSString *cardNumbers = nil;
//            NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:result.n_numbers];
//            
//            self.isScanComplete = YES;
//            
//            for (uint8_t i=0; i<result.n_numbers; i++) {
//                NSNumber *predictionNumber = [NSNumber numberWithInt:(int)result.predictions(i)];
//                
//                [numbers addObject:predictionNumber];
//            }
//            
//            cardNumbers = [numbers componentsJoinedByString:@""];
//            
//            self.cardInfoCache = [CardInfo cardInfoWithNumbers:cardNumbers];
//        } else {
//            self.cardInfoCacheDirty = NO;
//        }
//    }
//    
    return self.cardInfoCache;
}

- (void)marksCachesDirty {
    self.cardInfoCacheDirty = YES;
}

- (BOOL)complete {
    return (self.cardInfo != nil);
}

@end
