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

@synthesize delegate;

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

    //show image
    if([post.attachments count] > 0){
        mImgHeights = [[NSMutableArray alloc] init];
        NSArray* attachs = post.attachments;

        CGRect rect = self.postContent.frame;
        CGFloat imgOffset = [self.postContent get_height] + rect.origin.y + 5;
        
        for(int i=0; i<[attachs count]; i++){
            
            SMTHAttachment *att = (SMTHAttachment*)[attachs objectAtIndex:i];
            
            UIImageView * imageview = [[UIImageView alloc] init];
            NSString * url = [NSString stringWithFormat:@"http://att.newsmth.net/nForum/att/%@/%@/%ld", post.postBoard, post.postID, att.attPos];
            NSLog(@"Image URL: %@", url);
            
            // 20 is the height of placeholder image
            [mImgHeights insertObject:[NSNumber numberWithFloat:20.0] atIndex:i];
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [imageview sd_setImageWithURL:[NSURL URLWithString:url]
                         placeholderImage:[UIImage imageNamed:@"loading"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    CGFloat curImageHeight = rect.size.width * image.size.height / image.size.width;
                                    // update the exact image height
                                    [mImgHeights insertObject:[NSNumber numberWithFloat:curImageHeight] atIndex:i];
                                    
                                    // find current image offset
                                    CGFloat curImageOffset = imgOffset;
                                    for (int j = 0; j < i; j++) {
                                        // calculate sum of previous images's height
                                        float imgHeight = [[mImgHeights objectAtIndex:j] floatValue];
                                        curImageOffset += imgHeight + 5;
                                    }
                                    imageview.frame = CGRectMake(rect.origin.x, curImageOffset, rect.size.width, curImageHeight);
                                    
                                    // if image was not loaded before, refresh tableview
                                    if(self.delegate && att.loaded == NO){
                                        att.loaded = YES;
                                        [self.delegate RefreshTableView];
                                    }
                                }];

            if(att.loaded == NO){
                // image has not been loaded, so use placeholder image
                float curImageOffset = imgOffset;
                for (int j = 0; j < i; j++) {
                    // calculate sum of previous images's height
                    float imgHeight = [[mImgHeights objectAtIndex:j] floatValue];
                    curImageOffset += imgHeight + 5;
                }
                imageview.frame = CGRectMake(rect.origin.x, curImageOffset, 100, 20);
            }
            [self.cellView addSubview:imageview];
        }
    }
    
    // set cell border
    [self.cellView.layer setBorderColor:[UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0].CGColor];
    [self.cellView.layer setBorderWidth:2.0f];
}

-(CGFloat) getCellHeight
{
    CGRect rect = self.postContent.frame;
    
    // this is the image offset to post content
    CGFloat height = [self.postContent get_height] + rect.origin.y + 5;
    
    if(mImgHeights != nil){
        CGFloat imageHeights = 0;
        for (int i = 0; i < [mImgHeights count]; i++) {
            // calculate sum of previous images's height
            imageHeights += [[mImgHeights objectAtIndex:i] floatValue];
            imageHeights += 5;
        }
        height += imageHeights;
    }
    return height + 10;
    
}

@end
