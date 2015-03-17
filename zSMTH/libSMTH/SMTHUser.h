//
//  SMTHUser.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-18.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>

//        uid = 409391;
//        id = zSMTHDev;
//        nick = zSMTHDev;
//        gender = 0;
//        age = 35;
//        faceurl = "";

//        "first_login" = 1426471523;
//        "last_login" = 1426608072;
//        level = 1;
//        life = "\U840c\U82bd";
//        logins = 208;
//        posts = 0;
//        score = 0;
//        title = "\U7528\U6237";

@interface SMTHUser : NSObject

@property (strong, nonatomic) NSString *uID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userNick;
@property (strong, nonatomic) NSString *userGender;
@property (strong, nonatomic) NSString *userAge;
@property (strong, nonatomic) NSString *faceURL;

@property (strong, nonatomic) NSString *userLevel;
@property (strong, nonatomic) NSString *userLife;
@property (strong, nonatomic) NSString *userTitle;

@property (strong, nonatomic) NSString *firstLogin;
@property (strong, nonatomic) NSString *lastLogin;
@property (strong, nonatomic) NSString *totalLogins;
@property (strong, nonatomic) NSString *totalPosts;
@property (strong, nonatomic) NSString *userScore;


@end
