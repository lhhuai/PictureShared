//
//  PSDefines.h
//  PictureShared
//
//  Created by seaphy on 7/16/15.
//  Copyright (c) 2015 seaphy. All rights reserved.
//

#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

// iPhone 屏幕宽度
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)

// iPhone 屏幕高度
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)

// iPhone 屏幕尺寸
#define PHONE_SCREEN_SIZE (CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - PHONE_STATUSBAR_HEIGHT))

// iPhone statusbar 高度
#define PHONE_STATUSBAR_HEIGHT      20

// iPhone 默认导航条高度
#define PHONE_NAVIGATIONBAR_HEIGHT  44

// iPhone 默认TabBar高度
#define PHONE_TABBAR_HEIGHT        49

// 此项目中普通UIViewController的view的高度
#define VIEW_HEIGHT     (SCREEN_HEIGHT - PHONE_NAVIGATIONBAR_HEIGHT - PHONE_STATUSBAR_HEIGHT - PHONE_TABBAR_HEIGHT)
