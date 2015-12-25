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
//  使用示例：
//  SFBasicImage *firstPhoto = [[SFBasicImage alloc] initWithImageURL:[NSURL URLWithString:@"http://pic14.nipic.com/20110524/3969192_232747559148_2.jpg"] name:@"Photo 1"];
//  SFBasicImage *secondPhoto = [[SFBasicImage alloc] initWithImageURL:[NSURL URLWithString:@"http://fmn.rrfmn.com/fmn060/20120217/1515/original_zYfN_2b2d0003f29e125b.jpg"] name:@"Photo 2"];
//  SFBasicImage *thirdPhoto = [[SFBasicImage alloc] initWithImageURL:[NSURL URLWithString:@"http://fmn.xnpic.com/fmn056/20120217/1455/original_1qXw_19c30003e368125d.jpg"] name:@"Photo 3"];
//
//  SFBasicImageSource *photoSource = [[SFBasicImageSource alloc] initWithImages:@[firstPhoto, secondPhoto, thirdPhoto]];
//
//  SFImageViewerViewController* viewerVC = [[SFImageViewerViewController alloc] initWithImageSource:photoSource];
//  [self.navigationController pushViewController:viewerVC animated:YES];

#import "SFImageViewerViewController.h"
#import "SFImageTitleView.h"
#import "UIButton+block.h"
#import "PSDefines.h"
//#import "SFUserConfigurator.h"
//#import "SFCartIndicator.h"
//#import "SFBuyCartNoticeView.h"
//#import "SFSubscribeArrivalNoticeViewController.h"

@interface SFImageViewerViewController ()

@property(strong, nonatomic) SFImageTitleView *titleView;
//@property (nonatomic, strong) SFCartIndicator *cartIndicator;

@end

@implementation SFImageViewerViewController {
    NSInteger pageIndex;
    BOOL rotating;
    BOOL barsHidden;
    BOOL statusBarHidden;
    UIBarButtonItem *shareButton;
    UIView *_buttonNavView;
    
    void(^BuyImmediateBlock)(void);
    void(^AddCartBlock)(void);
    void(^GoCartBlock)(void);
    
    NSMutableArray *animationLayers;
    // 商品
//    SfbestAppEntitiesProductDetail* detailData_;
}

- (id)initWithImageSource:(id <SFImageSource>)aImageSource {
    return [self initWithImageSource:aImageSource imageIndex:0 detailData:nil];
}

- (id)initWithImageSource:(id <SFImageSource>)imageSource imageIndex:(NSInteger)imageIndex detailData:(NSMutableArray *)detailData{
    if ((self = [super init])) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleBarsNotification:) name:kSFImageViewerToogleBarsNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageViewDidFinishLoading:) name:kSFImageViewerDidFinishedLoadingNotificationKey object:nil];

        self.hidesBottomBarWhenPushed = YES;
        self.wantsFullScreenLayout = YES;

        _imageSource = imageSource;
        pageIndex = imageIndex;
//        detailData_ = detailData;
        
        self.sharingDisabled = NO;
    }
    return self;
}
- (void)setImageSource:(id<SFImageSource>)imageSource {
    _imageSource = imageSource;
    // refresh current
    [self loadScrollViewWithPage:pageIndex];
}
- (void)dealloc {
    _scrollView.delegate = nil;
//    [[SFImageLoader sharedInstance] cancelAllRequests];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"didReceiveMemoryWarning");
    self.imageViews = nil;
    _scrollView.delegate = nil;
    self.scrollView = nil;
    _titleView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

#ifdef __IPHONE_7_0
	if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
#endif

    self.view.backgroundColor = [UIColor whiteColor];

    if (!_scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _scrollView.scrollEnabled = YES;
        _scrollView.multipleTouchEnabled = NO;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.delaysContentTouches = YES;
        _scrollView.clipsToBounds = YES;
        _scrollView.bounces = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = self.view.backgroundColor;
        [self.view addSubview:_scrollView];
    }

    if (!_titleView) {
        self.titleView = [[SFImageTitleView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 1)];
        _titleView.adjustsFontSizeToFitWidth = [self isAdjustsFontSizeToFitWidth];
        [self.view addSubview:_titleView];
    }

    //  load SFImageView lazy
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [_imageSource numberOfImages]; i++) {
        [views addObject:[NSNull null]];
    }
    self.imageViews = views;
    
    // add by SFBest
    _buttonNavView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT, SCREEN_WIDTH, 49)];
    _buttonNavView.backgroundColor = [UIColor whiteColor];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_buttonNavView.frame), .5)];
