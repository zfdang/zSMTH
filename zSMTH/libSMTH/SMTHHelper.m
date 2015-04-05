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
#import "SMTHAttachment.h"

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

        // init setting to load post list
        brcmode = 0;
        postNumberinOnePage = 20;
        
        // init setting to load post details & replies
        replyNumberinOnePost = 20;
        replyOrder = 1;
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

- (void) logout
{
    [smth net_LogoutBBS];
    // 退出成功
    user = nil;
}


- (BOOL)isLogined
{
    // 由于API的限制，必须得登录之后才能查看首页导读，所以内置了zSMTHDev的帐号
    // 但是如果是zSMTHDev的用户名，我们认为是未登录
    if( user == nil)
        return NO;
    if([@"zSMTHDev" compare:user.userID] == NSOrderedSame)
//      if([@"zSMTHDevAA" compare:user.userID] == NSOrderedSame)
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

//        NSLog(@"English board name:%@", engName);
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


- (NSURL*) getFaceURLByUserID:(NSString*)userID
{
    SMTHUser *u = [[SMTHUser alloc] init];
    u.userID = userID;
    return [u getFaceURL];
}

- (NSArray*) getPostsFromBoard:(NSString*)boardID from:(int)from
{
    [smth reset_status];
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    NSArray *results = [smth net_LoadThreadList:boardID :from*postNumberinOnePage :postNumberinOnePage :brcmode];
    for (id result in results) {
//        "author_id" = Kazoo;
//        id = 410834;
//        subject = "这个是一个测试的帖子";
//        time = 1424611727;
//        count = 18;
//        flags = "Dnn d";   -- 置顶帖子的flag
//        flags = " nn  ";   -- 普通帖子的flag
//        "board_id" = DigiHome;
//        "board_name" = "\U6570\U5b57\U5bb6\U5ead";
//        "last_reply_id" = 415457;
//        "last_time" = 1425600260;
//        "last_user_id" = shanzai12;

//        NSLog(@"%@", result);
        NSDictionary *dict = (NSDictionary*) result;
        SMTHPost *post = [[SMTHPost alloc] init];
        post.author = [dict objectForKey:@"author_id"];
        post.postID = [dict objectForKey:@"id"];
        post.postSubject = [dict objectForKey:@"subject"];
        post.postDate = [self getRelativeDateString:[[result objectForKey:@"time"] doubleValue]];
        post.postCount = [[dict objectForKey:@"count"] description];
        post.postFlags = [dict objectForKey:@"flags"];
        
        post.postBoard = [dict objectForKey:@"board_id"];
        post.replyPostID = [dict objectForKey:@"last_reply_id"];
        post.replyAuthor = [dict objectForKey:@"last_user_id"];
        post.replyPostDate = [self getRelativeDateString:[[result objectForKey:@"last_time"] doubleValue]];

        [posts addObject:post];
    }
    
    return posts;
}

- (NSArray *)getPostContents:(NSString *)board_id postID:(long)article_id from:(long)from
{
    [smth reset_status];
    NSMutableArray *posts = [[NSMutableArray alloc] init];
    NSArray *results = [smth net_GetThread:board_id :article_id :from*replyNumberinOnePost :replyNumberinOnePost :replyOrder];
    long replyIndex = from*replyNumberinOnePost;
    for (id result in results) {
//        "attachment_list" =     (
//                                 {
//                                     name = "634fd979gw1eqb6sjvvorj20m80etwmk.jpg";
//                                     pos = 651;
//                                     size = 308191;
//                                 },
//                                 );
//        attachments = 2;
//        "author_id" = confinement;
//        body = ";
//        effsize = 288;
//        flags = "*nn@ ";
//        id = 19680;
//        subject = "\U6b66\U5927\U6a31\U82b1\U56fe";
//        time = 1426868596;
//        NSLog(@"%@", result);
        
        NSDictionary *dict = (NSDictionary*) result;
        SMTHPost *post = [[SMTHPost alloc] init];

        post.postID = [dict objectForKey:@"id"];
        post.postSubject = [dict objectForKey:@"subject"];
        post.author = [dict objectForKey:@"author_id"];
        post.postDate = [self getAbsoluteDateString:[[result objectForKey:@"time"] doubleValue]];
        
        post.postContent = [dict objectForKey:@"body"];

        post.postFlags = [dict objectForKey:@"flags"];
        post.replyIndex = replyIndex;

        [posts addObject:post];
        
        NSArray *attachs = [dict objectForKey:@"attachment_list"];
        if(attachs != nil && [attachs count] > 0){
            post.attachments = [[NSMutableArray alloc] init];

            for (id attach in attachs) {
                NSDictionary *items = (NSDictionary*) attach;
                SMTHAttachment *att = [[SMTHAttachment alloc] init];
                att.attName = [items objectForKey:@"name"];
                att.attPos = [[items objectForKey:@"pos"] longValue];
                att.attSize = [[items objectForKey:@"size"] longValue];
                
                [post.attachments addObject:att];
            }
            
        }

        replyIndex += 1;
    }
    
    return posts;
}

- (NSArray *)getAllBoards
{
    [smth reset_status];
    
    NSMutableArray *boards = [[NSMutableArray alloc] init];
    [self getAllBoardsInternal:0 Result:boards];
    return boards;
}


- (void)getAllBoardsInternal:(long)groupid Result:(NSMutableArray*)boards
{
    [smth reset_status];
    NSArray *results = [smth net_LoadBoards:groupid];
    for(id result in results)
    {
        //        {
        //            bid = 60;
        //            "current_users" = 0;
        //            flag = "-1";
        //            flag = 332288;
        //            group = 0;
        //            id = "";
        //            "last_post" = 0;
        //            level = 0;
        //            manager = Business;
        //            "max_online" = 0;
        //            "max_time" = 0;
        //            name = "商务　　　 商务版面";
        //            position = 17;
        //            score = 0;
        //            "score_level" = 0;
        //            section = 0;
        //            total = 0;
        //            type = board;
        //            unread = 0;
        //        }
//        NSLog(@"%@", result);
        
        NSDictionary *dict = (NSDictionary*) result;
        NSNumber *bid = [dict objectForKey:@"bid"];
        NSString *chsName = [dict objectForKey:@"name"];
        NSString *engName = [dict objectForKey:@"id"];
        NSString *manager = [dict objectForKey:@"manager"];

        int board_flag = [(NSString*)[dict objectForKey:@"flag"] intValue];
        NSLog(@"%@, %@, %d", bid, chsName, board_flag);

        if(board_flag == -1){
            // 目录
            [self getAllBoardsInternal:[bid longValue] Result:boards];
        }else if(board_flag & 0x400){
            // 版面目录，包含几个子版面
            [self getAllBoardsInternal:[bid longValue] Result:boards];
        }else{
            // 真正的版面
            SMTHBoard *board = [[SMTHBoard alloc] init];
            board.type = BOARD;
            board.engName = engName;
            board.boardID = [bid longValue];
            board.chsName = chsName;
            board.managers = manager;
            
            [boards addObject:board];
        }
    }
    return;
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
//    int percent = con->net_progress;
    
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


- (NSString*) getDateString_internal:(NSTimeInterval) time :(NSTimeInterval)cur_time :(int)after
{
    if(cur_time == 0){
        cur_time = [[NSDate date] timeIntervalSince1970];
    }
    
    long long int ts = (long long int)time;
    long long int c_ts = (long long int)cur_time;
    
    if(after){
        if(ts <= c_ts){
            return @"现在";
        }
    }else{
        if(ts >= c_ts){
            return @"现在";
        }
    }
    if(ts == 0){
        return @"";
    }
    long long int d;
    NSString * post;
    if(after){
        d = ts - c_ts;
        post = @"后";
    }else{
        d = c_ts - ts;
        post = @"前";
    }
    
    if(d < 60){
        return [NSString stringWithFormat:@"%lld秒%@", d, post];
    }
    d /= 60;
    if(d < 60){
        return [NSString stringWithFormat:@"%lld分钟%@", d, post];
    }
    d /= 60;
    if(d < 24){
        return [NSString stringWithFormat:@"%lld小时%@", d, post];
    }
    d /= 24; //天数
    if(d < 7){
        return [NSString stringWithFormat:@"%lld天%@", d, post];
    }
    if(d < 30){
        return [NSString stringWithFormat:@"%lld周%@", d/7, post];
    }
    if(d < 365){
        return [NSString stringWithFormat:@"%lld月%@", d/30, post];
    }
    d /= 365;
    return [NSString stringWithFormat:@"%lld年%@", d, post];
}


- (NSString*) getRelativeDateString:(NSTimeInterval) time
{
    NSTimeInterval cur_time = [[NSDate date] timeIntervalSince1970];

    return [self getDateString_internal:time :cur_time :0];
}

- (NSString*) getAbsoluteDateString:(NSTimeInterval) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    return [dateFormatter stringFromDate:d];
}

@end
