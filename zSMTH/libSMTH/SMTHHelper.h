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
@property (strong, nonatomic) SMTHUser *user;

- (void) updateNetworkStatus;
- (NSURL*) getFaceURLByUserID:(NSString*)userID;
- (int) checkVersion;

// returned value should not be used to judge whether user is logined or not.
// 根据user == nil来判断是否有活跃用户
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

- (BOOL) hasNewMail;
- (NSArray*) getMailsFrom:(int)type from:(int)from;
- (id) getMailContent:(int)type position:(int)pos;

@end
