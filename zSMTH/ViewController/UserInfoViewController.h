//
//  UserInfoViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"


@interface UserInfoViewController : ExtendedUIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelID;
@property (weak, nonatomic) IBOutlet UILabel *labelNick;
@property (weak, nonatomic) IBOutlet UILabel *labelLevel;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
