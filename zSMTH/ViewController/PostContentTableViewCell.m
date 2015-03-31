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
#import "SVPullToRefresh.h"
#import "SMTHAttachment.h"

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

    imageHeights = 0;
    //show image
    CGRect rect = self.postContent.frame;
    CGFloat imgOffset = [self.postContent get_height] + rect.origin.y + 5;
    NSArray* attachs = post.attachments;
    for(int i=0; i<[attachs count]; i++){
        SMTHAttachment *att = (SMTHAttachment*)[attachs objectAtIndex:i];

        UIImageView * imageview = [[UIImageView alloc] init];
        NSString * url = [NSString stringWithFormat:@"http://att.newsmth.net/nForum/att/%@/%@/%ld", post.postBoard, post.postID, att.attPos];
        NSLog(@"Image URL: %@", url);

        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [imageview sd_setImageWithURL:[NSURL URLWithString:url]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     CGFloat curImageHeight = rect.size.width * image.size.height / image.size.width;
                                     att.imgHeight = curImageHeight;
                                     CGFloat curImageOffset = imgOffset;
                                     for (int j = 0; j < i; j++) {
                                         SMTHAttachment *at = (SMTHAttachment*)[attachs objectAtIndex:j];
                                         curImageOffset += at.imgHeight + 5;
                                     }
                                     imageview.frame = CGRectMake(rect.origin.x, curImageOffset, rect.size.width, curImageHeight);
                                     imageHeights += curImageHeight + 10;
                                     [self setNeedsDisplay];
                                 }];
//        imageview.frame = CGRectMake(rect.origin.x, imgOffset + i * 10, rect.size.width, 10);
        [self.cellView addSubview:imageview];
}
    
    // set cell border
    [self.cellView.layer setBorderColor:[UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0].CGColor];
    [self.cellView.layer setBorderWidth:2.0f];
}

-(CGFloat) getCellHeight
{
    CGRect rect = self.postContent.frame;
    CGFloat height = [self.postContent get_height] + rect.origin.y + 20;
    return height + imageHeights;
}

@end
