//
//  PostListTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-20.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ExtendedTableViewController.h"
#import "SINavigationMenuView.h"

@interface PostListTableViewController : ExtendedTableViewController <SINavigationMenuDelegate>

@property (strong, nonatomic) NSString *engName;
@property (strong, nonatomic) NSString *chsName;
@property (nonatomic) long boardID;

- (IBAction)return:(id)sender;
- (IBAction)newPost:(id)sender;

@end
