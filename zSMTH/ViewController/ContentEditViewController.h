//
//  ContentEditViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendedUIViewController.h"

@interface ContentEditViewController : ExtendedUIViewController

@property (strong, nonatomic) NSString *engName;

@property (strong, nonatomic) NSArray *mAttachments;

@property (weak, nonatomic) IBOutlet UITextField *txtSubject;
@property (weak, nonatomic) IBOutlet UITextField *txtAttach;
@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (weak, nonatomic) IBOutlet UILabel *txtSummary;

- (IBAction)editAttachments:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)submit:(id)sender;

- (void) setOrigPostInfo:(long)postID subject:(NSString*)origSubject author:(NSString*) author content:(NSString*)origContent;

@end
