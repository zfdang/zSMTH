//
//  SMTHPost.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMTHPost : NSObject

//  十大导读里的帖子信息
//        "author_id" = GuoTie;
//        board = Universal;
//        count = 70;
//        id = 39889;
//        subject = "\U6211\U521a\U624d\U5728\U5783\U573e\U7bb1\U91cc\U6361\U4e86\U4e00\U5957\U56db\U672c\U8d27\U5e01\U6218\U4e89";
//        time = 1426511802;

//  版面文章里的帖子信息
//        "author_id" = Kazoo;*
//        id = 410834;*
//        subject = "这个是一个测试的帖子";*
//        time = 1424611727;*
//        count = 18;*
//        flag的含义: 第一位如果是*, 表示未读；第一位是d或者D, 表示置顶；第四位是@, 表示有附件
//        flags = "Dnn d";   -- 置顶帖子的flag *
//        flags = " nn  ";   -- 普通帖子的flag *
//        flags = "*nn@ ";

//        "board_id" = DigiHome;*
//        "board_name" = "\U6570\U5b57\U5bb6\U5ead";
//        "last_reply_id" = 415457;
//        "last_time" = 1425600260;
//        "last_user_id" = shanzai12;


@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* postID;
@property (strong, nonatomic) NSString* postSubject;
@property (strong, nonatomic) NSString* postDate;
@property (strong, nonatomic) NSString* postCount;
@property (strong, nonatomic) NSString* postFlags;

@property (strong, nonatomic) NSString* postContent;
@property (strong, nonatomic) NSMutableArray* attachments;

@property (strong, nonatomic) NSString* postBoard;
@property (strong, nonatomic) NSString* replyPostID;
@property (strong, nonatomic) NSString* replyPostDate;
@property (strong, nonatomic) NSString* replyAuthor;


@property (nonatomic) long replyIndex;

-(BOOL) isDing;
-(BOOL) isUnread;
-(BOOL) hasAttachment;

- (NSURL*) getAttachedImageURL:(int) index;

@end
