//
//  SMTHHelper.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHHelper.h"
#import "Reachability.h"
#import "SMTHBoard.h"
#import "SMTHPost.h"

@implementation SMTHHelper

@synthesize nNetworkStatus;
@synthesize smth;
@synthesize sectionList;
@synthesize user;

+ (id)sharedManager {
    static SMTHHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // init smth library
        smth = [[SMTHURLConnection alloc] init];
        [smth init_smth];
        smth.delegate = self;
        // 未登录
        user = nil;
        // network initial status
        nNetworkStatus = -1;
        // init sections
        sectionList = @[@"全站热点", @"国内院校", @"休闲娱乐", @"五湖四海", @"游戏运动", @"社会信息", @"知性感性", @"文化人文", @"学术科学", @"电脑技术"];
    }
    return self;
}


- (int) login:(NSString*)username password:(NSString*)password
{
    [smth reset_status];
    user = nil;
    int status = [smth net_LoginBBS:username :password];
    if(status == 1)
    {
        NSDictionary *infos = [smth net_QueryUser:username];
//        NSLog(@"%@", infos);
        if(infos != nil){
            //        uid = 409391;
            //        id = zSMTHDev;
            //        nick = zSMTHDev;
            //        gender = 0;
            //        age = 35;
            //        faceurl = "";
            
            //        logins = 208;
            //        "first_login" = 1426471523;
            //        "last_login" = 1426608072;

            //        level = 1;
            //        life = "\U840c\U82bd";
            //        posts = 0;
            //        score = 0;
            //        title = "\U7528\U6237";
            user = [[SMTHUser alloc] init];
            
            self.user.uID = [infos objectForKey:@"uid"];
            self.user.userID = [infos objectForKey:@"id"];
            self.user.userNick = [infos objectForKey:@"nick"];
            self.user.userGender = [infos objectForKey:@"gender"];
            self.user.userAge = [infos objectForKey:@"age"];
            self.user.faceURL = [infos objectForKey:@"faceurl"];

            self.user.totalLogins = [infos objectForKey:@"logins"];
            self.user.firstLogin = [[[NSDate alloc] initWithTimeIntervalSince1970:[[infos objectForKey:@"first_login"] doubleValue]] description];
            self.user.lastLogin = [[[NSDate alloc] initWithTimeIntervalSince1970:[[infos objectForKey:@"last_login"] doubleValue]] description];

            self.user.userLevel = [[infos objectForKey:@"level"] stringValue];
            self.user.userLife = [infos objectForKey:@"life"];
            self.user.totalPosts = [infos objectForKey:@"posts"];
            self.user.userScore = [infos objectForKey:@"score"];
            self.user.userTitle = [infos objectForKey:@"title"];
        }
    }
    NSLog(@"Login Status %d", user != nil);

    return user != nil;
}

- (BOOL)isLogined
{
    // 由于API的限制，必须得登录之后才能查看首页导读，所以内置了zSMTHDev的帐号
    // 但是如果是zSMTHDev的用户名，我们认为是未登录
    if( user == nil)
        return NO;
    if([@"zSMTHDev" compare:user.userID] == NSOrderedSame)
        return NO;
    return YES;
}

- (NSArray *)getFavorites: (long) fid
{
    [smth reset_status];

    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    NSArray *results = [smth net_LoadFavorites:fid];
    for(id result in results)
    {
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

        NSDictionary *dict = (NSDictionary*) result;
        NSNumber *bid = [dict objectForKey:@"bid"];
        NSString *engName = [dict objectForKey:@"id"];
        NSString *chsName = [dict objectForKey:@"name"];
        NSString *manager = [dict objectForKey:@"manager"];

        NSLog(@"English board name:%@", engName);
        SMTHBoard *board = [[SMTHBoard alloc] init];
        if (engName != nil && engName.length > 0)
        {
            board.type = BOARD;
        } else
        {
            board.type = GROUP;
        }
        board.engName = engName;
        board.boardID = [bid longValue];
        board.chsName = chsName;
        board.managers = manager;
        [favorites addObject:board];
    }
    return favorites;
}

- (NSArray *)getGuidancePosts
{
    [smth reset_status];

    NSMutableArray *sections = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.sectionList count]; i++) {
        NSMutableArray *posts = [[NSMutableArray alloc] init];

        // find all posts in one section
        NSArray *results;
        if( i == 0)
            results = [smth net_LoadSectionHot:i];
        else
            results = [smth net_LoadSectionHot:i+1];
//        NSLog(@"--------- %@ ---------", [self.sectionList objectAtIndex:i]);
        for (id result in results) {
            //        "author_id" = GuoTie;
            //        board = Universal;
            //        count = 70;
            //        id = 39889;
            //        subject = "";
            //        time = 1426511802;

            SMTHPost *post = [[SMTHPost alloc] init];
            post.author = [result objectForKey:@"author_id"];
            post.postBoard = [result objectForKey:@"board"];
            post.postID = [result objectForKey:@"id"];
            post.postSubject = [result objectForKey:@"subject"];
            post.postCount = [result objectForKey:@"count"];
            NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:[[result objectForKey:@"time"] doubleValue]];
            post.postDate = [d description];

            [posts addObject:post];
        }
        [sections addObject:posts];
    }

    return sections;
}

- (int) checkVersion
{
    NSDictionary* dict = [smth net_GetVersion];
    if(smth->net_error != 0 || dict==nil){
        return -1;
    }
    NSLog(@"%@", dict);
    
//    int latest_major = [(NSString *)[dict objectForKey:@"latest_major"] intValue];
//    int latest_minor = [(NSString *)[dict objectForKey:@"latest_minor"] intValue];
//    int latest_rc    = [(NSString *)[dict objectForKey:@"latest_rc"] intValue];
//    int min_major = [(NSString *)[dict objectForKey:@"min_major"] intValue];
//    int min_minor = [(NSString *)[dict objectForKey:@"min_minor"] intValue];
//    int min_rc    = [(NSString *)[dict objectForKey:@"min_rc"] intValue];
//    
//    NSString *appVer = @"0.0.1";
//    
//    //app version
//    NSDictionary *dict_cur = [[NSBundle mainBundle] infoDictionary];
//    appVer = [dict_cur objectForKey:@"CFBundleVersion"];
//    int cur_major=0, cur_minor=0, cur_rc =0;
//    sscanf([appVer cStringUsingEncoding:NSUTF8StringEncoding], "%d.%d.%d", &cur_major, &cur_minor, &cur_rc);
//    NSLog(@"current app version %@:%d.%d.%d", appVer, cur_major, cur_minor, cur_rc);
    
    return 1;
}

-(void)smth_update_progress:(SMTHURLConnection *)con
{
    int percent = con->net_progress;
    
    //    if(net_ops == 0){
    //        net_ops = 1;
    //    }
    //    net_ops_percent = (net_ops_done * 100 + percent) / net_ops;
//    NSLog(@"percentage %d", percent);
}



- (void) updateNetworkStatus
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            nNetworkStatus = -1;
            break;
        case ReachableViaWiFi:
            nNetworkStatus = 0;
            break;
        case ReachableViaWWAN:
            nNetworkStatus = 1;
            break;
        default:
            break;
    }
}
@end
