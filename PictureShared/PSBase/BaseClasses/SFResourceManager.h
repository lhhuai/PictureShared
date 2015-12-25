//
//  SFResourceManager.h
//  SFBestIphone
//  Created by hou zhenyong on 13-12-9.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SFResourceManager : NSObject{
    NSDictionary* _colorAndFontInfoDic; // color和font
    NSCache *_imageCache;
}

@property (nonatomic, strong) NSBundle *skinInfoBundle;
@property (nonatomic, strong) NSBundle *skinCommonBundle;
@property (nonatomic, strong) NSDictionary *colorAndFontInfoDic;

+ (SFResourceManager*)sharedInstance;

- (UIImage *)imageForKey:(NSString*)key;

/** plist里面字体属性的相关格式
 *
 <dict>
    <key>name</key>
        <string>STHeitiSC-Medium</string>
    <key>rgb</key>
        <string>255,255,255,1.0</string>
    <key>shadow</key>
        <string>0,-1</string>
    <key>shadow_rgb</key>
        <string>0,0,0,0.4</string>
    <key>size</key>
        <string>20</string>
 </dict>
 */
/**
 * 每次只获取一个属性
 */

- (UIFont *)fontForKey:(NSString *)key;
- (UIColor *)colorForKey:(NSString *)key;

- (void)clearImageCache;

@end
