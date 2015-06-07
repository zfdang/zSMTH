//
//  SMTHAttachment.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-28.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "SMTHAttachment.h"

@implementation SMTHAttachment

@synthesize attName;
@synthesize attPos;
@synthesize attSize;
@synthesize imgHeight;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loaded = NO;
    }
    return self;
}

-(BOOL) isImage
{
    if(self.attName == nil)
        return NO;
    
    NSString* extension = [self.attName pathExtension];
    BOOL isImage = ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame)
    || ([extension caseInsensitiveCompare:@"jpeg"] == NSOrderedSame)
    || ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame)
    || ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame)
    || ([extension caseInsensitiveCompare:@"bmp"] == NSOrderedSame)
    || ([extension caseInsensitiveCompare:@"tiff"] == NSOrderedSame);
    
    return isImage;
}

@end
