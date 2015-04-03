//
//  FavoriteTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedTableViewController.h"
#import "LoginCompletionProtocol.h"

@interface FavoriteTableViewController : ExtendedTableViewController <LoginCompletionProtocol>

@property (nonatomic) long favoriteRootID;
@property (strong, nonatomic) NSString *favoriteRootName;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;

@end
