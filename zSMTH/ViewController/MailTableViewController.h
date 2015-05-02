//
//  MailTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-29.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedTableViewController.h"
#import "SINavigationMenuView.h"

@interface MailTableViewController : ExtendedTableViewController <SINavigationMenuDelegate>

- (IBAction)clickRightButton:(id)sender;

@end
