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

@interface SMTHHelper : NSObject <SMTHURLConnectionDelegate>
{
    
}

+ (id)sharedManager;

@property (strong, nonatomic) SMTHURLConnection *smth;
@property (nonatomic) int nNetworkStatus;
@property (strong, nonatomic) NSArray *sectionList;
@property BOOL isLogined;

- (void) updateNetworkStatus;
- (int) login:(NSString*)username password:(NSString*)password;
- (int) checkVersion;

- (NSArray*) getFavorites:(long)fid;
- (NSArray*) getGuidancePosts;

@end
