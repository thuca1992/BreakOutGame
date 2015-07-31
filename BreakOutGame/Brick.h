//
//  Brick.h
//  BreakOutGame
//
//  Created by Nguyen Thanh Tung on 7/31/15.
//  Copyright (c) 2015 Nguyen Thanh Tung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Brick : NSObject

@property (nonatomic, strong) UIView *brickView;
@property int breakingTimesLeft;

- (instancetype) init: (UIView*) brickView and: (int) breakingTimesLeft;

- (void)setBreakingTimesLeft: (int)value;
    
@end
