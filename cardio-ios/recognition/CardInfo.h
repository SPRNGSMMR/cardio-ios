//
//  CardInfo.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 12/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardInfo : NSObject

+ (CardInfo *)cardInfoWithNumbers:(NSString *)numbers;

@property(nonatomic, strong, readonly) NSString *numbers;

@end
