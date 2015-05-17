//
//  LeftMenuViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ExtendedTableViewController.h"

typedef enum {
    VIEW_GUIDANCE = 0,
    VIEW_FAVORITE,
    VIEW_LOGIN,
    VIEW_USER_INFO,
    VIEW_BOARD_LIST,
    VIEW_MAIL,
    VIEW_NOTIFICATION,
    VIEW_SETTING,
    VIEW_ABOUT,
} SMTHVIEW;

@interface LeftMenuViewController : UITableViewController

-(void)switchViewto:(SMTHVIEW)target;

@end
