//
//  AttachSelectorTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-13.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateAttachmentsProtocol.h"


@interface AttachSelectorTableViewController : UITableViewController

- (IBAction)finish:(id)sender;
- (IBAction)select:(id)sender;

@property (nonatomic, copy) NSArray *mAssets;

@property (weak, nonatomic) id<UpdateAttachmentsProtocol> delegate;

@end
