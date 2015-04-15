//
//  ViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-6.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "REFrostedRootViewController.h"

@interface REFrostedRootViewController ()

@end

@implementation REFrostedRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGSize size = CGSizeMake(180.0, 0.0);
    self.menuViewSize = size;
}

- (void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
