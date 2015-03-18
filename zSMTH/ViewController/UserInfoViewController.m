//
//  UserInfoViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UserInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [helper.user getFaceURL]
    [self.userAvatar sd_setImageWithURL:[helper.user getFaceURL]];
    
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

- (IBAction)showLeftMenu:(id)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    [self.frostedViewController presentMenuViewController];    
}
@end
