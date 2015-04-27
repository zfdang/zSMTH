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

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1200);
    
    // Load git version from plist
    // http://feinstruktur.com/blog/2010/12/29/integrating-git-version-info-in-ioscocoa-apps
    NSString *version = [[[NSBundle mainBundle] infoDictionary]
                         objectForKey:@"CFBundleVersion"];
    self.txtVersion.text = version;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) updateCacheSize
{
    //获取SD的缓存
    __weak typeof(self) weakSelf = self;
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        NSLog(@"SDWebImage cache size = %ld", totalSize);
        weakSelf.txtCacheSize.text = [NSString stringWithFormat:@"图片缓存 (%6ldM)", totalSize/1024/1024];
    }];
}

- (IBAction)clickLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchUserAvatar:(id)sender {
    
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
