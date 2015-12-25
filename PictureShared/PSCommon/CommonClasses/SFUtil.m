//
//  SFUtil.m
//  SFBestIphone
//
//  Created by jcx on 14-3-19.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import "SFUtil.h"
//#import "SFGoodsDetailViewController.h"
//#import "SFGoodsListViewController.h"
//#import "SFBrowserPageViewController.h"
//#import "SFRegionParser.h"
//#import "SFMotionShakeViewController.h"
//#import "SFActivityNMViewController.h"
//#import "MobClick.h"
//#import "SFAppDelegate.h"
//#import "SFOriginPlaceStraightHairListViewController.h"
//#import "SFGlobalCateViewController.h"
//#import "SFGoodsCommonListViewController.h"
//#import "SFSnapUpProductViewController.h"

#define MB_FILE_SIZE 1024*1024

@implementation SFUtil

//// 根据资源信息跳转画面
//+ (UIViewController *)switchViewCtrlWithResource:(SFHomeResourceInfo *)resourceInfo
//{
//    if (nil == resourceInfo) {
//        return nil;
//    }
//    
//    /** 资源类型. 0: 无; 1:商品;2:关键字;3:分类;4:品牌;5:专题 6:URL 7:N元M件 8:摇一摇 9:全部分类  10:产地直供 11:全球美食 12:手机专享 13:精品推荐 14:限时抢购  */
//    switch (resourceInfo.resourceType)
//    {
//        case 0:
//            return nil;
//            // 1:商品
//        case 1:
//        {
//            if (nil == resourceInfo.resourceCommonID || [resourceInfo.resourceCommonID isEqualToString:@""]) {
//                return nil;
//            }
//            SFGoodsDetailViewController *goodDetailView = [[SFGoodsDetailViewController alloc]init];
//            goodDetailView.productID = [resourceInfo.resourceCommonID intValue];
//            return goodDetailView;
//        }
//            // 2:关键字
//        case 2:
//        {
//            if (nil == resourceInfo.resourceCommonID || [resourceInfo.resourceCommonID isEqualToString:@""]) {
//                return nil;
//            }
//            SFGoodsListViewController *keywordView = [[SFGoodsListViewController alloc]init];
//            keywordView.keyword = resourceInfo.resourceCommonID;
//            return keywordView;
//        }
//            // 3:分类
//        case 3:{
//            if (nil == resourceInfo.resourceCommonID || [resourceInfo.resourceCommonID isEqualToString:@""]) {
//                return nil;
//            }
//            SFGoodsListViewController *categoryView = [[SFGoodsListViewController alloc]init];
//            categoryView.categoryID = [resourceInfo.resourceCommonID intValue];
//            return categoryView;
//        }
//            // 4:品牌
//        case 4:
//        {
//            if (nil == resourceInfo.resourceCommonID || [resourceInfo.resourceCommonID isEqualToString:@""]) {
//                return nil;
//            }
//            SFGoodsListViewController *brandView = [[SFGoodsListViewController alloc]init];
//            brandView.brandID = [resourceInfo.resourceCommonID intValue];
//            return brandView;
//        }
//            // 5:专题
//        case 5:
//        {
//            if (nil == resourceInfo) {
//                return nil;
//            }
//            if (nil == resourceInfo.resourceSpecialURL || [resourceInfo.resourceSpecialURL isEqualToString:@""]) {
//                return nil;
//            }
//            NSString *picUrl = nil;
//            // 1:静态专题
//            if (resourceInfo.resourceSpecialType == 1) {
//                picUrl = resourceInfo.resourceSpecialURL;
//            }
//            // 2: 动态专题: 服务端只给页面路径 客户端自己拼参数部分，参数需要三个 1是设备标识 2是专题ID 3是地址ID
//            else {
//                SFRegion *region = [[SFRegionParser sharedInstance] loadLastRegion];
//                NSString *address = [NSString stringWithFormat:@"-%d-%d-%d",region.provID,region.cityID,region.distID];
//                NSString *iphoneMark = @"2";
//                picUrl = [NSString stringWithFormat:@"%@%@-%@%@.html",resourceInfo.resourceSpecialURL,iphoneMark, resourceInfo.resourceCommonID, address];
//            }
//            SFBrowserPageViewController *browserView = [[SFBrowserPageViewController alloc]initWithtitle:resourceInfo.resourceSpecialName linkURL:picUrl];
//            return browserView;
//        }
//         // 6:URL
//        case 6:
//        {
//            NSString *linkURL = resourceInfo.resourceCommonID;
//            if (![linkURL hasPrefix:@"http"])
//            {
//                linkURL = [NSString stringWithFormat:@"http://%@", linkURL];
//            }
//            SFBrowserPageViewController *browserView = [[SFBrowserPageViewController alloc]initWithtitle:resourceInfo.resourceSpecialName linkURL:linkURL];
//            return browserView;
//        }
//          // 7:N元M件
//        case 7:
//        {
//            SFActivityNMViewController *vc = [SFActivityNMViewController new];
//            vc.actID = [resourceInfo.resourceCommonID integerValue];
//            return vc;
//        }
//           // 8:摇一摇
//        case 8:
//        {
//            // 友盟事件统计-首页_摇优惠模块点击量
//            [MobClick event:@"A007"];
//            SFMotionShakeViewController *motionShakeVC = [[SFMotionShakeViewController alloc] init];
//            motionShakeVC.commonID = resourceInfo.resourceCommonID;
//            return motionShakeVC;
//        }
//            // 10:产地直供
//        case 10:
//        {
//            // 友盟事件统计-首页产地直供模块点击量
//            [MobClick event:@"A005"];
//            SFOriginPlaceStraightHairListViewController *originPlaceStraightHairView = [[SFOriginPlaceStraightHairListViewController alloc]init];
//            return originPlaceStraightHairView;
//        }
//            // 11:全球美食
//        case 11:
//        {
//            // 友盟事件统计-首页_全球美食模块点击量
//            [MobClick event:@"A006"];
//            SFGlobalCateViewController *globalCateCtrl = [[SFGlobalCateViewController alloc] init];
//            SfbestAppEntitiesGlobalFoodRequest *globalFoodRequest = [[SfbestAppEntitiesGlobalFoodRequest alloc]init];
//            globalFoodRequest.Country = 0;
//            globalFoodRequest.ContinentId = 0;
//            // 选择地区
//            SFRegion *region = [[SFRegionParser sharedInstance] lastRegion];
//            globalFoodRequest.Province = region.provID;
//            globalFoodRequest.City = region.cityID;
//            globalFoodRequest.District = region.distID;
//            globalFoodRequest.Area = region.areaID;
//            globalCateCtrl.globalFoodRequest = globalFoodRequest;
//            return globalCateCtrl;
//        }
//            // 12:手机专享
//        case 12:
//        {
//            // 友盟事件统计-首页精品推荐模块点击量
//            [MobClick event:@"A009"];
//            SFGoodsCommonListViewController *goodCommonCtrl = [[SFGoodsCommonListViewController alloc] init];
//            goodCommonCtrl.type = SFGoodsListTypeProductRecomment;
//            return goodCommonCtrl;
//        }
//            // 13:精品推荐
//        case 13:
//        {
//            // 友盟事件统计-首页精品推荐模块点击量
//            [MobClick event:@"A009"];
//            SFGoodsCommonListViewController *goodCommonCtrl = [[SFGoodsCommonListViewController alloc] init];
//            goodCommonCtrl.type = SFGoodsListTypeProductRecomment;
//            return goodCommonCtrl;
//        }
//            // 14:限时抢购
//        case 14:
//        {
//           // 友盟事件统计-首页限时抢购模块点击量
//            [MobClick event:@"A008"];
//            SFSnapUpProductViewController *snapUpViewCtrl = [[SFSnapUpProductViewController alloc]init];
//            return snapUpViewCtrl;
//        }
//    }
//    return nil;
//}

