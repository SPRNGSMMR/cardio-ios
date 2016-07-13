//
//  CardInfo.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 12/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "CardInfo.h"

@interface CardInfo ()

@property(nonatomic, strong, readwrite) NSString *numbers;

@end

@implementation CardInfo

+ (CardInfo *)cardInfoWithNumbers:(NSString *)numbers {
    CardInfo *info = [[self alloc] init];
    
    info.numbers = numbers;
    
    return info;
}

- (NSString *)description {
    return self.numbers;
}

@end
