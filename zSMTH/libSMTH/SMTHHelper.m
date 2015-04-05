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
#import "FMDB.h"

@interface SMTHHelper ()
{
    int postNumberinOnePage;  // 版面列表：一页显示多少个帖子数
    int replyNumberinOnePost; // 文章内容：一页显示多少回复数
    int replyOrder;
    int brcmode;
    
    FMDatabase *db;
}
@end

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

        // init FMDB
        NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString* dbpath = [docsdir stringByAppendingPathComponent:@"zSMTH.sqlite"];
        db = [FMDatabase databaseWithPath:dbpath];
        
        [self initDatabaseStructure];
//        NSString *stamp = [self getBoardListUpdateTime];
//        [self saveAllBoardToCache:nil];
//        stamp = [self getBoardListUpdateTime];
//        [self clearBoardListCache];
//        stamp = [self getBoardListUpdateTime];
    }
    return self;
}

// init two tables to store cached results
- (BOOL) initDatabaseStructure
{
    if ([db open]) {
        NSString *sqlCreateTable =  @"CREATE TABLE IF NOT EXISTS 'CacheStatus' (\
        'type' TEXT,\
        'status' INTEGER,\
        'updated_at' TEXT)";
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table: CacheStatus");
        } else {
            NSLog(@"success to creating db table: CacheStatus");
        }
        
        sqlCreateTable =  @"CREATE TABLE IF NOT EXISTS 'BoardCache' (\
        'type' TEXT,\
        'root_id' INTEGER,\
        'board_id' INTEGER,\
        'board_chs_name' TEXT,\
        'board_eng_name' TEXT,\
        'board_category' TEXT,\
        'board_type' INTEGER,\
        'board_managers' TEXT)";
        res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table: BoardCache");
        } else {
            NSLog(@"success to creating db table: BoardCache");
        }
        [db close];
        
        return YES;
    }
    
    return NO;
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

- (NSString*) getBoardListUpdateTime
{
    NSString *result = nil;
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT updated_at FROM CacheStatus where type='BOARD'"];
        while ([s next]) {
            //retrieve values for each record
            result = [s stringForColumn:@"updated_at"];
        }
        [db close];
    }
    return result;
}

- (void)clearBoardListCache
{
    if ([db open]) {
        BOOL result = [db executeUpdate:@"DELETE FROM CacheStatus where type='BOARD'"];
        if(! result){
            NSLog(@"clearBoardListCache FAILED.");
        } else {
            NSLog(@"clearBoardListCache");
        }
        [db close];
    }
}

- (NSArray *)getAllBoards
{
    NSMutableArray *boards = [[NSMutableArray alloc] init];
    
    BOOL loaded = [self getAllBoardsFromCache:boards];
    if(!loaded){
        // get raw list of all boards from server
        // 1. duplicated 2. unsorted
        [self getAllBoardsFromServer:0 Result:boards BoardPath:nil isSection:NO];
        NSLog(@"Raw records loaded from Server: %ld", [boards count]);
        
        // de-duplicate
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSMutableArray *newBoards = [[NSMutableArray alloc] init];
        for (int i = 0; i < [boards count]; i++) {
            SMTHBoard *board = [boards objectAtIndex:i];
            NSNumber* value = [dict valueForKey:board.engName];
            if(value == nil){
                // new board
                [dict setValue:[NSNumber numberWithInt:i] forKey:board.engName];
                [newBoards addObject:board];
            } else {
                // duplicated board, merge category and do not add current board again
                SMTHBoard *previousBoard = [boards objectAtIndex:[value intValue]];
                if(board.category == nil){
                    continue;
                } else if(previousBoard.category == nil){
                    previousBoard.category = board.category;
                } else {
                    // 两个都不为空，需要合并
                    // 合并时，我们对某些category会舍弃，比如"正版主-","商务-"等
                    if([previousBoard.category hasPrefix:@"正版主"] ||  [previousBoard.category hasPrefix:@"商务"]){
                        // ignore previous category
                        previousBoard.category = board.category;
                    } else if([board.category hasPrefix:@"正版主"] ||  [board.category hasPrefix:@"商务"]){
                        // ignore current category
                    } else {
                        previousBoard.category = [NSString stringWithFormat:@"%@|%@", previousBoard.category, board.category];
                    }
                }
            }
        }

        // sort
        NSArray *sortedBoards = [newBoards sortedArrayUsingSelector:@selector(compare:)];

        // save back
        [boards removeAllObjects];
        [boards addObjectsFromArray:sortedBoards];
        NSLog(@"Refined records loaded from Server: %ld", [boards count]);

        // save boards to cache server
        [self saveAllBoardToCache:boards];
    }

    // return result
    return boards;
}


