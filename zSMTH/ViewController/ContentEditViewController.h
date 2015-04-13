//
//  ContentEditViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentEditViewController : UIViewController

@property (strong, nonatomic) NSString *engName;

@property (nonatomic) long replyID;
@property (strong, nonatomic) NSString *origSubject;
@property (strong, nonatomic) NSString *origContent;


@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UITextField *txtAttach;
@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (weak, nonatomic) IBOutlet UILabel *txtSummary;

- (IBAction)editAttachments:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)submit:(id)sender;

@end
