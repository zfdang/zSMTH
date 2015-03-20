//
//  PostListTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-20.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ExtendedTableViewController.h"

@interface PostListTableViewController : ExtendedTableViewController

@property (strong, nonatomic) NSString *boardID;
@property (strong, nonatomic) NSString *boardName;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

- (IBAction)return:(id)sender;
- (IBAction)newPost:(id)sender;

@end
