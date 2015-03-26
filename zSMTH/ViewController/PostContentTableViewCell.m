//
//  PostContentTableViewCell.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-22.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "PostContentTableViewCell.h"
#import "SMTHHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation PostContentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setCellContent:(SMTHPost*)post
{
    SMTHHelper *helper = [SMTHHelper sharedManager];
    [self.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
    self.imageAvatar.layer.cornerRadius = 10.0;
    self.imageAvatar.layer.borderWidth = 0;
    self.imageAvatar.clipsToBounds = YES;
    
    self.postAuthor.text = post.author;
    self.postTime.text = post.postDate;
    
    if(post.replyIndex == 0){
        self.postIndex.text = @"楼主";
    } else {
        self.postIndex.text = [NSString stringWithFormat:@"%ld楼",post.replyIndex];
    }
    
    // set content
    [self.postContent setContentInfo:post.postContent];
    
    // set cell border
    CGRect rect = self.cellView.frame;
    if(post.replyIndex == 0){
        rect.origin.y += 5;
    }
    CGFloat height = [self getCellHeight];
    rect.size.height = height - 1;
    [self.cellView setFrame:rect];

    [self.cellView.layer setBorderColor:[UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0].CGColor];
    [self.cellView.layer setBorderWidth:2.0f];
}

-(CGFloat) getCellHeight
{
    CGRect rect = self.postContent.frame;
    CGFloat height = [self.postContent get_height] + rect.origin.y + 10;
    return height;
}

@end
