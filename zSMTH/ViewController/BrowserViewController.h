//
//  BrowserViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-5-4.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController

- (IBAction)clickLeftButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (strong, nonatomic) NSURL* targetURL;

@end
