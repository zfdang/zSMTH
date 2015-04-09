//
//  SMTHPost.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHPost.h"
#import "SMTHAttachment.h"

@implementation SMTHPost

@synthesize author;
@synthesize postID;
@synthesize postSubject;
@synthesize postDate;
@synthesize postCount;
@synthesize postFlags;

@synthesize postContent;
@synthesize attachments;

@synthesize postBoard;
@synthesize replyPostID;
@synthesize replyPostDate;
@synthesize replyAuthor;

@synthesize replyIndex;

-(BOOL) isDing
{
    if(postFlags && postFlags.length > 0){
        NSString * flag0 = [postFlags substringToIndex:1];
        if([flag0 isEqualToString:@"d"] || [flag0 isEqualToString:@"D"]){
            return YES;
        }
    }
    return NO;
}

-(BOOL) isUnread
{
    if(postFlags && postFlags.length > 0){
        NSString * flag0 = [postFlags substringToIndex:1];
        if([flag0 isEqualToString:@"*"]){
            return YES;
        }
    }
    return NO;
}

-(BOOL) hasAttachment
{
    if(postFlags && postFlags.length > 0){
        if([[[postFlags substringToIndex:4] substringFromIndex:3] isEqualToString:@"@"]){
            return YES;
        }
    }
    return NO;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"Board=%@, Author=%@, id=%@, subject=%@, time=%@",
            self.postBoard, self.author, self.postID, self.postSubject, self.postDate];
}

- (NSURL*) getAttachedImageURL:(int) index
{
    if(index >= [self.attachments count])
        return nil;
    
    SMTHAttachment *attach = [self.attachments objectAtIndex:index];
    NSString * url = [NSString stringWithFormat:@"http://att.newsmth.net/nForum/att/%@/%@/%ld", self.postBoard, self.postID,
                      attach.attPos];    
    return [NSURL URLWithString:url];
}

@end
