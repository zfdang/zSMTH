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

@interface LoginViewController ()

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
    
//    NSLog(@"%@", setting);
    
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
        if(self.delegate){
            [self.delegate refreshViewAfterLogin];
        }
        
        // return to upstream view
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)hideLoginFeedbackLater
{
    [self.loginFeedback setHidden:YES];
}


- (IBAction)cancel:(id)sender {
    // 回到rootView
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
