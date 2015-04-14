//
//  ExtendedUIViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-13.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ExtendedUIViewController.h"
#import "LeftMenuViewController.h"

@interface ExtendedUIViewController ()
{
}
@end



@implementation ExtendedUIViewController

@synthesize progressTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    helper = [SMTHHelper sharedManager];
    setting = [ZSMTHSetting sharedManager];
    self.progressTitle = @"加载中...";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startAsyncTask
{
    [helper.smth reset_status];
    
    progressBar = [[MBProgressHUD alloc] initWithView:self.view];
    progressBar.mode = MBProgressHUDModeIndeterminate;
    progressBar.delegate = self;
    progressBar.labelText = self.progressTitle;
    
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HudTapped)];
    //    tap.delegate = self;
    //    [progressBar addGestureRecognizer:tap];
    [self.view addSubview:progressBar];
    
    [progressBar showWhileExecuting:@selector(asyncTask) onTarget:self withObject:nil animated:YES];
}


- (void)asyncTask
{
    NSLog(@"asyncTask");
}

- (void)finishAsyncTask
{
    
}

#pragma mark MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [self finishAsyncTask];
}

- (IBAction)showLeftMenu:(id)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    LeftMenuViewController *menuController = (LeftMenuViewController*)self.frostedViewController.menuViewController;
    [menuController refreshTableHeadView];
    [self.frostedViewController presentMenuViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
