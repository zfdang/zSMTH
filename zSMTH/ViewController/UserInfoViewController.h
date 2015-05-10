//
//  UserInfoViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"
#import "VPImageCropperViewController.h"

@interface UserInfoViewController : ExtendedUIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelID;
@property (weak, nonatomic) IBOutlet UILabel *labelNick;
@property (weak, nonatomic) IBOutlet UILabel *labelLevel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonRight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonLeft;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *editUserID;

- (IBAction)clickRightButton:(id)sender;
- (IBAction)doSearch:(id)sender;

- (void) setQueryTask:(int)taskType userID:(NSString*) userID;

@end
