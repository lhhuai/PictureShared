//
//  UIButton+block.h
//  SFBestIphone
//
//  Created by SFBest on 14-2-17.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (block)

- (void)handlEvent:(UIControlEvents)controlEvents withBlock:(void(^)())block;

@end
