//
//  SMTHUser.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-18.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHUser.h"

@implementation SMTHUser

@synthesize uID;
@synthesize userID;
@synthesize userNick;
@synthesize userGender;
@synthesize userAge;
@synthesize faceURL;

@synthesize userLevel;
@synthesize userLife;
@synthesize userTitle;

@synthesize firstLogin;
@synthesize lastLogin;
@synthesize totalLogins;
@synthesize totalPosts;
@synthesize userScore;

-(NSURL *)getFaceURL
{
    NSString *_userID;
    int forcemode = 0;
    NSRange t_range = [self.userID rangeOfString:@"."];
    if (t_range.location != NSNotFound){
        _userID = [self.userID substringToIndex:t_range.location];
        forcemode = 1;
    } else {
        _userID = [self.userID copy];
        forcemode = 0;
    }

    NSString *url = nil;

    // default avatar, don't have to query user info to get the result
    // http://images.newsmth.net/nForum/uploadFace/Z/zSMTHDev.jpg
    // if we query user and get exact user information, we will use faceURL as avatar, it might be different with default avatar
    // http://images.newsmth.net/nForum/uploadFace/Z/zSMTHDev.4279.jpg
    if(!forcemode){
        if(self.faceURL){
            url = [NSString stringWithFormat:@"http://images.newsmth.net/nForum/uploadFace/%@/%@", [[_userID substringToIndex:1] uppercaseString], self.faceURL];
        } else {
            url = [NSString stringWithFormat:@"http://images.newsmth.net/nForum/uploadFace/%@/%@.jpg", [[_userID substringToIndex:1] uppercaseString], _userID];
        }
    }else{
        url = [NSString stringWithFormat:@"http://images.newsmth.net/nForum/uploadFace/%@/%@", [[_userID substringToIndex:1] uppercaseString], _userID];
    }
//    NSLog(@"userID = %@, URL=%@, faceurl = %@", self.userID, url, self.faceURL);

    return [NSURL URLWithString:url];
}

- (NSString *)getLifeLevel
{
    return [NSString stringWithFormat:@"%@(%@)",self.userLife, self.userLevel ];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID=%@, Nick=%@, last_login=%@, posts=%@, title=%@",
            self.userID, self.userNick, self.lastLogin, self.totalPosts, self.userTitle];
}
@end
