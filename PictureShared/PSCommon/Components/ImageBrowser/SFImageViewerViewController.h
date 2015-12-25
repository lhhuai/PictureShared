//  SFImageViewer
//
//  Created by Felix Schulze on 8/26/2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
#import <UIKit/UIKit.h>
#import "SFImageViewer.h"
#import "SFImageSource.h"
//#import "SFBaseViewController.h"
//#import "ProductInfo.h"

/// SFImageViewerViewController is an UIViewController which can present images.
@interface SFImageViewerViewController : UIViewController <UIScrollViewDelegate>

/// @param imageSource image data source
- (id)initWithImageSource:(id <SFImageSource>)imageSource;

/// @param imageSource image data source
/// @param imageIndex the index of the first shown image
- (id)initWithImageSource:(id <SFImageSource>)imageSource imageIndex:(NSInteger)imageIndex detailData:(NSMutableArray *)detailData;

/// Image data source
@property(strong, nonatomic) id <SFImageSource> imageSource;

/// SFImageView array
@property(strong, nonatomic) NSMutableArray *imageViews;

/// Main scrollView
@property(strong, nonatomic) UIScrollView *scrollView;

/// Disable image sharing
@property(assign, nonatomic, getter = isSharingDisabled) BOOL sharingDisabled;

/// Adjust font size to fit width - Default is NO
@property(assign, nonatomic, getter = isAdjustsFontSizeToFitWidth) BOOL adjustsFontSizeToFitWidth;

/// Current index of the image displayed
/// @return current index of the image displayed
- (NSInteger)currentImageIndex;

- (void)updateCurrentPage;
/// Move the SFImageView to the index
/// @param index index move to
/// @param animated should the movevement animated
- (void)moveToImageAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)setBuyImmediateBlock:(void(^)(void))block;
- (void)setAddCartBlock:(void(^)(void))block;
- (void)setGoCartBlock:(void(^)(void))block;

//- (void)updateCartIcon;

@end