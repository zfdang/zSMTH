//
//  ViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-6.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "REFrostedRootViewController.h"
#import "SMTHHelper.h"

@interface REFrostedRootViewController ()
{
    NSTimer *myTimer;
    SMTHHelper *helper;
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
    NSLog(@"LeftMenuViewController: applicationDidBecomeActive");

    // 检查登录状态，如果连接已失效，提示重新登录
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        BOOL active = [helper isConnectionActive];
        NSLog(@"Current Login Status: %d", active);
        if(active == NO){
            
        }
    });

    // 开启定时器，检查新邮件
    if(myTimer == nil){
        //每1秒运行一次function方法。
        myTimer =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
    } else {
        //开启定时器
        [myTimer setFireDate:[NSDate distantPast]];
    }
}

- (void) applicationDidEnterBackground{
    NSLog(@"LeftMenuViewController: applicationDidEnterBackground");
    //关闭定时器
    [myTimer setFireDate:[NSDate distantFuture]];
}

- (void) timerTask {
    NSLog(@"timerTask");
}

@end
