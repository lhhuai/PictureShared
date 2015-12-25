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
//
// 该类原来的样子：
// 使用了EGOCache和AFNetworking, EGOCache只有disk cache, 没有memory cache; 而AFNetworking有memory cache, 两者结合使用很好.
// 改为：
// 方案一：
// 1. 使用SDImageCache替换掉EGOCache.
// 2. 使用SDImageDownloaderOperation类替换了AFNetworking.
// 由于SDImageDownloaderOperation类的原因，UI卡，具体原因没查明
// 方案二：
// 使用AFNetworking+TMDiskCache，TMCache是个比较理想的缓存类

//#import <EGOCache/EGOCache.h>
#import "SFImageLoader.h"
#ifdef USE_SebImageDownloader
#import "SDImageCache.h"
#import "SDWebImageDownloaderOperation.h"
#else
#import <AFNetworking/AFNetworking.h>
#import "TMDiskCache.h"
#endif

@implementation SFImageLoader {
    NSMutableArray *runningRequests;
}

+ (SFImageLoader *)sharedInstance {
    static SFImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFImageLoader alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 30.0;
        runningRequests = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
}

- (void)cancelAllRequests {
#ifdef USE_SebImageDownloader
    for (SDWebImageDownloaderOperation *imageRequestOperation in runningRequests) {
#else
    for (AFImageRequestOperation *imageRequestOperation in runningRequests) {
#endif
        [imageRequestOperation cancel];
    }
}

- (void)cancelRequestForUrl:(NSURL *)aURL {
#ifdef USE_SebImageDownloader
    for (SDWebImageDownloaderOperation *imageRequestOperation in runningRequests) {
#else
    for (AFImageRequestOperation *imageRequestOperation in runningRequests) {
#endif
        if ([imageRequestOperation.request.URL isEqual:aURL]) {
            [imageRequestOperation cancel];
            break;
        }
    }
}

- (void)loadImageForURL:(NSURL *)aURL image:(void (^)(UIImage *image, NSError *error))imageBlock {
    NSLog(@"%@", aURL);
    if (!aURL) {
        NSError *error = [NSError errorWithDomain:@"de.felixschulze.fsimageloader" code:412 userInfo:@{
                NSLocalizedDescriptionKey : @"You must set a url"
        }];
        imageBlock(nil, error);
    };
/*    NSString *cacheKey = [NSString stringWithFormat:@"SFImageLoader-%u", [[aURL description] hash]];
    UIImage *anImage = [[EGOCache globalCache] imageForKey:cacheKey];
*/

    NSString* cacheKey = [aURL absoluteString];
#ifdef USE_SebImageDownloader
    UIImage *anImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
#else
    UIImage *anImage = (UIImage*)[[TMDiskCache sharedCache] objectForKey:cacheKey];
#endif
    if (anImage) {
        if (imageBlock) {
            imageBlock(anImage, nil);
        }
    }
    else {
        [self cancelRequestForUrl:aURL];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:aURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:_timeoutInterval];
#ifdef USE_SebImageDownloader
        SDWebImageDownloaderOperation* imageRequestOperation = [[SDWebImageDownloaderOperation alloc] initWithRequest:urlRequest
                                                                                                              options:SDWebImageDownloaderUseNSURLCache];
        [runningRequests addObject:imageRequestOperation];
        __weak SDWebImageDownloaderOperation *imageRequestOperationForBlock = imageRequestOperation;
        
        [imageRequestOperation setProgressBlock:^(NSUInteger receivedSize, long long expectedSize) {
            ;
        }];
        
        [imageRequestOperation setCompletedBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (image && finished) {
                [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
            }
            
            if (imageBlock) {
                imageBlock(image, error);
            }
            [runningRequests removeObject:imageRequestOperationForBlock];
        }];

        [imageRequestOperation setCancelBlock:^{
            if (imageBlock) {
                imageBlock(nil, nil);
            }
            [runningRequests removeObject:imageRequestOperationForBlock];
        }];
        
        [imageRequestOperation start];
#else
        AFImageRequestOperation *imageRequestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        [runningRequests addObject:imageRequestOperation];

        __weak AFImageRequestOperation *imageRequestOperationForBlock = imageRequestOperation;
        [imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = responseObject;
            [[TMDiskCache sharedCache] setObject:image forKey:cacheKey];
//            [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
//            [[EGOCache globalCache] setImage:image forKey:cacheKey];
            if (imageBlock) {
                imageBlock(image, nil);
            }
            [runningRequests removeObject:imageRequestOperationForBlock];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (imageBlock) {
                imageBlock(nil, error);
            }
            [runningRequests removeObject:imageRequestOperationForBlock];
        }];

        [imageRequestOperation start];
#endif
    }
}

@end