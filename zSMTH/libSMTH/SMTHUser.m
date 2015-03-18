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

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID=%@, Nick=%@, last_login=%@, posts=%@, title=%@",
            self.userID, self.userNick, self.lastLogin, self.totalPosts, self.userTitle];
}
@end
