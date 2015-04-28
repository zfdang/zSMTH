//
//  ExtendedTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-13.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SMTHHelper.h"
#import "ZSMTHSetting.h"
#import "REFrostedViewController.h"
#import "ExtendNSLogFunctionality.h"

@interface ExtendedTableViewController : UITableViewController <MBProgressHUDDelegate>
{
    SMTHHelper *helper;
    ZSMTHSetting *setting;
}

@property (strong, nonatomic) NSString* progressTitle;
/*
 * default: init m_progressBar;
 * subclass: don't overwrite this in most cases.
 */
-(void)startAsyncTask:(NSMutableDictionary*)params;


/*
 * flow: This function is called in startAsyncTask()
 * default: do nothing;
 * subclass: do real network operations.
 */
- (void)asyncTask:(NSMutableDictionary*) params;


/*
 * flow: This function is called after asyncTask() done.
 * default: do nothing;
 * subclass: [m_tableView reloadData] if use tableView.
 */
- (void)finishAsyncTask:(NSDictionary*) resultParams;

- (IBAction)showLeftMenu:(id)sender;

@end
