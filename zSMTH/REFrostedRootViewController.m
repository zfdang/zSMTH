//
//  ViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-6.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "REFrostedRootViewController.h"
#import "SMTHHelper.h"
#include "JDStatusBarNotification.h"

@interface REFrostedRootViewController ()
{
    NSTimer *myTimer;
    SMTHHelper *helper;
    
    BOOL isConnectionActive;
    BOOL hasNewMail;
}

@end

@implementation REFrostedRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGSize size = CGSizeMake(180.0, 0.0);
    self.menuViewSize = size;
    helper = [SMTHHelper sharedManager];

    // 监听激活、暂停的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Periodical Checking Tasks

- (void) applicationDidBecomeActive {
//    NSLog(@"LeftMenuViewController: applicationDidBecomeActive");

    // 开启定时器，检查新邮件
    if(myTimer == nil){
        //每120秒运行一次function方法。
        myTimer =  [NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
    } else {
        //重启定时器
        [myTimer setFireDate:[NSDate distantPast]];
    }
}

- (void) applicationDidEnterBackground{
//    NSLog(@"LeftMenuViewController: applicationDidEnterBackground");
    //关闭定时器
    [myTimer setFireDate:[NSDate distantFuture]];
}

- (void) timerTask {
    // 异步的方式运行，防止阻塞主线程
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
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
