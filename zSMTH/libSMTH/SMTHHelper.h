//
//  SMTHHelper.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMTHURLConnection.h"
#import "SMTHUser.h"
#import "SMTHPost.h"

@interface SMTHHelper : NSObject <SMTHURLConnectionDelegate>
{

}

+ (id)sharedManager;

@property (readonly, strong, nonatomic) SMTHURLConnection *smth;
@property (readonly, strong, nonatomic) NSArray *sectionList;
@property (strong, nonatomic) SMTHUser *user;

- (NSURL*) getFaceURLByUserID:(NSString*)userID;
- (int) checkVersion;

// returned value should not be used to judge whether user is logined or not.
// 根据user == nil来判断是否有活跃用户
- (int) login:(NSString*)username password:(NSString*)password;
- (void) logout;
- (BOOL) isConnectionActive;

// 获取版面，文章信息
- (NSArray*) getAllBoards;
- (NSString*) getCacheUpdateTime:(NSString*) type RootID:(long)rootid;
- (void) clearCacheStatus:(NSString*) type RootID:(long)rootid;

- (NSArray*) getFavorites:(long)fid;
- (BOOL) addFavorite:(NSString*)engName;
- (BOOL) removeFavorite:(NSString*)engName;

- (NSArray*) getGuidancePosts:(int)section;
- (NSArray*) getPostsFromBoard:(NSString*)boardID from:(long)from;
- (NSArray*) getPostContents:(NSString *)board_id postID:(long)article_id from:(long)from;
- (NSArray*) getFilteredPostsFromBoard:(NSString*)boardID title:(NSString*)title user:(NSString*)user from:(long)from;


- (SMTHUser*) getUserInfo:(NSString*) userID;

- (NSString*) getChsBoardName:(NSString*) engName;
- (long) getBoardID:(NSString*) engName;

- (int) hasNewMail;
- (NSArray*) getMailList:(int)type from:(int)from;
- (SMTHPost*) getMailContent:(int)type position:(int)pos;

@end
