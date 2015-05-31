//
//  AboutViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-5-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *version = [[[NSBundle mainBundle] infoDictionary]
                         objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary]
                       objectForKey:@"CFBundleVersion"];
    self.textVersion.text = [NSString stringWithFormat:@"版本号: %@ (%@)", version, build];
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

- (IBAction)visitWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://zsmth.zfdang.com"]];
}
@end