//    topLine.backgroundColor = COLOR_SEPARATOR_LINE;
    [_buttonNavView addSubview:topLine];
    
//    // V2.3版本缺货时，到货提醒放到“加入购物车”位置代替 除预售商品，商品详情页面去掉“立即购买”
//    SFBuyCartNoticeView *buyCartNoticeView = [[SFBuyCartNoticeView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-44-15, PHONE_TABBAR_HEIGHT)];
//    __weak __typeof (&*self)weakself = self;
//    [buyCartNoticeView setImBuyBlock:^{
//        if (BuyImmediateBlock) {
//            BuyImmediateBlock();
//        }
//    } addCartBlock:^{
//        SFImageView *view = self.imageViews[pageIndex];
//        if (view.imageView.image) {
//            [self cartParabolaAnimation:view.imageView];
//        } else {
//            [[SFTipView sharedInstance] showMessage:@"加入成功"];
//        }
//        if (AddCartBlock) {
//            AddCartBlock();
//        }
//    } arrivalRemindBlock:^{
//        // 未登陆
//        [weakself.navigationController login:^{
//            SFSubscribeArrivalNoticeViewController *subscribeView = [SFSubscribeArrivalNoticeViewController new];
//            subscribeView.productId = detailData_.ProductId;
//            [self.navigationController pushViewController:subscribeView animated:YES];
//        }];
//    }];
//    [_buttonNavView addSubview:buyCartNoticeView];
//    [buyCartNoticeView updateBuyCartNoticeView:detailData_];
//    
//    _cartIndicator = [[SFCartIndicator alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-44-15, 2, 44, 44)
//                                                     action:GoCartBlock];
//    [_buttonNavView addSubview:_cartIndicator];
//
//    [self.view addSubview:_buttonNavView];
//    [self.view bringSubviewToFront:_buttonNavView];
}
- (void)setBuyImmediateBlock:(void(^)(void))block {
    BuyImmediateBlock = block;
}
- (void)setAddCartBlock:(void(^)(void))block {
    AddCartBlock = block;
}
- (void)setGoCartBlock:(void(^)(void))block {
    GoCartBlock = block;
}
//- (void)updateCartIcon
//{
//    __weak __typeof(&*self) weakSelf = self;
//    [[SFUserConfigurator sharedInstance] cartProductNums:^(int productNums) {
//        weakSelf.cartIndicator.number = productNums;
//    }];
//}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    [self updateCartIcon];
    
    shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    shareButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItems = nil;
    // 导航栏部分后期确定，暂无需求，zsg，20140330