- (BOOL)getAllBoardsFromCache:(NSMutableArray*)boards
{
    NSString *stamp = [self getBoardListUpdateTime];
    if(stamp == nil){
        return NO;
    }
 
    if([db open]){
        // load all boards from cache
        FMResultSet *s = [db executeQuery:@"SELECT * FROM BoardCache where type = 'BOARD'"];
        while ([s next]) {
            SMTHBoard *board = [[SMTHBoard alloc] init];
            board.boardID = [s longForColumn:@"board_id"];
            board.chsName = [s stringForColumn:@"board_chs_name"];
            board.engName = [s stringForColumn:@"board_eng_name"];
            board.category = [s stringForColumn:@"board_category"];
            board.managers = [s stringForColumn:@"board_managers"];
            
            [boards addObject:board];
        }
        
        // Sort boards
        NSArray *sortedBoards = [boards sortedArrayUsingSelector:@selector(compare:)];
        [boards removeAllObjects];
        [boards addObjectsFromArray:sortedBoards];
        
        NSLog(@"Records loaded from Cache %ld", [boards count]);
        [db close];
    }
    if([boards count] == 0)
        return NO;
    
    return YES;
}

- (BOOL) saveAllBoardToCache:(NSArray*)boards
{
    if([db open]){
        BOOL success;
        
        // clear all board cache first
        success = [db executeUpdate:@"DELETE from BoardCache where type = 'BOARD'"];
        if(! success){
            NSLog(@"Failed to clear cached Boards!");
        } else {
            NSLog(@"Clear all cached boards done.");
        }

        // save all board to cache
        for (SMTHBoard* board in boards) {
            success = [db executeUpdate:@"INSERT INTO BoardCache ('type', 'board_id', 'board_chs_name', 'board_eng_name', 'board_category', 'board_managers') VALUES ('BOARD',?,?,?,?,?)", [NSNumber numberWithLong:board.boardID], board.chsName, board.engName, board.category, board.managers];
            if(! success){
                NSLog(@"Failt to write board to cache: %@", board.chsName);
            } else {
//                NSLog(@"Write board cache: %@", board.chsName);
            }
        }
        NSLog(@"Write board to cache: %ld", [boards count]);

        // write cache status
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSString *dateStr = [dateFormatter stringFromDate:date];
        
        success = [db executeUpdate:@"insert into CacheStatus ('type', 'updated_at') values ('BOARD', ?);", dateStr];
        if(! success){
            NSLog(@"Insert Record Failed: CacheStatus");
        } else {
            NSLog(@"Write Cache Status: %@", dateStr);
        }

        [db close];
    }

    
    return YES;
}


- (BOOL)getAllBoardsFromServer:(long)groupid Result:(NSMutableArray*)boards BoardPath:(NSString*)path isSection:(BOOL)isSection
{
    [smth reset_status];
    
    NSArray *results = nil;
    
    if(isSection)
    {
        // 版面目录，比如“篮球”，下面有几个具体的子版面
        // sectionid 固定为0, 现在的API貌似不看sectionid
        results = [smth net_ReadSection:0 :groupid];
    } else {
        // 目录，比如"体育运动"
        results = [smth net_LoadBoards:groupid];
    }
    if(smth->net_error != 0){
        // 获取失败了
        NSLog(@"Load group failed, groupid=%ld", groupid);
        return NO;
    }
    
    for(id result in results)
    {
//                {
//                    bid = 60;
//                    "current_users" = 0;
//                    flag = "-1";
//                    flag = 332288;
//                    group = 0;
//                    id = "";
//                    "last_post" = 0;
//                    level = 0;
//                    manager = Business;
//                    "max_online" = 0;
//                    "max_time" = 0;
//                    name = "商务　　　 商务版面";
//                    position = 17;
//                    score = 0;
//                    "score_level" = 0;
//                    section = 0;
//                    total = 0;
//                    type = board;
//                    unread = 0;
//                }
        
        NSDictionary *dict = (NSDictionary*) result;
        NSNumber *bid = [dict objectForKey:@"bid"];
        NSString *chsName = [dict objectForKey:@"name"];
        NSString *engName = [dict objectForKey:@"id"];
        NSString *manager = [dict objectForKey:@"manager"];

        int board_flag = [(NSString*)[dict objectForKey:@"flag"] intValue];
//        NSLog(@"%@, %@, %d, %@", bid, chsName, board_flag, [dict objectForKey:@"section"]);

        if(board_flag == -1){
            // 目录, 需要包含在版面路径中
            NSArray *listItems = [chsName componentsSeparatedByString:@" "];
            NSString *directParent = [[listItems objectAtIndex:0] stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceCharacterSet]];
            NSString *parent = nil;
            if(path != nil){
                parent = [NSString stringWithFormat:@"%@-%@", path, directParent];
            } else {
                parent = directParent;
            }
            [self getAllBoardsFromServer:[bid longValue] Result:boards BoardPath:parent  isSection:NO];
        }else if(board_flag & 0x400){
            // 版面目录，包含几个子版面
            NSArray *listItems = [chsName componentsSeparatedByString:@" "];
            NSString *directParent = [[listItems objectAtIndex:0] stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceCharacterSet]];
            NSString *parent = nil;
            if(path != nil){
                parent = [NSString stringWithFormat:@"%@-%@", path, directParent];
            } else {
                parent = directParent;
            }
            [self getAllBoardsFromServer:[bid longValue] Result:boards BoardPath:parent isSection:YES];
        }else{
            // 真正的版面
            SMTHBoard *board = [[SMTHBoard alloc] init];
            board.type = BOARD;
            board.engName = engName;
            board.boardID = [bid longValue];
            board.chsName = chsName;
            board.managers = manager;
            board.category = path;

            [boards addObject:board];
        }
    }
    return YES;
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
