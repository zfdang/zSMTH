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
@synthesize postID;
@synthesize postSubject;
@synthesize postDate;
@synthesize postCount;
@synthesize postFlags;

@synthesize postBoard;
@synthesize replyPostID;
@synthesize replyPostDate;
@synthesize replyAuthor;

-(NSString *)description
{
    return [NSString stringWithFormat:@"Board=%@, Author=%@, id=%@, subject=%@, time=%@",
            self.postBoard, self.author, self.postID, self.postSubject, self.postDate];
}

@end
