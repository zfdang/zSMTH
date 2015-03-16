//
//  SMTHPost.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMTHPost : NSObject

@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* postBoard;
@property (strong, nonatomic) NSString* postID;
@property (strong, nonatomic) NSString* postSubject;
@property (strong, nonatomic) NSString* postDate;
@property (strong, nonatomic) NSString* postCount;


@end
