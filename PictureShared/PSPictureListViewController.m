//
//  PSPictureListViewController.m
//  PictureShared
//
//  Created by seaphy on 7/16/15.
//  Copyright (c) 2015 seaphy. All rights reserved.
//

#import "PSPictureListViewController.h"
#import "PSDefines.h"
#import <QuickLook/QuickLook.h>
#import "MJRefreshHeaderView.h"
#import "SFBasicImage.h"
#import "SFBasicImageSource.h"
#import "SFImageViewerViewController.h"
#import "SFUtil.h"
#import <SDImageCache.h>

static NSString *savedFlagDictionary = @"savedFlagDictionary";

@interface PSPictureListViewController () <UITableViewDataSource, UITableViewDelegate, MJRefreshBaseViewDelegate, UIActionSheetDelegate>
// QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIDocumentInteractionControllerDelegate

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *checkArray;
@property (nonatomic, retain) NSMutableArray *dirArray;
//@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@property (nonatomic, strong) MJRefreshHeaderView *refreshHeaderView;
@property (nonatomic, assign) CGFloat startDragY;
@property (nonatomic, assign) CGFloat endDragY;
@property (nonatomic, assign) BOOL isAcceptTapGesture;

@property (nonatomic, strong) UIBarButtonItem *clearSavedFlagDictionaryBarButtonItem;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property (nonatomic, strong) UIButton *shareToButton;
@property (nonatomic, strong) UIButton *saveToPhotosButton;
@property (nonatomic, strong) UIButton *delPictureButton;

@end

@implementation PSPictureListViewController
{
    __weak PSPictureListViewController *weakSelf;
}

- (id)init {
    self = [super init];
    
    self.title = @"Pictures";
    
    if (self) {
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    weakSelf = self;
    
    self.clearSavedFlagDictionaryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"ClearSaved" style:UIBarButtonItemStyleBordered target:self action:@selector(didClearSavedFlagDictionaryBarButtonItem)];
    [self.clearSavedFlagDictionaryBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = self.clearSavedFlagDictionaryBarButtonItem;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60 * 2, PHONE_NAVIGATIONBAR_HEIGHT)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"Pictures";
    self.navigationItem.titleView = self.titleLabel;
    
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(didRightBarButton)];
    [self.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_HEIGHT) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_HEIGHT, SCREEN_WIDTH, PHONE_TABBAR_HEIGHT)];
    footerView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
    footerView.layer.borderWidth = 1.0;
    footerView.layer.borderColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1.0].CGColor;
    
    self.shareToButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, PHONE_TABBAR_HEIGHT)];
    [self.shareToButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.shareToButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.shareToButton setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareToButton setEnabled:NO];
    [self.shareToButton setAlpha:0.4];
    
    self.saveToPhotosButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, SCREEN_WIDTH - 60 * 2, PHONE_TABBAR_HEIGHT)];
    [self.saveToPhotosButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.saveToPhotosButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.saveToPhotosButton setTitle:@"Save To Photos" forState:UIControlStateNormal];
    [self.saveToPhotosButton addTarget:self action:@selector(didSaveToPhotosButton) forControlEvents:UIControlEventTouchUpInside];
    [self.saveToPhotosButton setEnabled:NO];
    [self.saveToPhotosButton setAlpha:0.4];
    
    self.delPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, PHONE_TABBAR_HEIGHT)];
    [self.delPictureButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.delPictureButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.delPictureButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.delPictureButton addTarget:self action:@selector(didDelPictureButton) forControlEvents:UIControlEventTouchUpInside];
    [self.delPictureButton setEnabled:NO];
    [self.delPictureButton setAlpha:0.4];
    
    [footerView addSubview:self.shareToButton];
    [footerView addSubview:self.saveToPhotosButton];
    [footerView addSubview:self.delPictureButton];
    [self.view addSubview:footerView];
    
    self.refreshHeaderView = [MJRefreshHeaderView header];
    self.refreshHeaderView.scrollView = self.tableView;
    self.refreshHeaderView.delegate = self;
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey:savedFlagDictionary];
//    NSMutableDictionary *savedFlagDic = [defaults dictionaryForKey:savedFlagDictionary].mutableCopy;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    self.dirArray = [[NSMutableArray alloc] init];
    self.checkArray = [[NSMutableArray alloc]init];
    
    for (NSString *file in fileList)
    {
        [self.dirArray addObject:file];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"NO" forKey:@"checked"];
        [self.checkArray addObject:dic];
    }
    
    if (IOS_VERSION >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    } else {
        self.wantsFullScreenLayout = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView setEditing:NO];
}

