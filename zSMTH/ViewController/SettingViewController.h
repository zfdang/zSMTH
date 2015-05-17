//
//  SettingViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-15.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"

@interface SettingViewController : ExtendedUIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *txtCacheSize;

- (IBAction)clickLeftButton:(id)sender;
- (IBAction)switchUserAvatar:(id)sender;
- (IBAction)switchAutoRotate:(id)sender;
- (IBAction)clearCache:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *bShowAvatar;
@property (weak, nonatomic) IBOutlet UISwitch *bAutoRotate;

@end
