//
//  ContentEditViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"

typedef enum {
    ACTION_NEW_POST = 0,
    ACTION_REPLY_POST,
    ACTION_NEW_MAIL,
    ACTION_REPLY_MAIL,
    ACTION_REPLY_POST_TO_MAIL
} ActionType;

@interface ContentEditViewController : ExtendedUIViewController

@property (strong, nonatomic) NSString *engName;
@property (strong, nonatomic) NSString *recipient;

@property (strong, nonatomic) NSArray *mAttachments;

@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UITextField *txtAttach;
@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (weak, nonatomic) IBOutlet UILabel *txtSummary;
@property (weak, nonatomic) IBOutlet UITextField *txtAction;
@property (weak, nonatomic) IBOutlet UIButton *btAttachment;

@property (nonatomic) ActionType actionType;

- (IBAction)editAttachments:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)submit:(id)sender;

- (void) setOrigPostInfo:(long)postID subject:(NSString*)origSubject author:(NSString*) author content:(NSString*)origContent;
- (void) setOrigMailInfo:(int)position recipient:(NSString*)recipient subject:(NSString*)origSubject content:(NSString*)origContent;

@end
