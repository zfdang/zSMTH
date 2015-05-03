//
//  SettingViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-15.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SettingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Toast.h"
#import "ZSMTHSetting.h"


@interface SettingViewController ()
{
    ZSMTHSetting *setting;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1200);
    
    setting = [ZSMTHSetting sharedManager];

    // Load git version from plist
    // http://feinstruktur.com/blog/2010/12/29/integrating-git-version-info-in-ioscocoa-apps
    NSString *version = [[[NSBundle mainBundle] infoDictionary]
                         objectForKey:@"CFBundleShortVersionString"];
    self.txtVersion.text = version;

    // read initial values from settings
    self.bShowAvatar.on = setting.bShowAvatar;
    self.bAutoRotate.on = setting.bAutoRotate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateCacheSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateCacheSize
{
    //获取SD的缓存
    __weak typeof(self) weakSelf = self;
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        NSLog(@"SDWebImage cache size = %lu", (unsigned long)totalSize);
        weakSelf.txtCacheSize.text = [NSString stringWithFormat:@"%luM", (unsigned long)totalSize/1024/1024];
    }];
}

- (IBAction)clickLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setting Buttons

- (IBAction)switchUserAvatar:(id)sender {
    setting.bShowAvatar = self.bShowAvatar.on;
    NSLog(@"Setting = %@", setting);
}

- (IBAction)switchAutoRotate:(id)sender {
    setting.bAutoRotate = self.bAutoRotate.on;
    NSLog(@"Setting = %@", setting);
}

- (IBAction)clearCache:(id)sender {
    NSLog(@"Clear SDWebImage Cache");
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    
    [self.view makeToast:@"缓存已清空!"];

    [self updateCacheSize];
}


@end
