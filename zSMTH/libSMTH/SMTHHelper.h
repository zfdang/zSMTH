//
//  SMTHHelper.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "SMTHURLConnection.h"
#import "SMTHUser.h"

@interface SMTHHelper : NSObject <SMTHURLConnectionDelegate>
{
    int postNumberinOnePage;  // 版面列表：一页显示多少个帖子数
    int replyNumberinOnePost; // 文章内容：一页显示多少回复数
    int replyOrder;
    int brcmode;
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
- (int) login:(NSString*)username password:(NSString*)password;
- (void) logout;
- (NSArray*) getFavorites:(long)fid;
- (NSArray*) getGuidancePosts;
- (NSArray*) getPostsFromBoard:(NSString*)boardID from:(int)from;
- (NSArray *)getPostContents:(NSString *)board_id postID:(long)article_id from:(long)from;

@end
