//
//  AboutViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-5-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"

@interface AboutViewController : ExtendedUIViewController
@property (weak, nonatomic) IBOutlet UILabel *textVersion;

- (IBAction)visitWebsite:(id)sender;

@end
