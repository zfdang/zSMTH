//
//  SMTHAttachment.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-28.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FMDB.h"

@interface SMTHAttachment : NSObject
@property (strong, nonatomic) NSString *attName;
@property (nonatomic) long attPos;
@property (nonatomic) long attSize;
@property (nonatomic) CGFloat imgHeight;
@property (nonatomic) BOOL loaded;

@end
