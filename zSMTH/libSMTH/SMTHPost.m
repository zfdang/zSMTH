//
//  SMTHPost.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHPost.h"

@implementation SMTHPost

@synthesize author;
@synthesize postBoard;
@synthesize postID;
@synthesize postSubject;
@synthesize postCount;
@synthesize postDate;


//        "author_id" = GuoTie;
//        board = Universal;
//        count = 70;
//        id = 39889;
//        subject = "\U6211\U521a\U624d\U5728\U5783\U573e\U7bb1\U91cc\U6361\U4e86\U4e00\U5957\U56db\U672c\U8d27\U5e01\U6218\U4e89";
//        time = 1426511802;

-(NSString *)description
{
    return [NSString stringWithFormat:@"Board=%@, Author=%@, id=%ld, subject=%@, time=%@",
            self.postBoard, self.author, self.postID, self.postSubject, self.postDate];
}

@end
