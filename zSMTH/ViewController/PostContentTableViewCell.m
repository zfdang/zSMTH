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
#import "TapImageView.h"

const CGFloat PaddingBetweenContentAndImage = 5.0;
const CGFloat PaddingBetweenImages = 5.0;

@implementation PostContentTableViewCell

@synthesize delegate;
@synthesize idxPost;


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

        CGFloat imgOffset = [self.postContent getContentHeight] + rect.origin.y + PaddingBetweenContentAndImage;
        
        for(int i=0; i<[attachs count]; i++){
            
            SMTHAttachment *att = (SMTHAttachment*)[attachs objectAtIndex:i];
            
            if(![att isImage]){
                // this is not an image
                continue;
            }
            TapImageView * imageview = [[TapImageView alloc] init];
            imageview.idxPost = self.idxPost;
            imageview.idxImage = i;
            imageview.delegate = self.delegate;
            
            // 20 is the height of placeholder image
            [mImgHeights insertObject:[NSNumber numberWithFloat:20.0] atIndex:i];
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [imageview sd_setImageWithURL: [post getAttachedImageURL:i]
                         placeholderImage:[UIImage imageNamed:@"loading"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    CGFloat curImageHeight = rect.size.width * image.size.height / image.size.width;
                                    // update the exact image height
                                    [mImgHeights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:curImageHeight]];
                                    
                                    // find current image offset
                                    CGFloat curImageOffset = imgOffset;
                                    for (int j = 0; j < i; j++) {
                                        // calculate sum of previous images's height
                                        float imgHeight = [[mImgHeights objectAtIndex:j] floatValue];
                                        curImageOffset += imgHeight + PaddingBetweenImages;
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
    self.cellView.layer.cornerRadius = 5.0;
    [self.cellView.layer setBorderWidth:0.5f];

//    CGRect rect = self.frame;
//    NSLog(@"%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
//    rect = self.cellView.frame;
//    NSLog(@"%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

-(CGFloat) getCellHeight
{
    CGRect rect = self.postContent.frame;
    
    // this is the image offset to post content
    CGFloat content_height = [self.postContent getContentHeight];
    CGFloat result = rect.origin.y + content_height + PaddingBetweenContentAndImage;
    
//    NSLog(@"header height is %f, content height = %f", rect.origin.y, content_height);
    if(mImgHeights != nil){
        CGFloat imageHeight = 0;
        for (int i = 0; i < [mImgHeights count]; i++) {
            // calculate sum of previous images's height
            imageHeight = [[mImgHeights objectAtIndex:i] floatValue];
//            NSLog(@"image index %d, height = %f", i, imageHeight);
            result += imageHeight + PaddingBetweenImages;
        }
        result += PaddingBetweenImages;
    }
//    NSLog(@"Final result is %f", result);
    return result;
}

@end
