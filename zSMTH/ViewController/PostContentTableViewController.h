//
//  PostContentTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-22.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ExtendedTableViewController.h"
#import "RefreshTableViewProtocol.h"

@interface PostContentTableViewController : ExtendedTableViewController <RefreshTableViewProtocol>

@property (strong, nonatomic) NSString *boardName;
@property (strong, nonatomic) NSString *postSubject;
@property (nonatomic) long postID;


- (IBAction)return:(id)sender;

@end
