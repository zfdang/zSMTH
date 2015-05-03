//
//  NavigationViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "NavigationViewController.h"
#import "ZSMTHSetting.h"

@interface NavigationViewController ()
{
    ZSMTHSetting *setting;
}

@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    setting = [ZSMTHSetting sharedManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// http://stackoverflow.com/questions/12996293/io6-doesnt-call-boolshouldautorotate
- (BOOL)shouldAutorotate {
    NSLog(@"Auto Rotate = %d", setting.bAutoRotate);
    return setting.bAutoRotate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
