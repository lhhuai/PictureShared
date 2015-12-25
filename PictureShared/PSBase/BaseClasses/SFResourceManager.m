//
//  SFResourceManager.m
//  SFBestIphone
//  Created by hou zhenyong on 13-12-9.

#import "SFResourceManager.h"

//定义bundle里面的plist文件名
#define COLOR_AND_FONT    @"color_font"
#define SKINTYPE_COMMON  @"/skin_common.bundle"

// 从plist取字体相关属性所用的宏
#define kFontName @"name"
#define kFontSize @"size"
#define kFontColor @"rgb"
#define kShadowOffSet @"shadow"
#define kShadowColor @"shadow_rgb"

@interface SFResourceManager(Private)


@end

@implementation SFResourceManager

static inline UIColor *colorWithHexString(NSString *hexString)
{
    unsigned long colorValue = strtoul([hexString UTF8String], 0, 16);
    UIColor *color = [UIColor colorWithRed:((float)((colorValue & 0xFF0000) >> 16))/255.0
                                     green:((float)((colorValue & 0xFF00) >> 8))/255.0 \
                                      blue:((float)(colorValue & 0xFF))/255.0 alpha:1.0];
    return color;
}

static SFResourceManager* _instance = nil;

+ (SFResourceManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SFResourceManager alloc] init];
    });
    return _instance;
}

- (id)init{
    self = [super init];
    if (self) {
        _imageCache = [[NSCache alloc] init];
        [_imageCache setCountLimit:0];
        [_imageCache setTotalCostLimit:0];
        [self readSkinInfo];
    }
    return self;
}

- (void)readSkinInfo {
    NSString *skinCommonPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:SKINTYPE_COMMON];
    NSBundle *skinCommonBundle = [[NSBundle alloc] initWithPath:skinCommonPath];
    self.skinCommonBundle = skinCommonBundle;

    NSString *plistPath = [self.skinCommonBundle pathForResource:COLOR_AND_FONT ofType:@"plist"];
    NSDictionary *tmpColorAndFontDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    self.colorAndFontInfoDic = tmpColorAndFontDic;
}
- (NSString *)imagePathForKey:(NSString *)key
{
    NSString *imagePath = [self.skinInfoBundle pathForResource:key ofType:@"png"];
    if (nil == imagePath) {
        imagePath = [self.skinCommonBundle pathForResource:key ofType:@"png"];
    }
    return imagePath;
}
- (UIImage*)imageForKey:(NSString *)key{
    if (key == nil) {
        return nil;
    }
    
    UIImage *image = [_imageCache objectForKey:key];
    if (nil == image) {
        NSString* imagePath = [self.skinInfoBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (image == nil) {
            imagePath = [self.skinCommonBundle pathForResource:key ofType:@"png"];
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        
        if (image != nil) {
            [_imageCache setObject:image forKey:key];
        }
    }
    return image;

}

- (UIFont *)fontForKey:(NSString*)key{
    NSDictionary *fontDic = [_colorAndFontInfoDic objectForKey:key];
    if (!fontDic) {
        return nil;
    }
    NSString *fontName = [fontDic objectForKey:@"name"];
    NSNumber *fontSize = [fontDic objectForKey:@"size"];
    //return [UIFont fontWithName:fontName size:[fontSize floatValue]];
    if (fontName)
    {
        return [UIFont fontWithName:fontName size:[fontSize floatValue]];
    }
    else
    {
        return [UIFont systemFontOfSize:[fontSize floatValue]];
    }
}

- (UIColor *)colorForKey:(NSString*)key{
    return [self colorForFontKey:key andColorKey:kFontColor];
}

- (UIColor *)colorForFontKey:(NSString *)fontKey andColorKey:(NSString *)colorKey{
    NSDictionary *fontDic = [_colorAndFontInfoDic objectForKey:fontKey];
    if (!fontDic) {
        return nil;
    }
    NSString *colorStr = [fontDic objectForKey:colorKey];
    if (!colorStr) {
        return nil;
    }
    NSNumber *redValue;
    NSNumber *greenValue;
    NSNumber *blueValue;
    NSNumber *alphaValue;
    NSArray *colorArray = [colorStr componentsSeparatedByString:@","];
    if (colorArray != nil && colorArray.count == 3) {
        redValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:0] floatValue]];
        greenValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:1] floatValue]];
        blueValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:2] floatValue]];
        alphaValue = [NSNumber numberWithFloat:1.0];
    } else if (colorArray != nil && colorArray.count == 4) {
        redValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:0] floatValue]];
        greenValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:1] floatValue]];
        blueValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:2] floatValue]];
        alphaValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:3] floatValue]];
    } else if (colorArray && colorArray.count == 1){
        //十六进制的颜色值
        NSString *colorString = [colorArray objectAtIndex:0];
        return colorWithHexString(colorString);
    }else {
        return nil;
    }
        
    if ([alphaValue floatValue] <= 0.0f) {
        return [UIColor clearColor];
    }
    return [UIColor colorWithRed:[redValue floatValue]/255.0f 
                           green:[greenValue floatValue]/255.0f
                            blue:[blueValue floatValue]/255.0f
                           alpha:[alphaValue floatValue]];
}

- (void)clearImageCache {
    [_imageCache removeAllObjects];
}

@end