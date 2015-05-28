//
//  AppDelegate.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-6.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "UMSocial.h"
#import "UMSocialConfig.h"
#import "UMSocialWechatHandler.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MobClick startWithAppkey:@"553c8da267e58e541b00334f" reportPolicy:BATCH   channelId:nil];
    [UMSocialData setAppKey:@"553c8da267e58e541b00334f"];

    // 由于苹果审核政策需求，建议大家对未安装客户端平台进行隐藏，在设置QQ、微信AppID之前调用下面的方法
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    // 添加微信及朋友圈到分享列表
    [UMSocialWechatHandler setWXAppId:@"wx9c391da83dcb85ea" appSecret:@"4eed35a5647938b35ea9a0ecef01e549" url:@"http://zsmth.zfdang.com"];

    // 使用git version作为版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary]
                         objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];

    // force app to launch in portrait mode only
    // this mode will be changed later after guidance view is loaded
    self.supportedOrientations = UIInterfaceOrientationMaskPortrait;

    // 提醒开启notification
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return self.supportedOrientations;
}
@end
