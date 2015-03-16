//
//  SMTHBoard.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-15.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHBoard.h"



@implementation SMTHBoard

@synthesize boardID;
@synthesize chsName;
@synthesize engName;
@synthesize managers;
@synthesize type;

- (instancetype)init
{
    self = [super init];
    if (self) {
        children = nil;
        type = BOARD;
    }
    return self;
}
@end
