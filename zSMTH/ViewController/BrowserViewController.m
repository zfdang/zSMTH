//
//  BrowserViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-5-4.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@end

@implementation BrowserViewController

@synthesize targetURL;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.title = [self.targetURL absoluteString];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.targetURL];
    [self.webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (bool) prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickRightButton:(id)sender {
    [self.webview reload];
}
@end
