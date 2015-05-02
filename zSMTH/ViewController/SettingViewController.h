//
//  SettingViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-15.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *txtCacheSize;
@property (weak, nonatomic) IBOutlet UILabel *txtVersion;

- (IBAction)clickLeftButton:(id)sender;
- (IBAction)switchUserAvatar:(id)sender;
- (IBAction)switchAutoRotate:(id)sender;
- (IBAction)clearCache:(id)sender;

@end
