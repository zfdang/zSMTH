//
//  ContentEditViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ContentEditViewController.h"

@interface ContentEditViewController ()

@end

@implementation ContentEditViewController

@synthesize engName;
@synthesize origContent;
@synthesize origSubject;
@synthesize replyID;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    if(self.replyID != 0){
        title = [NSString stringWithFormat:@"回帖@%@", self.engName];
    } else {
        title = [NSString stringWithFormat:@"发帖@%@", self.engName];
    }
    self.title = title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editAttachments:(id)sender {
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
}
@end
