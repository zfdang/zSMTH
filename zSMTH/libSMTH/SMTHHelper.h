//
//  SMTHHelper.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "SMTHURLConnection.h"
#import "SMTHUser.h"


@interface SMTHHelper : NSObject <SMTHURLConnectionDelegate>
{
    
}

+ (id)sharedManager;

@property (readonly, strong, nonatomic) SMTHURLConnection *smth;
@property (readonly, nonatomic) int nNetworkStatus;
@property (readonly, strong, nonatomic) NSArray *sectionList;
@property (readonly, strong, nonatomic) SMTHUser *user;
@property (readonly) BOOL isLogined;

- (void) updateNetworkStatus;
- (NSURL*) getFaceURLByUserID:(NSString*)userID;
- (int) checkVersion;

// returned value should not be used to judge whether user is logined or not.
// 有的时候会用内置帐号登录，但是应该认为真正用户还没有登录
// 使用isLogined来判断真实用户是否登录
- (void) login:(NSString*)username password:(NSString*)password;
- (void) logout;
- (BOOL) isConnectionActive;

// 获取版面，文章信息
- (NSArray*) getAllBoards;
- (NSString*) getCacheUpdateTime:(NSString*) type RootID:(long)rootid;
- (void) clearCacheStatus:(NSString*) type RootID:(long)rootid;
- (BOOL) updateCacheStatus:(NSString*) type RootID:(long)rootid;

- (NSArray*) getFavorites:(long)fid;
- (BOOL) addFavorite:(NSString*)engName;
- (BOOL) removeFavorite:(NSString*)engName;

- (NSArray*) getGuidancePosts;
- (NSArray*) getPostsFromBoard:(NSString*)boardID from:(int)from;
- (NSArray*) getPostContents:(NSString *)board_id postID:(long)article_id from:(long)from;
- (NSArray*) getFilteredPostsFromBoard:(NSString*)boardID title:(NSString*)title user:(NSString*)user from:(int)from;


- (SMTHUser*) getUserInfo:(NSString*) userID;

- (NSString*) getChsBoardName:(NSString*) engName;
- (long) getBoardID:(NSString*) engName;

@end