- (void)didClearSavedFlagDictionaryBarButtonItem {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:savedFlagDictionary];
    [self loadData];
}

- (void)didRightBarButton {
    if ([self.rightBarButtonItem.title isEqual:@"Select"]) {
//        self.navigationItem.title = @"Select Items";
        self.titleLabel.text = @"Select Items";
        self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleBordered target:self action:@selector(didLeftBarButton)];
        [self.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName, nil] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
        
        [self.rightBarButtonItem setTitle:@"Cancel"];
        [self.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [self.tableView setEditing:YES];
//        self.tableView.editing = UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
        
        NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[self.tableView indexPathsForVisibleRows]];
        for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
            NSIndexPath *indexPath = [anArrayOfIndexPath objectAtIndex:i];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else {
        self.titleLabel.text = @"Pictures";
//        self.navigationItem.title = @"Pictures";
        self.navigationItem.leftBarButtonItem = self.clearSavedFlagDictionaryBarButtonItem;
        
        [self.rightBarButtonItem setTitle:@"Select"];
        [self.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
        [self.tableView setEditing:NO];
//        self.tableView.editing = UITableViewCellEditingStyleDelete;
    }
    for (NSDictionary *dic in self.checkArray) {
        [dic setValue:@"NO" forKey:@"checked"];
    }
    [self setOperatePictureButton];
}

- (void)didLeftBarButton {
    BOOL selected = NO;
    if ([self.leftBarButtonItem.title isEqual:@"Select All"]) {
        selected = YES;
    } else {
        selected = NO;
    }
    NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[self.tableView indexPathsForVisibleRows]];
    for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
        NSIndexPath *indexPath = [anArrayOfIndexPath objectAtIndex:i];
        if (selected) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
//        [cell setSelected:selected];
    }
    if (selected) {
        [self.leftBarButtonItem setTitle:@"Cancel All"];
        [self.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        self.titleLabel.text = [NSString stringWithFormat:@"%lu Pictures Selected", (unsigned long)self.dirArray.count];
//        self.navigationItem.title = [NSString stringWithFormat:@"%lu Pictures Selected", self.dirArray.count];
        
        for (NSDictionary *dic in self.checkArray) {
            [dic setValue:@"YES" forKey:@"checked"];
        }
    } else {
        [self.leftBarButtonItem setTitle:@"Select All"];
        [self.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        self.titleLabel.text = @"Select Items";
//        self.navigationItem.title = @"Select Items";
        
        for (NSDictionary *dic in self.checkArray) {
            [dic setValue:@"NO" forKey:@"checked"];
        }
    }
    [self setOperatePictureButton];
}

- (void)didSaveToPhotosButton {
    NSString *saveButtonTitle = nil;
    if ([self countOfCheckArray] == 1) {
        saveButtonTitle = @"Save Picture";
    } else {
        saveButtonTitle = [NSString stringWithFormat:@"Save %lu Pictures", (unsigned long)[self countOfCheckArray]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *savedFlagDic = [defaults dictionaryForKey:savedFlagDictionary].mutableCopy;
    
    NSString *notSavedButtonTitle = nil;
    NSUInteger count = 0;
    for (int i = 0; i < [self.checkArray count]; i++) {
        if ([[[self.checkArray objectAtIndex:i] objectForKey:@"checked"] isEqualToString:@"YES"]
            && ![[savedFlagDic objectForKey:[self.dirArray objectAtIndex:i]] isEqualToString:@"Saved"]) {
            count ++;
        }
    }
    if (count < [self countOfCheckArray] && count == 1) {
        notSavedButtonTitle = @"Save Picture(Not Saved)";
    } else if(count < [self countOfCheckArray] && count > 1) {
        notSavedButtonTitle = [NSString stringWithFormat:@"Save %lu Pictures(Not Saved)", (unsigned long)count];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:saveButtonTitle, notSavedButtonTitle, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = 1;
    
//    UILabel *destructiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, PHONE_NAVIGATIONBAR_HEIGHT)];
//    destructiveLabel.font = [UIFont boldSystemFontOfSize:14];
//    destructiveLabel.textAlignment = NSTextAlignmentCenter;
//    destructiveLabel.text = destructiveButtonTitle;
//    
//    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, PHONE_NAVIGATIONBAR_HEIGHT)];
//    cancelLabel.font = [UIFont boldSystemFontOfSize:14];
//    cancelLabel.textAlignment = NSTextAlignmentCenter;
//    cancelLabel.text = @"Cancel";
//    
//    [actionSheet addSubview:destructiveLabel];
//    [actionSheet addSubview:cancelLabel];
    
//    [actionSheet addButtonWithTitle:destructiveButtonTitle];
//    [actionSheet addButtonWithTitle:@"Cancel"];

    [actionSheet showInView:self.view];
    
//    UIImage *image = [[UIImage alloc] init];
//    for (int i = 0; i < [self.checkArray count]; i++) {
//        NSMutableDictionary *dic = [self.checkArray objectAtIndex:i];
//        if ([[dic objectForKey:@"checked"] isEqualToString:@"YES"]) {
//            NSURL *fileURL = nil;
//            NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentDir = [documentPaths objectAtIndex:0];
//            NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:i]];
//            fileURL = [NSURL fileURLWithPath:path];
//            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:fileURL]];
//            [self saveImageToPhotos:image];
//        }
//    }
}

- (void)saveImageToPhotos:(UIImage *)savedImage {
    UIImageWriteToSavedPhotosAlbum(savedImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil;
    if (error != NULL) {
        msg = @"save picture fail.";
    } else {
        msg = @"save picture success.";
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                    message:msg
//                                                   delegate:self
//                                          cancelButtonTitle:@"ok"
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (void)didDelPictureButton {
    NSString *deleteButtonTitle = nil;
    if ([self countOfCheckArray] == 1) {
        deleteButtonTitle = @"Delete Picture";
    } else {
        deleteButtonTitle = [NSString stringWithFormat:@"Delete %lu Pictures", (unsigned long)[self countOfCheckArray]];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *savedFlagDic = [defaults dictionaryForKey:savedFlagDictionary].mutableCopy;
    
    NSString *deleteSavedButtonTitle = nil;
    NSUInteger count = 0;
    for (int i = 0; i < [self.checkArray count]; i++) {
        if ([[[self.checkArray objectAtIndex:i] objectForKey:@"checked"] isEqualToString:@"YES"]
            && [[savedFlagDic objectForKey:[self.dirArray objectAtIndex:i]] isEqualToString:@"Saved"]) {
            count ++;
        }
    }
    if (count < [self countOfCheckArray] && count == 1) {
        deleteSavedButtonTitle = @"Delete Picture(Saved)";
    } else if(count < [self countOfCheckArray] && count > 1) {
        deleteSavedButtonTitle = [NSString stringWithFormat:@"Delete %lu Pictures(Saved)", (unsigned long)count];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:deleteButtonTitle, deleteSavedButtonTitle, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = 2;
    
    [actionSheet showInView:self.view];
}

- (void)setOperatePictureButton {
    if ([self countOfCheckArray] > 0) {
        [self.saveToPhotosButton setEnabled:YES];
        [self.saveToPhotosButton setTitleColor:[UIColor colorWithRed:47/255.0 green:128/255.0 blue:253/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.saveToPhotosButton setAlpha:1.0];
        
        [self.delPictureButton setEnabled:YES];
        [self.delPictureButton setTitleColor:[UIColor colorWithRed:47/255.0 green:128/255.0 blue:253/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.delPictureButton setAlpha:1.0];
    } else {
        [self.saveToPhotosButton setEnabled:NO];
        [self.saveToPhotosButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.saveToPhotosButton setAlpha:0.4];
        
        [self.delPictureButton setEnabled:NO];
        [self.delPictureButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.delPictureButton setAlpha:0.4];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dirArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"PictureListId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *savedFlagDic = [defaults dictionaryForKey:savedFlagDictionary].mutableCopy;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.textLabel.text = [self.dirArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        NSString *savedFlag = [savedFlagDic objectForKey:cell.textLabel.text];
        
        UILabel *saveFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 78, 0, 70, cell.frame.size.height)];
        saveFlagLabel.font = [UIFont systemFontOfSize:14];
        saveFlagLabel.textAlignment = NSTextAlignmentRight;
        if ([savedFlag isEqualToString:@"Saved"]) {
            saveFlagLabel.text = @"Saved";
            saveFlagLabel.textColor = [UIColor colorWithRed:47/255.0 green:128/255.0 blue:253/255.0 alpha:1.0];
            saveFlagLabel.alpha = 1.0;
        } else {
            saveFlagLabel.text = @"Not Saved";
            saveFlagLabel.textColor = [UIColor grayColor];
            saveFlagLabel.alpha = 0.4;
        }
        saveFlagLabel.tag = 1;
        [cell addSubview:saveFlagLabel];
    } else {
        cell.textLabel.text = [self.dirArray objectAtIndex:indexPath.row];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *savedFlag = [savedFlagDic objectForKey:cell.textLabel.text];
        
        UILabel *saveFlagLabel = (UILabel *)[cell viewWithTag:1];
        saveFlagLabel.font = [UIFont systemFontOfSize:14];
        saveFlagLabel.textAlignment = NSTextAlignmentRight;
        if ([savedFlag isEqualToString:@"Saved"]) {
            saveFlagLabel.text = @"Saved";
            saveFlagLabel.textColor = [UIColor colorWithRed:47/255.0 green:128/255.0 blue:253/255.0 alpha:1.0];
            saveFlagLabel.alpha = 1.0;
        } else {
            saveFlagLabel.text = @"Not Saved";
            saveFlagLabel.textColor = [UIColor grayColor];
            saveFlagLabel.alpha = 0.4;
        }
    }
    
//    NSURL *fileURL= nil;
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDir = [documentPaths objectAtIndex:0];
//    NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:indexPath.row]];
//    fileURL = [NSURL fileURLWithPath:path];
    
//    [self setupDocumentControllerWithURL:fileURL];
    
//    NSInteger iconCount = [self.docInteractionController.icons count];
//    if (iconCount > 0)
//    {
//        cell.imageView.image = [self.docInteractionController.icons objectAtIndex:iconCount - 1];
//    }
    NSUInteger row = [indexPath row];
    NSMutableDictionary *dic = [self.checkArray objectAtIndex:row];
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
        [dic setObject:@"NO" forKey:@"checked"];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else {
        [dic setObject:@"YES" forKey:@"checked"];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

//step7. 利用url路径打开UIDocumentInteractionController
//- (void)setupDocumentControllerWithURL:(NSURL *)url
//{
//    if (self.docInteractionController == nil)
//    {
//        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
//        self.docInteractionController.delegate = self;
//    }
//    else
//    {
//        self.docInteractionController.URL = url;
//    }
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSURL *fileURL= nil;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:indexPath.row]];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath:path]) {
            if ([fileManager removeItemAtPath:path error:nil]) {
                [self.dirArray removeObjectAtIndex:indexPath.row];
                [self.checkArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rightBarButtonItem.title isEqual:@"Select"]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rightBarButtonItem.title isEqualToString:@"Cancel"]) {
        NSUInteger row = [indexPath row];
        NSMutableDictionary *dic = [self.checkArray objectAtIndex:row];
        [dic setObject:@"YES" forKey:@"checked"];
        if ([self countOfCheckArray] > 1) {
            self.titleLabel.text = [NSString stringWithFormat:@"%lu Pictures Selected", (unsigned long)[self countOfCheckArray]];
        } else {
            self.titleLabel.text = [NSString stringWithFormat:@"%lu Picture Selected", (unsigned long)[self countOfCheckArray]];
        }
        
        
        if ([tableView.indexPathsForSelectedRows count] == [self.dirArray count]) {
            [self.leftBarButtonItem setTitle:@"Cancel All"];
            [self.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        }
        
        [self setOperatePictureButton];
    } else {
//        SFBasicImageSource *imageSource = [[SFBasicImageSource alloc] initWithImages:nil];
//        NSMutableArray *array = [NSMutableArray new];
//        
//        NSURL *fileURL = nil;
//        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentDir = [documentPaths objectAtIndex:0];
//        
//        for (int i = 0; i < [self.dirArray count]; i++) {
//            NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:i]];
//            fileURL = [NSURL fileURLWithPath:path];
//            SFBasicImage *image_ = [[SFBasicImage alloc] initWithImageURL:fileURL name:[self.dirArray objectAtIndex:i]];
//            [array addObject:image_];
//        }
//        imageSource.images = array;
//        
//        SFImageViewerViewController* viewerViewController = [[SFImageViewerViewController alloc] initWithImageSource:imageSource imageIndex:indexPath.row detailData:nil];
//
//        [self.navigationController pushViewController:viewerViewController animated:YES];
        
        // Browser
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSMutableArray *thumbs = [[NSMutableArray alloc] init];

        MWPhoto *photo;
        BOOL displayActionButton = YES;
        BOOL displaySelectionButtons = NO;
        BOOL displayNavArrows = YES;
        BOOL enableGrid = YES;
        BOOL startOnGrid = YES;
        BOOL autoPlayOnAppear = NO;
        
        NSURL *fileURL = nil;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        for (int i = 0; i < [self.dirArray count]; i++) {
            NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:i]];
            fileURL = [NSURL fileURLWithPath:path];
            photo = [MWPhoto photoWithURL:fileURL];
            photo.caption = [self.dirArray objectAtIndex:i];
            
            [thumbs addObject:photo];
            [photos addObject:photo];
        }
        
        self.photos = photos;
        self.thumbs = thumbs;
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = displayActionButton;
        browser.displayNavArrows = displayNavArrows;
        browser.displaySelectionButtons = displaySelectionButtons;
        browser.alwaysShowControls = displaySelectionButtons;
        browser.zoomPhotosToFill = YES;
        browser.enableGrid = enableGrid;
        browser.startOnGrid = startOnGrid;
        browser.enableSwipeToDismiss = NO;
        browser.autoPlayOnAppear = autoPlayOnAppear;
        [browser setCurrentPhotoIndex:indexPath.row];
        
        // Test custom selection images
        //    browser.customImageSelectedIconName = @"ImageSelected.png";
        //    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
        
        // Reset selections
        if (displaySelectionButtons) {
            _selections = [NSMutableArray new];
            for (int i = 0; i < photos.count; i++) {
                [_selections addObject:[NSNumber numberWithBool:NO]];
            }
        }
        
//        // Show
//        if (_segmentedControl.selectedSegmentIndex == 0) {
            // Push
            [self.navigationController pushViewController:browser animated:YES];
//        } else {
//            // Modal
//            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
//            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            [self presentViewController:nc animated:YES completion:nil];
//        }
        
        // Release
        
        // Deselect
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Test reloading of data after delay
        double delayInSeconds = 3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            //        // Test removing an object
            //        [_photos removeLastObject];
            //        [browser reloadData];
            //
            //        // Test all new
            //        [_photos removeAllObjects];
            //        [_photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
            //        [browser reloadData];
            //
            //        // Test changing photo index
            //        [browser setCurrentPhotoIndex:9];
            
            //        // Test updating selections
            //        _selections = [NSMutableArray new];
            //        for (int i = 0; i < [self numberOfPhotosInPhotoBrowser:browser]; i++) {
            //            [_selections addObject:[NSNumber numberWithBool:YES]];
            //        }
            //        [browser reloadData];
            
        });
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rightBarButtonItem.title isEqualToString:@"Cancel"]) {
        NSUInteger row = [indexPath row];
        NSMutableDictionary *dic = [self.checkArray objectAtIndex:row];
        [dic setObject:@"NO" forKey:@"checked"];
        
        
        if ([self countOfCheckArray] == 0) {
            [self.leftBarButtonItem setTitle:@"Select All"];
            [self.leftBarButtonItem setStyle:UIBarButtonItemStyleBordered];
            
            self.titleLabel.text = @"Select Items";
        } else {
            if ([self countOfCheckArray] > 1) {
                self.titleLabel.text = [NSString stringWithFormat:@"%lu Pictures Selected", (unsigned long)[self countOfCheckArray]];
            } else {
                self.titleLabel.text = [NSString stringWithFormat:@"%lu Picture Selected", (unsigned long)[self countOfCheckArray]];
            }
        }
        
        [self setOperatePictureButton];
    }
}

- (NSUInteger)countOfCheckArray {
    NSUInteger count = 0;
    for (NSDictionary *dic in self.checkArray) {
        if ([[dic objectForKey:@"checked"] isEqualToString:@"YES"]) {
            count ++;
        }
    }
    return count;
}

//#pragma mark - UIDocumentInteractionControllerDelegate
//
//- (NSString *)applicationDocumentsDirectory
//{
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//}
//
//- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
//{
//    return self;
//}


//#pragma mark - QLPreviewControllerDataSource
//
//// Returns the number of items that the preview controller should preview
//- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
//{
//    return 1;
//}
//
//- (void)previewControllerDidDismiss:(QLPreviewController *)controller
//{
//    // if the preview dismissed (done button touched), use this method to post-process previews
//}
//
//// returns the item that the preview controller should preview
//- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
//{
//    NSURL *fileURL = nil;
//    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDir = [documentPaths objectAtIndex:0];
//    NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:selectedIndexPath.row]];
//    fileURL = [NSURL fileURLWithPath:path];
//    return fileURL;
//}

//#pragma mark - UINavigationControllerDelegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if ([viewController isEqual:self])
//    {
//        navigationController.navigationBarHidden = YES;
//    }
//    
//    if(navigationController.viewControllers.count == 2)
//    {
//        navigationController.navigationBarHidden = NO;
//    }
//}

#pragma mark - MJRefreshBaseViewDelegate

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView {
    if (![self.refreshHeaderView isRefreshing]) {
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
    }
}

- (void)loadData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    self.dirArray = [[NSMutableArray alloc] init];
    self.checkArray = [[NSMutableArray alloc] init];
    for (NSString *file in fileList)
    {
        [self.dirArray addObject:file];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"NO" forKey:@"checked"];
        [self.checkArray addObject:dic];
    }
    
    [self reloadTable];
}

