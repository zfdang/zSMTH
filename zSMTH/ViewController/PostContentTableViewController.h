//
//  PostContentTableViewController.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-22.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ExtendedTableViewController.h"
#import "RefreshTableViewProtocol.h"

typedef enum {
    CONTENT_POST = 0,
    CONTENT_INBOX,
    CONTENT_OUTBOX,
    CONTENT_NOTIFICATION_REPLY,
    CONTENT_NOFIFICATION_AT
} ContentType;

@interface PostContentTableViewController : ExtendedTableViewController <RefreshTableViewProtocol>

@property (strong, nonatomic) NSString *postSubject;
@property (nonatomic) long postID;
@property (nonatomic) BOOL isFromGuidance;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonRight;

- (IBAction)clickRightButton:(id)sender;

- (IBAction)return:(id)sender;
-(void) setBoardInfo:(long)boardid chsName:(NSString*)chsname engName:(NSString*) engname;
-(void) setMailInfo:(ContentType)type position:(long)position subject:(NSString*)subject;

@end
