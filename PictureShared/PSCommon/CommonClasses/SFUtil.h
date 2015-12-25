//
//  SFUtil.h
//  SFBestIphone
//
//  Created by jcx on 14-3-19.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "SFCmsAndContinentBean.h"
//#import "SFBaseViewController.h"

@interface SFUtil : NSObject

// 根据资源信息跳转画面
//+ (UIViewController *)switchViewCtrlWithResource:(SFHomeResourceInfo *)resourceInfo;

+ (NSString *)CalculateScale:(NSString *)picUrl imageView:(UIImageView *)imageView;
+ (NSString *)CalculateScale:(NSString *)picUrl size:(CGSize)size;

@end