+ (NSString *)CalculateScale:(NSString *)picUrl imageView:(UIImageView *)imageView {
    if (nil == picUrl || [picUrl isEqualToString:@""]) {
        return picUrl;
    }
    NSString *url = [NSString stringWithFormat:@"%@",picUrl];
    NSString *last = [NSString stringWithFormat:@".jpg"];
    NSRange range = [picUrl rangeOfString:last];
    if (range.length <= 0) {
        last = [NSString stringWithFormat:@".JPG"];
    }
    range = [picUrl rangeOfString:last];
    if (range.length <= 0) {
        last = [NSString stringWithFormat:@".png"];
    }
    range = [picUrl rangeOfString:last];
    if (range.length <= 0) {
        last = [NSString stringWithFormat:@".PNG"];
    }
    if (range.length > 0) {
        url = [picUrl substringToIndex:range.location];
        int imgWidth = imageView.frame.size.width * 2;
        int imgHeight = imageView.frame.size.height * 2;
        url = [NSString stringWithFormat:@"%@/%dx%d%@", url,imgWidth, imgHeight,last];
    }

    return url;
}

+ (NSString *)CalculateScale:(NSString *)picUrl size:(CGSize)size {
    if (nil == picUrl || [picUrl isEqualToString:@""]) {
        return picUrl;
    }
    NSString *url = [NSString stringWithFormat:@"%@",picUrl];
    NSString *last = [NSString stringWithFormat:@".jpg"];
    NSRange range = [picUrl rangeOfString:last];
    if (range.length <= 0) {
        last = [NSString stringWithFormat:@".JPG"];
    }
    range = [picUrl rangeOfString:last];
    if (range.length <= 0) {
        last = [NSString stringWithFormat:@".png"];
    }
    range = [picUrl rangeOfString:last];
    if (range.length <= 0) {
        last = [NSString stringWithFormat:@".PNG"];
    }
    if (range.length > 0) {
        url = [picUrl substringToIndex:range.location];
        int imgWidth = size.width * 2;
        int imgHeight = size.height * 2;
        url = [NSString stringWithFormat:@"%@/%dx%d%@", url,imgWidth, imgHeight,last];
    }
    
    return url;
}

@end
