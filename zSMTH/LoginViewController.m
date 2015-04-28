//
//  LoginViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-11.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "LoginViewController.h"
#import "SMTHHelper.h"
#import "ZSMTHSetting.h"
#import "REFrostedRootViewController.h"
#import "LeftMenuViewController.h"
#import "NavigationViewController.h"
#import "GuidanceTableViewController.h"

@interface LoginViewController ()
{
    REFrostedRootViewController *rootView;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self.editUsername setText:setting.username];
    if(setting.bSavePassword) {
        [self.editPassword setText:setting.password];
    }
    self.switchAutoLogin.on = setting.bAutoLogin;
    self.switchSavePassword.on = setting.bSavePassword;
    
    if(setting.bAutoLogin){
        self.progressTitle = @"自动登录中...";
        [self startAsyncTask];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // show network connection status
//    SMTHHelper *helper = [SMTHHelper sharedManager];
    [helper updateNetworkStatus];
    if(helper.nNetworkStatus == -1){
        [self.netStatus setText:@"没有网络"];
    } else if(helper.nNetworkStatus == 0){
        [self.netStatus setText:@"WLAN"];
    } else if(helper.nNetworkStatus == 1){
        [self.netStatus setText:@"移动网络"];
    }
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickAutoLogin:(id)sender {
    if(self.switchAutoLogin.on){
        self.switchSavePassword.on = YES;
    }
}

- (IBAction)login:(id)sender
{
    self.progressTitle = @"登录中...";
    [self startAsyncTask];
}

- (void)asyncTask
{
    setting.username = [self.editUsername text];
    setting.password = [self.editPassword text];
    setting.bSavePassword = self.switchSavePassword.on;
    setting.bAutoLogin = self.switchAutoLogin.on;
    
    NSLog(@"%@", setting);
    
    [helper login:[self.editUsername text] password:[self.editPassword text]];
}

- (void)finishAsyncTask
{
    if(!helper.isLogined)
    {
        [self.loginFeedback setHidden:NO];
        [self performSelector:@selector(hideLoginFeedbackLater) withObject:nil afterDelay:2.0f];
    }
    else {
        if(!rootView){
            rootView = [self.storyboard instantiateViewControllerWithIdentifier:@"REFrostedRootViewController"];
        }
        [self presentViewController:rootView animated:YES completion:nil];
    }
}

- (void)hideLoginFeedbackLater
{
    [self.loginFeedback setHidden:YES];
}


- (IBAction)cancel:(id)sender {
    // 回到rootView
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self exitApplication];
}

- (void)exitApplication {
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

@end
