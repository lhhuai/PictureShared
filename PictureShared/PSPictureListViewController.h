//
//  PSPictureListViewController.h
//  PictureShared
//
//  Created by seaphy on 7/16/15.
//  Copyright (c) 2015 seaphy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface PSPictureListViewController : UIViewController <MWPhotoBrowserDelegate>
{
    NSMutableArray *_selections;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;

@end
