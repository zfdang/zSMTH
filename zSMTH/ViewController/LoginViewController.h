//
//  LoginViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-11.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"
#import "LoginCompletionProtocol.h"

@interface LoginViewController : ExtendedUIViewController

@property (weak, nonatomic) IBOutlet UILabel *netStatus;
@property (strong, nonatomic) IBOutlet UITextField *editUsername;
@property (strong, nonatomic) IBOutlet UITextField *editPassword;
@property (weak, nonatomic) IBOutlet UILabel *loginFeedback;
@property (weak, nonatomic) id<LoginCompletionProtocol> delegate;

- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;

@end
