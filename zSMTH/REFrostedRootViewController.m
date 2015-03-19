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
    
}

- (void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    [self setMenuViewSize:CGSizeMake(self.contentViewController.view.frame.size.width - 100.0f, self.contentViewController.view.frame.size.height)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
