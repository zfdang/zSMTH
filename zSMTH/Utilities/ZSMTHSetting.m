//
//  ZSMTHSetting.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ZSMTHSetting.h"

@implementation ZSMTHSetting
{
    NSUserDefaults *user;
}

+ (id)sharedManager {
    static ZSMTHSetting *setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setting = [[self alloc] init];
    });
    return setting;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // empty statements
        user = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


- (NSString *)username
{
    return [user stringForKey:@"username"];
}

- (void)setUsername:(NSString *)username
{
    [user setObject:username forKey:@"username"];
}


- (NSString *)password
{
    return [user stringForKey:@"password"];
}

- (void)setPassword:(NSString *)password
{
    [user setObject:password forKey:@"password"];
}
@end
