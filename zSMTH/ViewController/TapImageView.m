//
//  TapImageView.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-9.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "TapImageView.h"


@implementation TapImageView

@synthesize idxPost;
@synthesize idxImage;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    self = [super init];
    if (self)
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tapped:)];
        [self addGestureRecognizer:tap];
        
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
        self.loaded = NO;
    }
    return self;
}


- (void) Tapped:(UIGestureRecognizer *) gesture
{
    if ([self.delegate respondsToSelector:@selector(tappedWithObject:)])
    {
        [self.delegate tappedWithObject:self];
    }
}

- (void)dealloc
{
    self.delegate = nil;
}

@end
