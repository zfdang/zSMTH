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
#import "JDStatusBarNotification.h"
#import "Reachability.h"

@interface LoginViewController ()
{
    REFrostedRootViewController *rootView;

    // 定期任务需要的参数
    NSTimer *myTimer;
    BOOL isConnectionActive;
    int newMailCount;
    BOOL isReconnectSuccsss;

    Reachability *reach;

    // 保存登录的结果，用来显示错误信息
    int loginResult;
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
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];


    // 开始监控网络状态
    // Initialize Reachability
    reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    // Start Monitoring
    BOOL notifier = [reach startNotifier];
    NSLog(@"%d", notifier);
    //to catch network status.
//    NSLog(@"%@", kReachabilityChangedNotification);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    // enable click on banner
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerClick)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageBanner setUserInteractionEnabled:YES];
    [self.imageBanner addGestureRecognizer:singleTap];

    // 自动登录
    if(setting.bAutoLogin && setting.username && setting.password){
        self.progressTitle = @"自动登录中...";
        [self startAsyncTask];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // show network connection status
    [self updateNetworkStatus:[reach currentReachabilityStatus]];

    [super viewWillAppear:animated];
}

// 此viewcontroller禁止旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reachability monitoring

- (void)reachabilityDidChange:(NSNotification *)notification {
    [self updateNetworkStatus:[reach currentReachabilityStatus]];
}

- (void) updateNetworkStatus:(NetworkStatus) nstatus {
    switch (nstatus) {
        case NotReachable:
            [self.netStatus setText:@"无网络"];
            break;
        case ReachableViaWiFi:
            [self.netStatus setText:@"WIFI"];
            break;
        case ReachableViaWWAN:
            [self.netStatus setText:@"Mobile"];
            break;
        default:
            break;
    }
}

#pragma mark - Login buttons

- (void) bannerClick
{
    NSString* url = @"http://zsmth.zfdang.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


- (IBAction)clickAutoLogin:(id)sender {
    if(self.switchAutoLogin.on){
        // “自动登录”会强制打开“保存密码”
        self.switchSavePassword.on = YES;
    }
    setting.bSavePassword = self.switchSavePassword.on;
    setting.bAutoLogin = self.switchAutoLogin.on;
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

    [self.loginFeedback setHidden:YES];
    self.progressTitle = @"登录中...";
    [self startAsyncTask];
}

- (IBAction)clear:(id)sender {
    self.editUsername.text = @"";
    self.editPassword.text = @"";

    [self saveStatus];
}

#pragma mark - Async tasks

- (void)asyncTask
{
    NSLog(@"%@", setting);
    NSString *username = [[self.editUsername text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    loginResult = [helper login:username password:[self.editPassword text]];
}

- (void)finishAsyncTask
{
    if(helper.user == nil) {
        // 登录失败，显示错误信息
        // http://trac.kcn.cn/kbs/wiki/smthappDevAPIError
        if(loginResult == -1){
            self.loginFeedback.text = @"网络错误，请稍后重试...";
        } else if(loginResult <=-2 && loginResult >= -10) {
            self.loginFeedback.text = @"服务器错误，请稍后重试...";
        } else if(loginResult == 10010) {
            self.loginFeedback.text = @"帐号密码错误，请重试...";
        } else {
            self.loginFeedback.text = @"登录失败，错误类型未知，请重试...";
        }
        [self.loginFeedback setHidden:NO];
        [self performSelector:@selector(hideLoginFeedbackLater) withObject:nil afterDelay:15.0f];
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

// 退出程序的方法，但是已经不被提倡了
//- (void)exitApplication {
//    [UIView beginAnimations:@"exitApplication" context:nil];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.window cache:NO];
//    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
//    self.view.window.bounds = CGRectMake(0, 0, 0, 0);
//    [UIView commitAnimations];
//}
//
//- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    if ([animationID compare:@"exitApplication"] == 0) {
//        exit(0);
//    }
//}


#pragma mark - Periodical Checking Tasks

- (void) applicationDidBecomeActive {
    NSLog(@"applicationDidBecomeActive");
    // 开启定时器，检查新邮件
    if(myTimer == nil){
        //每120秒运行一次function方法。
        myTimer =  [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
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
    // 只有当login view被放置在后台时，做定时的检查
    if(self.presentedViewController == nil){
        // NSLog(@"in Login view, skip background checking.");
        return;
    }

    // 异步的方式运行，防止阻塞主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        isConnectionActive = [helper isConnectionActive];
        NSLog(@"Login Token: %d, helper.user is %@", isConnectionActive, helper.user);

        if(!isConnectionActive){
            // 连接已经失效，清空用户，在LeftMenuViewController里会做响应
            helper.user = nil;
        }

        isReconnectSuccsss = NO;
        // 如果连接已经失效，并且允许自动登录，则自动登录
        // 有时候isConnectionActive == YES, 但是user并没有生成，所以这时候，需要再次登录一次，以获取用户信息
        if(!isConnectionActive || helper.user == nil) {
            if(setting.bAutoLogin) {
                [helper login:[self.editUsername text] password:[self.editPassword text]];
                if(helper.user) {
                    // 设置自动重连成功的提示信息
                    isReconnectSuccsss = YES;
                }
            }
        }

        // 检查新邮件, 等到token状态是YES时再检查
        if(isConnectionActive) {
            newMailCount = [helper hasNewMail];
            NSLog(@"Status of newMail: %d", newMailCount);
        } else {
            newMailCount = 0;
        }

        // 结果放到主线程里展示
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postTimerTask];
        });
    });
}

- (void) postTimerTask {
    if(isReconnectSuccsss) {
        [JDStatusBarNotification showWithStatus:@"自动重新登录成功!"
                                   dismissAfter:3.0
                                      styleName:JDStatusBarStyleSuccess];
        return;
    }

    if(isConnectionActive == NO){
        [JDStatusBarNotification showWithStatus:@"当前连接已失效，请重新登录!"
                                   dismissAfter:3.0
                                      styleName:JDStatusBarStyleError];
        return;
    }

    if(newMailCount > 0){
        // 使用状态栏来提示新邮件，每隔5次查询提醒一次
        static int alert_counter = 0;
        if(alert_counter == 0) {
            [JDStatusBarNotification showWithStatus:@"您有新邮件，请及时查看!"
                                       dismissAfter:3.0
                                          styleName:JDStatusBarStyleSuccess];
        }
        alert_counter += 1;
        if(alert_counter == 5) {
            alert_counter = 0;
        }

        // 根据newMailCount来决定是否要增加新的notification
        if(newMailCount > [UIApplication sharedApplication].applicationIconBadgeNumber) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            // localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
            // localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.alertBody = [NSString stringWithFormat:@"您有%d封新邮件，请及时查看!",newMailCount];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            // localNotification.applicationIconBadgeNumber = newMailCount;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
    // 更新badgeNumber
    if(newMailCount != [UIApplication sharedApplication].applicationIconBadgeNumber) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newMailCount];
    }
    return;
}

@end
