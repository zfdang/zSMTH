//
//  TapImageView.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-9.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapImageViewDelegate <NSObject>
- (void) tappedWithObject:(id) sender;
@end

@interface TapImageView : UIImageView
@property (weak) id<TapImageViewDelegate> delegate;
@property (nonatomic) long idxPost;
@property (nonatomic) long idxImage;
@end
