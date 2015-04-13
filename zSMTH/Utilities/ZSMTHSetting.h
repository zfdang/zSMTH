//
//  ZSMTHSetting.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSMTHSetting : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (nonatomic) BOOL bAutoLogin;
@property (nonatomic) BOOL bSavePassword;

+ (id)sharedManager;

- (NSString*) getAttachmentFilepath:(NSString*)fname;

@end
