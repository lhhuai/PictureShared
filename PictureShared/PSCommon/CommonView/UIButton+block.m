//
//  UIButton+block.m
//  SFBestIphone
//
//  Created by SFBest on 14-2-17.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import "UIButton+block.h"
#import <objc/runtime.h>

const char *TOUCHUPINSIDE;//UIControlEventTouchUpInside

@implementation UIButton (block)

- (void)handlEvent:(UIControlEvents)controlEvents withBlock:(void(^)())block
{
//    UIControlEventTouchUpInside
//    const char *eventFlag = [[NSString stringWithFormat:@"UIBUTTONBLOCK%i", controlEvents] UTF8String];
    objc_setAssociatedObject(self, &TOUCHUPINSIDE, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(doTouchUpInside:) forControlEvents:controlEvents];
}

- (void)doTouchUpInside:(id)sender {
    void(^block)();
    block = objc_getAssociatedObject(self, &TOUCHUPINSIDE);
    if (block) {
        block();
    }
}
@end
