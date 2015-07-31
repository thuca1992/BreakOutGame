//
//  Brick.m
//  BreakOutGame
//
//  Created by Nguyen Thanh Tung on 7/31/15.
//  Copyright (c) 2015 Nguyen Thanh Tung. All rights reserved.
//

#import "Brick.h"

@implementation Brick

@synthesize breakingTimesLeft;

- (instancetype) init: (UIView*) brickView and: (int) breakingTimesLeft {
    if (self = [super init]) {
        self.brickView = brickView;
        self.breakingTimesLeft = breakingTimesLeft;
    }
    return self;
}


@end
