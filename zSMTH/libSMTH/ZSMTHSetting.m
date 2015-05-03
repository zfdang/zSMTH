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


- (BOOL)bSavePassword
{
    return [user boolForKey:@"bSavePassword"];
}

- (void)setBSavePassword:(BOOL)bSavePassword
{
    [user setBool:bSavePassword forKey:@"bSavePassword"];
}

- (BOOL)bAutoLogin
{
    return [user boolForKey:@"bAutoLogin"];
}

- (void)setBAutoLogin:(BOOL)bAutoLogin
{
    [user setBool:bAutoLogin forKey:@"bAutoLogin"];
}

- (BOOL)bShowAvatar
{
    return [user boolForKey:@"bShowAvatar"];
}

- (void)setBShowAvatar:(BOOL)bShowAvatar
{
    [user setBool:bShowAvatar forKey:@"bShowAvatar"];
}

- (BOOL)bAutoRotate
{
    return [user boolForKey:@"bAutoRotate"];
}

- (void)setBAutoRotate:(BOOL)bAutoRotate
{
    [user setBool:bAutoRotate forKey:@"bAutoRotate"];
}

- (NSString*) getAttachmentFilepath:(NSString*) fname
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PostAtt"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }

    return [diskCachePath stringByAppendingPathComponent:fname];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"user = %@, autoLogin = %d, savePassword = %d, showAvatar = %d, autoRotate = %d", self.username, self.bAutoLogin, self.bSavePassword, self.bShowAvatar, self.bAutoRotate];
}
@end
