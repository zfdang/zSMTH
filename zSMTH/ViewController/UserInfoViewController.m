//
//  UserInfoViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UserInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoTableViewCell.h"
#import "LoginViewController.h"
@import MobileCoreServices;
#import "UIImage+Resize.h"

@interface UserInfoViewController ()
{
    // 0: 显示当前登录用户的信息
    // 1: 在用户信息界面，查询其他用户的信息 ==> 这个只会从内部触发
    // 2: 在帖子内容处，点击查询用户信息按钮
    // 3: 退出当前登录用户 ==> 这个只会从内部触发
    int taskType;
    NSString* userID;

    SMTHUser *user;
}

@end

@implementation UserInfoViewController

- (void) setQueryTask:(int)_taskType userID:(NSString*) _userID
{
    // taskType 只会是0或者2
    taskType = _taskType;
    userID = _userID;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.imageAvatar.layer.cornerRadius = 30.0;
    self.imageAvatar.layer.borderWidth = 0;
    self.imageAvatar.clipsToBounds = YES;

    // enable single tap on imager
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarClicked)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageAvatar setUserInteractionEnabled:YES];
    [self.imageAvatar addGestureRecognizer:singleTap];
    
    if(taskType == 0) {
        // do nothing here
    } else if (taskType == 2) {
        // 隐藏左按钮，右按钮显示revert图标
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setHidesBackButton:YES];
//        [self.navigationItem setRightBarButtonItem:nil];
        [self.buttonRight setImage:[UIImage imageNamed:@"revert"]];
        self.editUserID.enabled = NO;
    }
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // set userinfo
    if(taskType == 0) {
        // 查询当前登录用户的详细信息, 这时候userID is nil
        [self.imageAvatar sd_setImageWithURL:[helper.user getFaceURL]
                            placeholderImage:[UIImage imageNamed:@"anonymous"]
                                     options:SDWebImageRefreshCached];

        self.labelID.text = helper.user.userID;
        self.labelNick.text = helper.user.userNick;
        self.labelLevel.text = [helper.user getLifeLevel];

        self.progressTitle = @"加载信息中...";
        userID = helper.user.userID;
        [self startAsyncTask];
    } else if (taskType == 2) {
        // 查询传递进来的用户ID的详细信息
        [self.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:userID]
                            placeholderImage:[UIImage imageNamed:@"anonymous"]
                                     options:SDWebImageRefreshCached];
        self.labelID.text = userID;
        self.progressTitle = @"查询信息中...";
        [self startAsyncTask];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRightButton:(id)sender {
    if(taskType == 0) {
        // 显示的是当前用户的信息，按钮的作用是退出
        taskType = 3;
        self.progressTitle = @"退出中...";
        [self startAsyncTask];
    } else if(taskType == 1) {
        // 在用户信息页查询其他用户信息
        // 显示的是查询用户的信息，按钮的作用是返回到当前用户信息页
        taskType = 0;
        self.progressTitle = @"加载信息中...";
        userID = helper.user.userID;
        [self startAsyncTask];
    } else if(taskType == 2) {
        // 从帖子处查询用户信息，按钮的作用是关闭用户信息view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doSearch:(id)sender {
    if(taskType == 2) {
        // 在帖子处查询用户时，禁止再做查询
        return;
    }
    taskType = 1;
    self.progressTitle = @"查询用户中...";
    NSString *username = [[self.editUserID text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    userID = username;
    [self startAsyncTask];
}

#pragma mark - ExpandedTableView -- async task

- (void)asyncTask
{
    // now different async task is distinguished by taskType, which is unsafe
    // it's better to add parameter to startAsyncTask->asyncTask->finishAsyncTask
    if(taskType == 0 || taskType == 1 || taskType == 2){
        user = [helper getUserInfo:userID];
    } else if(taskType == 3)
    {
        [helper logout];
    }
}

- (void)finishAsyncTask
{
    if(taskType == 3) {
        // 当上一个任务是退出，并且用户已经退出时，显示登录窗口
        [self.frostedViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    // 更新查询到的用户信息
    [self.imageAvatar sd_setImageWithURL:[user getFaceURL] placeholderImage:[UIImage imageNamed:@"anonymous"]];
    self.imageAvatar.layer.cornerRadius = 30.0;
    self.imageAvatar.layer.borderWidth = 0;
    self.imageAvatar.clipsToBounds = YES;
    
    self.labelID.text = user.userID;
    self.labelNick.text = user.userNick;
    self.labelLevel.text = [user getLifeLevel];
    
    // update tableview infors
    [self.tableView reloadData];
    
    // update icon of right button
    if(taskType == 0){
        // 显示的是登录用户的信息，显示退出按钮
        [self.buttonRight setImage:[UIImage imageNamed:@"logout"]];
    } else {
        // 从信息页查询其他用户
        // 或者从帖子出查询其他用户
        // 都显示revert按钮
        [self.buttonRight setImage:[UIImage imageNamed:@"revert"]];
    }
}


#pragma mark - UITableViewDelegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserInfoTableViewCell";
    
    UserInfoTableViewCell *cell = (UserInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (UserInfoTableViewCell*)[nibArray objectAtIndex:0];
    }
    
    if (indexPath.section == 0) {
        if(user == nil){
            cell.rowLabel.text = @"属性";
            cell.rowValue.text = @"值";
        } else {
            if(indexPath.row == 0){
                cell.rowLabel.text = @"性别";
                cell.rowValue.text = user.userGender;
            } else if (indexPath.row == 1){
                cell.rowLabel.text = @"年龄";
                cell.rowValue.text = user.userAge;
            } else if (indexPath.row == 2){
                cell.rowLabel.text = @"论坛身份";
                cell.rowValue.text = user.userTitle;
            } else if (indexPath.row == 3){
                cell.rowLabel.text = @"";
                cell.rowValue.text = @"";
            } else if (indexPath.row == 4){
                cell.rowLabel.text = @"注册时间";
                cell.rowValue.text = user.firstLogin;
            } else if (indexPath.row == 5){
                cell.rowLabel.text = @"上次登录";
                cell.rowValue.text = user.lastLogin;
            } else if (indexPath.row == 6){
                cell.rowLabel.text = @"登陆次数";
                cell.rowValue.text = user.totalLogins;
            } else if (indexPath.row == 7){
                cell.rowLabel.text = @"帖子总数";
                cell.rowValue.text = user.totalPosts;
            } else if (indexPath.row == 8){
                cell.rowLabel.text = @"积分";
                cell.rowValue.text = user.userScore;
            }
        }
    }
    
    return cell;
}

// remove leading space of separator in tableview
// http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working/25788003#25788003
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Avatar Modification Methods

-(void)userAvatarClicked {
    NSLog(@"single Tap on user avatar or username");
    if([user.userID compare:helper.user.userID] == NSOrderedSame) {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:@"更改头像"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
        [choiceSheet showInView:self.view];
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {

    // 得到裁剪后的图片
    NSString *tempfile = [setting getAttachmentFilepath:@"avatar.jpg"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [manager removeItemAtPath:tempfile error:&error];
    NSLog(@"tempfile for avatar is %@, removal is %d", tempfile, result);

    CGSize size = CGSizeMake(500, 500);
    UIImage *sizedImage = [UIImage imageWithImage:editedImage scaledToFitToSize:size];
    NSLog(@"Image resized from %f*%f ==> %f*%f", editedImage.size.width, editedImage.size.height, sizedImage.size.width, sizedImage.size.height);

    // find proper compression ratio
    CGFloat qs = 1.0f;
    CGFloat max_size = 200 * 1024; // 200k
    NSData * data = UIImageJPEGRepresentation(sizedImage, 1.0);
    int cur_size = (int)[data length];
    //            int resized_size = cur_size;
    while(cur_size > max_size && qs > 0.1f){
        qs -= 0.1f;
        data = UIImageJPEGRepresentation(sizedImage, qs);
        cur_size = (int)[data length];
    }
    
    // write image to temp file
    [UIImageJPEGRepresentation(sizedImage, qs) writeToFile:tempfile atomically:YES];

    // 上载到服务器
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [helper.smth net_modifyFace:tempfile];
        // 更新头像
        [self.imageAvatar sd_setImageWithURL:[helper.user getFaceURL]
                                placeholderImage:[UIImage imageNamed:@"anonymous"]
                                         options:SDWebImageRefreshCached];
    });

    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark camera utility

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

@end
