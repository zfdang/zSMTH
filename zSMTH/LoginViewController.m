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
#include "JDStatusBarNotification.h"

@interface LoginViewController ()
{
    REFrostedRootViewController *rootView;

    // 定期任务需要的参数
    NSTimer *myTimer;
    BOOL isConnectionActive;
    BOOL hasNewMail;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 从设置从读取保存的输入和设置
    [self.editUsername setText:setting.username];
    if(setting.bSavePassword) {
        [self.editPassword setText:setting.password];
    }
    self.switchAutoLogin.on = setting.bAutoLogin;
    self.switchSavePassword.on = setting.bSavePassword;
    NSLog(@"Setting status: %@", setting);

    // 监听激活、暂停的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];

    // 自动登录
    if(setting.bAutoLogin){
        self.progressTitle = @"自动登录中...";
        [self startAsyncTask];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // show network connection status
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
        // “自动登录”会强制打开“保存密码”
        self.switchSavePassword.on = YES;
    }
}

- (void) saveStatus {
    // 保存设置
    setting.bSavePassword = self.switchSavePassword.on;
    setting.bAutoLogin = self.switchAutoLogin.on;

    // 保存用户名
    setting.username = [self.editUsername text];

    // 如果设置了保存密码，则保存；否则清空保存的密码
    if(setting.bSavePassword){
        setting.password = [self.editPassword text];
    } else {
        setting.password = @"";
    }
}

- (IBAction)login:(id)sender
{
    [self saveStatus];

    self.progressTitle = @"登录中...";
    [self startAsyncTask];
}

- (void)asyncTask
{
    NSLog(@"%@", setting);
    [helper login:[self.editUsername text] password:[self.editPassword text]];
}

- (void)finishAsyncTask
{
    if(!helper.isLogined) {
        [self.loginFeedback setHidden:NO];
        [self performSelector:@selector(hideLoginFeedbackLater) withObject:nil afterDelay:2.0f];
    } else {
        // 进入主界面
        if(!rootView) {
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
    [self saveStatus];

    // 退出
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

#pragma mark - Periodical Checking Tasks

- (void) applicationDidBecomeActive {
    NSLog(@"applicationDidBecomeActive");
    // 开启定时器，检查新邮件
    if(myTimer == nil){
        //每120秒运行一次function方法。
        myTimer =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
    } else {
        //重启定时器
        [myTimer setFireDate:[NSDate distantPast]];
    }
}

- (void) applicationDidEnterBackground{
    NSLog(@"applicationDidEnterBackground");
    //关闭定时器
    [myTimer setFireDate:[NSDate distantFuture]];
}

- (void) timerTask {
    // 异步的方式运行，防止阻塞主线程
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if(helper.isLogined) {
            // 检查登录状态
            isConnectionActive = [helper isConnectionActive];
            NSLog(@"Status of Login Token: %d", isConnectionActive);

            // 检查新邮件
            hasNewMail = [helper hasNewMail];
            NSLog(@"Status of newMail: %d", hasNewMail);

            // 结果放到主线程里展示
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf postTimerTask];
            });
        }
    });
}

- (void) postTimerTask {
    if(isConnectionActive == NO){
        [JDStatusBarNotification showWithStatus:@"当前连接已失效，请重新登录!"
                                   dismissAfter:3.0
                                      styleName:JDStatusBarStyleError];
        return;
    }

    if(hasNewMail){
        [JDStatusBarNotification showWithStatus:@"您有新邮件，请及时查看!"
                                   dismissAfter:3.0
                                      styleName:JDStatusBarStyleError];
        return;
    }
}

@end