//    if (self.presentingViewController && (self.modalPresentationStyle == UIModalPresentationFullScreen)) {
//        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[self localizedStringForKey:@"done" withDefault:@"Done"] style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
//        self.navigationItem.rightBarButtonItem = doneButton;
//        if (!_sharingDisabled) {
//            self.navigationItem.leftBarButtonItem = shareButton;
//        }
//    }
//    else {
//        if (!_sharingDisabled) {
//            self.navigationItem.rightBarButtonItem = shareButton;
//        }
//    }

    [self setupScrollViewContentSize];
    [self moveToImageAtIndex:pageIndex animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }

    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    rotating = YES;

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        _scrollView.contentSize = CGSizeMake(rect.size.height * [_imageSource numberOfImages], rect.size.width);
    }

    NSInteger count = 0;
    for (SFImageView *view in _imageViews) {
        if ([view isKindOfClass:[SFImageView class]]) {
            if (count != pageIndex) {
                [view setHidden:YES];
            }
        }
        count++;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    for (SFImageView *view in _imageViews) {
        if ([view isKindOfClass:[SFImageView class]]) {
            [view rotateToOrientation:toInterfaceOrientation];
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setupScrollViewContentSize];
    [self moveToImageAtIndex:pageIndex animated:NO];
    [_scrollView scrollRectToVisible:((SFImageView *) [_imageViews objectAtIndex:(NSUInteger) pageIndex]).frame animated:YES];

    for (SFImageView *view in self.imageViews) {
        if ([view isKindOfClass:[SFImageView class]]) {
            [view setHidden:NO];
        }
    }
    rotating = NO;
}

- (void)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share:(id)sender {
    if ([UIActivityViewController class]) {
        id<SFImage> currentImage = _imageSource[[self currentImageIndex]];
        NSAssert(currentImage.image, @"The image must be loaded to share.");
        if (currentImage.image) {
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[currentImage.image] applicationActivities:nil];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void) setSharingDisabled:(BOOL)sharingDisabled {
    if (![UIActivityViewController class]) {
        _sharingDisabled = YES;
    }
    else {
        _sharingDisabled = sharingDisabled;
    }
}

- (NSInteger)currentImageIndex {
    return pageIndex;
}
- (void)updateCurrentPage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self moveToImageAtIndex:pageIndex animated:NO];
    });
}
#pragma mark - Bar/Caption Methods

- (void)setStatusBarHidden:(BOOL)hidden {
    statusBarHidden = hidden;
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
#endif
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
#ifdef __IPHONE_7_0
    }
#endif

}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden && barsHidden) {
        return;
    }

    [self setStatusBarHidden:hidden];
    [self.navigationController setNavigationBarHidden:hidden animated:animated];

    [UIView animateWithDuration:0.3 animations:^{
        UIColor *backgroundColor = hidden ? [UIColor blackColor] : [UIColor whiteColor];
        self.view.backgroundColor = backgroundColor;
        self.scrollView.backgroundColor = backgroundColor;
        for (SFImageView *imageView in _imageViews) {
            if ([imageView isKindOfClass:[SFImageView class]]) {
                [imageView changeBackgroundColor:backgroundColor];;
            }
        }
    }];

    [_titleView hideView:hidden];
    _buttonNavView.hidden = hidden;
    barsHidden = hidden;
}

- (void)toggleBarsNotification:(NSNotification *)notification {
    [self setBarsHidden:!barsHidden animated:YES];
}

#pragma mark - Image View

- (void)imageViewDidFinishLoading:(NSNotification *)notification {
    if (notification == nil) {
        return;
    }

    if ([[notification object][@"image"] isEqual:_imageSource[[self centerImageIndex]]]) {
        if ([[notification object][@"failed"] boolValue]) {
            if (barsHidden) {
                [self setBarsHidden:NO animated:YES];
            }
            shareButton.enabled = NO;
        }
        else {
            shareButton.enabled = YES;
        }
        [self setViewState];
    }
}

