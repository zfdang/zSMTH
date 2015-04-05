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
@synthesize category;

- (instancetype)init
{
    self = [super init];
    if (self) {
        type = BOARD;
    }
    return self;
}

- (NSComparisonResult)compare:(SMTHBoard *)otherObject
{
    return [self.engName compare:otherObject.engName options:NSCaseInsensitiveSearch];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@(%@) - %@", self.chsName, self.engName, self.category];
}
@end
