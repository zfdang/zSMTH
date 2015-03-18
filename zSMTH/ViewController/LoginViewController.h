//
//  LoginViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-11.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"

@interface LoginViewController : ExtendedUIViewController
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *netStatus;
@property (strong, nonatomic) IBOutlet UITextField *editUsername;
@property (strong, nonatomic) IBOutlet UITextField *editPassword;
@property (strong, nonatomic) IBOutlet UIView *loginStatus;

- (IBAction)showLeftMenu:(id)sender;



@end