- (NSInteger)centerImageIndex {
    if (self.scrollView) {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        NSInteger centerImageIndex = (NSInteger)(floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
        if (centerImageIndex >= 0) {
            return centerImageIndex;
        }
    }
    return 0;
}

- (void)setViewState {

    NSInteger numberOfImages = [_imageSource numberOfImages];
    if (numberOfImages > 1) {
        self.navigationItem.title = [NSString stringWithFormat:@"%li %@ %li", pageIndex + 1, [self localizedStringForKey:@"imageCounter" withDefault:@"/"], numberOfImages];
    } else {
        self.title = @"";
    }

    if (_titleView) {
        _titleView.text = _imageSource[pageIndex].title;
    }

}

- (void)moveToImageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < [self.imageSource numberOfImages] && index >= 0) {

        pageIndex = index;
        [self setViewState];

        [self enqueueImageViewAtIndex:index];

        [self loadScrollViewWithPage:index - 1];
        [self loadScrollViewWithPage:index];
        [self loadScrollViewWithPage:index + 1];

        [self.scrollView scrollRectToVisible:((SFImageView *) [_imageViews objectAtIndex:(NSUInteger) index]).frame animated:animated];

        if (_imageSource[pageIndex].failed) {
            [self setBarsHidden:NO animated:YES];
            shareButton.enabled = NO;
        }
        else {
            if (pageIndex == [self currentImageIndex] && _imageSource[pageIndex].image) {
                shareButton.enabled = YES;
            }
        }

        if (index + 1 < [self.imageSource numberOfImages] && (NSNull *) [_imageViews objectAtIndex:(NSUInteger) (index + 1)] != [NSNull null]) {
            [((SFImageView *) [self.imageViews objectAtIndex:(NSUInteger) (index + 1)]) killScrollViewZoom];
        }
        if (index - 1 >= 0 && (NSNull *) [self.imageViews objectAtIndex:(NSUInteger) (index - 1)] != [NSNull null]) {
            [((SFImageView *) [self.imageViews objectAtIndex:(NSUInteger) (index - 1)]) killScrollViewZoom];
        }
    }
}

- (void)layoutScrollViewSubviews {

    NSInteger index = [self currentImageIndex];

    for (NSInteger page = index - 1; page < index + 3; page++) {

        if (page >= 0 && page < [_imageSource numberOfImages]) {

            CGFloat originX = _scrollView.bounds.size.width * page;

            if (page < index) {
                originX -= kSFImageViewerImageGap;
            }
            if (page > index) {
                originX += kSFImageViewerImageGap;
            }

            if ([_imageViews objectAtIndex:(NSUInteger) page] == [NSNull null] || !((UIView *) [_imageViews objectAtIndex:(NSUInteger) page]).superview) {
                [self loadScrollViewWithPage:page];
            }

            SFImageView *imageView = [_imageViews objectAtIndex:(NSUInteger) page];
            CGRect newFrame = CGRectMake(originX, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height);

            if (!CGRectEqualToRect(imageView.frame, newFrame)) {
                [UIView animateWithDuration:0.1 animations:^{
                    imageView.frame = newFrame;
                }];
            }
        }
    }
}

- (void)setupScrollViewContentSize {

    CGSize contentSize = self.view.bounds.size;
    contentSize.width = (contentSize.width * [_imageSource numberOfImages]);

    if (!CGSizeEqualToSize(contentSize, self.scrollView.contentSize)) {
        self.scrollView.contentSize = contentSize;
    }

    if (![_titleView isHidden]) {
        _titleView.frame = CGRectMake(0.0f, self.view.bounds.size.height - 40.0f, self.view.bounds.size.width, 40.0f);
    }
}

- (void)enqueueImageViewAtIndex:(NSInteger)theIndex {

    NSInteger count = 0;
    for (SFImageView *view in _imageViews) {
        if ([view isKindOfClass:[SFImageView class]]) {
            if (count > theIndex + 1 || count < theIndex - 1) {
                [view prepareForReuse];
                [view removeFromSuperview];
            } else {
                view.tag = 0;
            }
        }
        count++;
    }
}

- (SFImageView *)dequeueImageView {

    NSInteger count = 0;
    for (SFImageView *view in self.imageViews) {
        if ([view isKindOfClass:[SFImageView class]]) {
            if (view.superview == nil) {
                view.tag = count;
                return view;
            }
        }
        count++;
    }
    return nil;
}

