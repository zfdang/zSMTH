//
//  SMTHHelper.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHHelper.h"
#import "Reachability.h"

@implementation SMTHHelper

@synthesize nNetworkStatus;
@synthesize smth;

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
        // network initial status
        self.nNetworkStatus = -1;
        
        smth = [[SMTHURLConnection alloc] init];
        [smth init_smth];
        smth.delegate = self;
    }
    return self;
}

- (int) login:(NSString*)username password:(NSString*)password
{
    [smth reset_status];
    int status = [smth net_LoginBBS:username :password];
    NSLog(@"Login Status %d", status);

    return status;
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
