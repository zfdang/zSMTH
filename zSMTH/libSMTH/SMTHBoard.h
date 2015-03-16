//
//  SMTHBoard.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-15.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>
//bid = 647;
//"current_users" = 309;
//flag = 279040;
//group = 0;
//id = Children;
//"last_post" = 931215771;
//level = 0;
//manager = "";
//"max_online" = 0;
//"max_time" = 0;
//name = "\U5b69\U5b50";
//position = 646;
//score = 0;
//"score_level" = 0;
//section = 0;
//total = 93186;
//type = board;
//unread = 1;

typedef enum {
    BOARD = 1,
    GROUP,
} BoardType;

@interface SMTHBoard : NSObject
{
    NSArray *children;
}

@property long boardID;
@property (strong, nonatomic) NSString* chsName;
@property (strong, nonatomic) NSString* engName;
@property BoardType type;
@property (strong, nonatomic) NSString* managers;


@end