- (void)loadScrollViewWithPage:(NSInteger)page {
    
    if (page < 0) {
        return;
    }
    if (page >= [_imageSource numberOfImages]) {
        return;
    }

    SFImageView *imageView = [_imageViews objectAtIndex:(NSUInteger) page];
    if ((NSNull *) imageView == [NSNull null]) {
        imageView = [self dequeueImageView];
        if (imageView != nil) {
            [_imageViews exchangeObjectAtIndex:(NSUInteger) imageView.tag withObjectAtIndex:(NSUInteger) page];
            imageView = [_imageViews objectAtIndex:(NSUInteger) page];
        }
    }

    if (imageView == nil || (NSNull *) imageView == [NSNull null]) {
        imageView = [[SFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height)];
        UIColor *backgroundColor = barsHidden ? [UIColor blackColor] : [UIColor whiteColor];
        [imageView changeBackgroundColor:backgroundColor];
        [_imageViews replaceObjectAtIndex:(NSUInteger) page withObject:imageView];
    }
//    NSLog(@"load page: %d", page);
    imageView.image = _imageSource[page];
    [imageView loadImage];
    if (imageView.superview == nil) {
        [_scrollView addSubview:imageView];
    }

    CGRect frame = _scrollView.frame;
    NSInteger centerPageIndex = pageIndex;
    CGFloat xOrigin = (frame.size.width * page);
    if (page > centerPageIndex) {
        xOrigin = (frame.size.width * page) + kSFImageViewerImageGap;
    } else if (page < centerPageIndex) {
        xOrigin = (frame.size.width * page) - kSFImageViewerImageGap;
    }

    frame.origin.x = xOrigin;
    frame.origin.y = 0;
    imageView.frame = frame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = [self centerImageIndex];
    if (index >= [_imageSource numberOfImages] || index < 0) {
        return;
    }

    if (pageIndex != index && !rotating) {
        pageIndex = index;
        [self setViewState];

        if (![scrollView isTracking]) {
            [self layoutScrollViewSubviews];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = [self centerImageIndex];
    if (index >= [_imageSource numberOfImages] || index < 0) {
        return;
    }

    [self moveToImageAtIndex:index animated:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self layoutScrollViewSubviews];
}

- (BOOL)prefersStatusBarHidden {
    return statusBarHidden;
}

#pragma mark - Localization Helper
- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"SFImageViewer" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
        for (NSString *language in [NSLocale preferredLanguages])
            {
                if ([[bundle localizations] containsObject:language])
                {
                    bundlePath = [bundle pathForResource:language ofType:@"lproj"];
                    bundle = [NSBundle bundleWithPath:bundlePath];
                    break;
                }
            }
        }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

#pragma mark -
#pragma mark - Cart Animation
// 加入购物车动画
- (void)cartParabolaAnimation:(UIImageView *)imageView
{
    if (animationLayers == nil)
    {
        animationLayers = [[NSMutableArray alloc] init];
    }
    
    CALayer *transitionLayer = [[CALayer alloc] init];
    transitionLayer.frame = CGRectMake(100, SCREEN_HEIGHT, 144, 144);
    transitionLayer.contents = imageView.layer.contents;
    [self.view.layer addSublayer:transitionLayer];
    [animationLayers addObject:transitionLayer];
    
    CGMutablePathRef  path = CGPathCreateMutable();
    CGPoint p1 = CGPointMake(145, self.view.bounds.size.height - 22);
    CGPoint p3 = CGPointMake(self.view.bounds.size.width - 22, p1.y);
    
    CGPathMoveToPoint(path, NULL, p1.x, p1.y);
    
    CGPathAddQuadCurveToPoint(path, NULL, (p1.x+p3.x)*.5, p1.y - 400, p3.x, p3.y);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.path = path;
    CGPathRelease(path);
    animation.duration = 1;
    animation.repeatCount = 1;
    animation.delegate = self;
    
    CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    animation2.duration = 1;
    animation2.repeatCount =1;
    animation2.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0.1, 0.1, 1)];
    
    [transitionLayer addAnimation:animation forKey:@"position"];//@"position"
    [transitionLayer addAnimation:animation2 forKey:@"transform"];
    transitionLayer.needsDisplayOnBoundsChange = YES;
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
}

// 加入购物车动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *transitionLayer = [animationLayers objectAtIndex:0];
    [animationLayers removeObjectAtIndex:0];
    [transitionLayer removeFromSuperlayer];
    transitionLayer = nil;
}
@end
