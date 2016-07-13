//
//  CardView.h
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardInfo;

@protocol CardViewDelegate;

@interface CardView : UIView

@property(nonatomic, weak, readwrite) id<CardViewDelegate> delegate;

@end

@protocol CardViewDelegate <NSObject>

@required
- (void)didScanCard:(CardInfo *)info;

@optional
- (void)didReceiveFocusScore:(CGFloat)score;

@end
