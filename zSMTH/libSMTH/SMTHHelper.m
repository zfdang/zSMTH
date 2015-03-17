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
@synthesize isLogined;

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
        isLogined = false;
        // network initial status
        self.nNetworkStatus = -1;
        // init sections
        sectionList = @[@"全站热点", @"国内院校", @"休闲娱乐", @"五湖四海", @"游戏运动", @"社会信息", @"知性感性", @"文化人文", @"学术科学", @"电脑技术"];
    }
    return self;
}

- (int) login:(NSString*)username password:(NSString*)password
{
    [smth reset_status];
    int status = [smth net_LoginBBS:username :password];
    if( status == 1)
    {
//        age = 35;
//        faceurl = "";
//        "first_login" = 1426471523;
//        gender = 0;
//        id = zSMTHDev;
//        "last_login" = 1426608072;
//        level = 1;
//        life = "\U840c\U82bd";
//        logins = 208;
//        nick = zSMTHDev;
//        posts = 0;
//        score = 0;
//        title = "\U7528\U6237";
//        uid = 409391;
        NSDictionary *users = [smth net_QueryUser:username];
        NSLog(@"%@", users);
    }
    NSLog(@"Login Status %d", status);

    return status;
}

- (NSArray *)getFavorites: (long) fid
{
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    [smth reset_status];
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
    
//#ifdef DEBUG
//    USE_MEMBER = true;
//#else
//    if([(NSString *)[dict objectForKey:@"use_nmember"] intValue] > 0){
//        USE_MEMBER = true;
//    }
//#endif
//    
//    help_board = [dict objectForKey:@"help_board"];
//    if(help_board != nil && [help_board isEqualToString:@""]){
//        help_board = nil;
//    }
//#ifdef DEBUG
//    if(help_board == nil){
//        help_board = @"BBSHelp";
//    }
//#endif
    
    int latest_major = [(NSString *)[dict objectForKey:@"latest_major"] intValue];
    int latest_minor = [(NSString *)[dict objectForKey:@"latest_minor"] intValue];
    int latest_rc    = [(NSString *)[dict objectForKey:@"latest_rc"] intValue];
    int min_major = [(NSString *)[dict objectForKey:@"min_major"] intValue];
    int min_minor = [(NSString *)[dict objectForKey:@"min_minor"] intValue];
    int min_rc    = [(NSString *)[dict objectForKey:@"min_rc"] intValue];
//    last_changelog = [dict objectForKey:@"latest_changelog"];
    
//    notify_number = [(NSString *)[dict objectForKey:@"notify_number"] intValue];
//    notify_msg = [dict objectForKey:@"notify_msg"];
    
    NSString *appVer = @"0.0.1";
    
    //app version
    NSDictionary *dict_cur = [[NSBundle mainBundle] infoDictionary];
    appVer = [dict_cur objectForKey:@"CFBundleVersion"];
    int cur_major=0, cur_minor=0, cur_rc =0;
    sscanf([appVer cStringUsingEncoding:NSUTF8StringEncoding], "%d.%d.%d", &cur_major, &cur_minor, &cur_rc);
    NSLog(@"current app version %@:%d.%d.%d", appVer, cur_major, cur_minor, cur_rc);
    
    if((cur_major < min_major) || (cur_major == min_major && cur_minor < min_minor) || (cur_major == min_major && cur_minor == min_minor && cur_rc < min_rc)){
        return -2;
    }
    
    if((cur_major < latest_major) || (cur_major == latest_major && cur_minor < latest_minor) || (cur_major == latest_major && cur_minor == latest_minor && cur_rc < latest_rc)){
        
        NSString *newversion = [NSString stringWithFormat:@"%d.%d.%d", latest_major, latest_minor, latest_rc];
        return 2;
    }
    
    return 1;
    
}

-(void)smth_update_progress:(SMTHURLConnection *)con
{
    int percent = con->net_progress;
    
    //    if(net_ops == 0){
    //        net_ops = 1;
    //    }
    //    net_ops_percent = (net_ops_done * 100 + percent) / net_ops;
    NSLog(@"percentage %d", percent);
}



- (void) updateNetworkStatus
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            self.nNetworkStatus = -1;
            break;
        case ReachableViaWiFi:
            self.nNetworkStatus = 0;
            break;
        case ReachableViaWWAN:
            self.nNetworkStatus = 1;
            break;
        default:
            break;
    }
}
@end