- (void)reloadTable {
    [self.refreshHeaderView endRefreshing];
    
    if ([self.rightBarButtonItem.title isEqualToString:@"Cancel"]) {
        if ([self.rightBarButtonItem.title isEqual:@"Cancel"] && [self.leftBarButtonItem.title isEqual:@"Cancel All"]) {
            [self.leftBarButtonItem setTitle:@"Select All"];
            [self.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        }
        self.titleLabel.text = @"Select Items";
        
        [self setOperatePictureButton];
    }
    
    [self.tableView reloadData];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"] && actionSheet.tag == 1) {
        dispatch_group_t group = dispatch_group_create();
        
        NSDate *startTime = [NSDate date];
//        dispatch_queue_t serialQueue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t serialQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *savedFlagDic = [defaults dictionaryForKey:savedFlagDictionary].mutableCopy;
        if ([savedFlagDic count] == 0) {
            savedFlagDic = [[NSMutableDictionary alloc] init];
        }
        
        for (int i = 0; i < [self.checkArray count]; i++) {
            if (buttonIndex == 1 && [[savedFlagDic objectForKey:[self.dirArray objectAtIndex:i]] isEqualToString:@"Saved"]) {
                continue;
            }
            
            NSMutableDictionary *dic = [self.checkArray objectAtIndex:i];
            if ([[dic objectForKey:@"checked"] isEqualToString:@"YES"]) {
                UIImage *image = [[UIImage alloc] init];
                NSURL *fileURL = nil;
                NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDir = [documentPaths objectAtIndex:0];
                NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:i]];
                fileURL = [NSURL fileURLWithPath:path];
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:fileURL]];
                
                dispatch_group_async(group, serialQueue, ^{
                    [self saveImageToPhotos:image];
                });
                [savedFlagDic setObject:@"Saved" forKey:[self.dirArray objectAtIndex:i]];
                [defaults setObject:savedFlagDic forKey:savedFlagDictionary];
                
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        NSDate *endTime = [NSDate date];
        NSTimeInterval timeInterval = [endTime timeIntervalSinceDate:startTime];
        NSLog(@"Time taken to saveImageToPhotos concurrently = %f seconds", timeInterval);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Save Pictures success"
                                                       delegate:self
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
//        [self loadData];
    }
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"] && actionSheet.tag == 2) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *savedFlagDic = [defaults dictionaryForKey:savedFlagDictionary].mutableCopy;
        if ([savedFlagDic count] == 0) {
            savedFlagDic = [[NSMutableDictionary alloc] init];
        }
        
        for (int i = 0; i < [self.checkArray count]; i++) {
            if (buttonIndex == 1 && ![[savedFlagDic objectForKey:[self.dirArray objectAtIndex:i]] isEqualToString:@"Saved"]) {
                continue;
            }
            
            NSMutableDictionary *dic = [self.checkArray objectAtIndex:i];
            if ([[dic objectForKey:@"checked"] isEqualToString:@"YES"]) {
                NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDir = [documentPaths objectAtIndex:0];
                NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:i]];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if ([fileManager fileExistsAtPath:path]) {
                    if ([fileManager removeItemAtPath:path error:nil]) {
                        //                    [self.dirArray removeObjectAtIndex:i];
                        //                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                    }
                }
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Delete Pictures success"
                                                       delegate:self
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self loadData];
    }
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subView;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end
