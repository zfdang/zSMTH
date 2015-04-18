//
//  ContentLabel.h
//  BBSAdmin
//
//  Created by HE BIAO on 3/17/14.
//  Copyright (c) 2014 newsmth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "TTTAttributedLabel.h"

@interface PostContentLabel : TTTAttributedLabel
{
}

- (void)setContentInfo:(NSString *)text;
- (CGFloat)getContentHeight;

@end
