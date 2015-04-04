//
//  LeftMenuViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedTableViewController.h"

typedef enum {
    VIEW_GUIDANCE = 0,
    VIEW_FAVORITE,
    VIEW_LOGIN,
    VIEW_USER_INFO,
    VIEW_POST_LIST,
    VIEW_BOARD_LIST,
} SMTHVIEW;

@interface LeftMenuViewController : ExtendedTableViewController

-(void)switchViewto:(SMTHVIEW)target;
-(void)refreshTableHeadView;

@end
