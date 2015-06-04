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
#import "UIImage+Resize.h"

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

-(void) setCellContent:(SMTHPost*)post delegate:(id<TTTAttributedLabelDelegate>)obj

{
    // 设置用户头像
    SMTHHelper *helper = [SMTHHelper sharedManager];
    [self.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
    self.imageAvatar.layer.cornerRadius = 10.0;
    self.imageAvatar.layer.borderWidth = 0;
    self.imageAvatar.clipsToBounds = YES;

    // 设置标题，时间，楼层
    self.postAuthor.text = post.author;
    self.postTime.text = post.postDate;
    if(post.replyIndex == 0){
        self.postIndex.text = @"楼主";
    } else {
        self.postIndex.text = [NSString stringWithFormat:@"%ld楼",post.replyIndex];
    }
    
//    NSLog(@"%@", post.postContent);

    NSMutableArray *contentSegments = [[NSMutableArray alloc] init];
    NSMutableIndexSet *attachIndex = [[NSMutableIndexSet alloc] init];
    // 将内容分成不同的片段，单独显示
    // split post contents by [upload=1][/upload]
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\[upload=\\d+\\]\\[/upload\\]"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    // 按照找到的upload, 将文章内容分节
    __block NSRange preRange = NSMakeRange(0, 0);
    [regex enumerateMatchesInString:post.postContent
                            options:0
                              range:NSMakeRange(0, [post.postContent length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
    {
        // 将upload前的内容放到数组里
        NSRange ran = NSMakeRange(preRange.location + preRange.length,
                                  match.range.location - preRange.location - preRange.length);
        NSString *segment = [post.postContent substringWithRange:ran];
        // 去除开始、结尾的空格、换行符
        segment = [segment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(segment.length > 0){
            [contentSegments addObject:segment];
        }

        // 将upload也放到数组里
        NSString *matchedString = [post.postContent substringWithRange:match.range];
        NSString *matchedIndex = [matchedString substringWithRange:NSMakeRange(8, matchedString.length - 18)];
        // index是从1开始的
        int imgIndex = [matchedIndex intValue] - 1;
        if(imgIndex < [post.attachments count]) {
            // 确保图片的index是有效的
            [attachIndex addIndex:imgIndex];
            [contentSegments addObject:[NSNumber numberWithInt:imgIndex]];
        }
        preRange = match.range;
    }];
    // 如果upload后面还有内容，也放到数组里
    NSRange ran = NSMakeRange(preRange.location + preRange.length,
                              post.postContent.length - preRange.location - preRange.length);
    NSString *segment = [post.postContent substringWithRange:ran];
    if([segment length] > 0 ) {
        [contentSegments addObject:segment];
    }
    // 如果有些图片附件不在文章内容里，还需要将对应图片放到后面去
    for(int i=0; i<[post.attachments count]; i++){
        if(![attachIndex containsIndex:i]){
            [contentSegments addObject:[NSNumber numberWithInt:i]];
        }
    }

    // 如果某个内容过长，还需要对内容进一步进行拆分，避免单个content的高度太高
    // UILabel has maximum height, if content size is too large, content will be invisible
    //    http://stackoverflow.com/questions/14125563/uilabel-view-disappear-when-the-height-greater-than-8192
    //    http://stackoverflow.com/questions/1493895/uiview-what-are-the-maximum-bounds-dimensions-i-can-use
    // 所以需要限制text的长度
    // TODO

    // 显示results里存储的结果
    NSLog(@"-----------------------");
    NSLog(@"Number of segments = %d", [contentSegments count]);
    for (id item in contentSegments) {
        if([item isKindOfClass:[NSString class]]) {
            NSString *content = (NSString*) item;
            NSLog(@"Content, length = %d", content.length);
//            NSLog(@"%@", content);
        } else if ([item isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber*)item;
            NSLog(@"Attachment, index = %d", [num intValue]);
        }
    }
    NSLog(@"-----------------------");


    // 因为cell可能会被重用，所以要先清除之前可能添加进去的subview
    NSArray *subviews = [self.cellView subviews];
    for (id subview in subviews) {
        if([subview isKindOfClass:[TapImageView class]] || [subview isKindOfClass:[TTTAttributedLabel class]]){
            UIView *view = (UIView*) subview;
            [view removeFromSuperview];
        }
    }

    // 每个subview的高度，清零
    mSubviewHeights = [[NSMutableArray alloc] init];
    
    // 将每个segment添加到cellView中去
    CGRect rect = self.postContentHeader.frame;
    // tableviewcell does not resize with UIScreen size, but I guess this issue can be fixed somehow
    // before we fix the issue, use UIScreen's width
    CGRect rectScreen = [UIScreen mainScreen].bounds;
    // 12 is not a magic number;
    // cellView is 4 + 4 smaller than screen
    // post content is 2 + 2 smaller than cellview;
    rect.size.width = rectScreen.size.width - 12;


    for (int i = 0; i < [contentSegments count]; i++) {
        
        // 计算当前subview的垂直偏移量
        float curSubviewOffset = rect.origin.y;
        for (int j = 0; j < i; j++) {
            // calculate sum of previous images's height
            float subviewHeight = [[mSubviewHeights objectAtIndex:j] floatValue];
            curSubviewOffset += subviewHeight + 5;
        }

        id item = [contentSegments objectAtIndex:i];
        if([item isKindOfClass:[NSString class]]) {
            // 这是帖子内容的一个片段
            NSString *content = (NSString*) item;
            NSLog(@"Content, length = %d", content.length);

            PostContentLabel * labelView = [[PostContentLabel alloc] init];
            if(post.postContent.length < 2000) {
                labelView.enabledTextCheckingTypes = NSTextCheckingTypeLink;
                labelView.delegate = obj;
            } else {
                // 当文本太长时，不做链接的检查，否则性能会太差
                labelView.enabledTextCheckingTypes = 0;
            }
            [labelView setContentInfo:content];
            CGFloat subviewHeight = [labelView getContentHeight];
            labelView.frame = CGRectMake(rect.origin.x, curSubviewOffset, rect.size.width, subviewHeight);
            [self.cellView addSubview:labelView];

            [mSubviewHeights insertObject:[NSNumber numberWithFloat:subviewHeight] atIndex:i];
            continue;
            
        } else if ([item isKindOfClass:[NSNumber class]]) {
            // 这是帖子的一个附件
            NSNumber *num = (NSNumber*)item;
            NSLog(@"Attachment, index = %d", [num intValue]);
            
            SMTHAttachment *att = (SMTHAttachment*)[post.attachments objectAtIndex:[num intValue]];
            
            if(![att isImage]){
                // this is not an image
                [mSubviewHeights insertObject:[NSNumber numberWithFloat:0.0] atIndex:i];
                continue;
            }
            
            // 创建图片附件subview
            TapImageView * imageview = [[TapImageView alloc] init];
            imageview.idxPost = self.idxPost;
            imageview.idxImage = [num intValue];
            imageview.delegate = self.delegate;
        
            // 20 is the height of placeholder image
            [mSubviewHeights insertObject:[NSNumber numberWithFloat:20.0] atIndex:i];
            
            // Here we use the new provided sd_setImageWithURL: method to load the web image
            [imageview sd_setImageWithURL: [post getAttachedImageURL:[num intValue]]
                         placeholderImage:[UIImage imageNamed:@"loading"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    if(error != nil) {
                                        // 下载失败，使用loadingfailure图片来替代原来的placeholder image
                                        NSLog(@"failed to download %@, error is %@", imageURL, error);
                                        image = [UIImage imageNamed:@"loadingfailure"];
                                        imageview.image = image;
                                    } else {
                                        // 下载成功, 计算满宽情况下，图片的高度
                                        CGFloat curImageHeight = rect.size.width * image.size.height / image.size.width;
                                        // update the exact image height
                                        if(i < [mSubviewHeights count]){
                                            [mSubviewHeights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:curImageHeight]];
                                        } else {
                                            [mSubviewHeights insertObject:[NSNumber numberWithFloat:curImageHeight] atIndex:i];
                                        }
                                        
                                        // 缩小图片，否则占用内存会太大
                                        if(image.size.height > curImageHeight) {
                                            // NSLog(@"resize image, from %f * %f ==> %f * %f", image.size.width, image.size.height, rect.size.width, curImageHeight);
                                            CGSize size = CGSizeMake(rect.size.width, curImageHeight);
                                            image = [UIImage imageWithImage:image scaledToFitToSize:size];
                                        }

                                        // find current image y offset
                                        CGFloat curImageOffset = 0;
                                        for (int j = 0; j < i; j++) {
                                            // calculate sum of previous subviews' height
                                            float subviewHeight = [[mSubviewHeights objectAtIndex:j] floatValue];
                                            curImageOffset += subviewHeight + PaddingBetweenImages;
                                        }
                                        CGRect frame = CGRectMake(rect.origin.x, curImageOffset, rect.size.width, curImageHeight);
                                        imageview.frame = frame;
                                        
                                        // if image was not loaded before, refresh tableview
                                        if(self.delegate && att.loaded == NO){
                                            att.loaded = YES;
                                            [self.delegate RefreshTableView];
                                        }
                                    }
                                }];
            
            if(att.loaded == NO){
                imageview.frame = CGRectMake(rect.origin.x, curSubviewOffset, 100, 20);
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
    CGRect rect = self.postContentHeader.frame;
    
    // this is the image offset to post content
    CGFloat content_height = self.postContentHeader.frame.size.height;
    CGFloat result = rect.origin.y + content_height + PaddingBetweenContentAndImage;
    
//    NSLog(@"header height is %f, content height = %f", rect.origin.y, content_height);
    if(mSubviewHeights != nil){
        CGFloat imageHeight = 0;
        for (int i = 0; i < [mSubviewHeights count]; i++) {
            // calculate sum of previous images's height
            imageHeight = [[mSubviewHeights objectAtIndex:i] floatValue];
//            NSLog(@"image index %d, height = %f", i, imageHeight);
            result += imageHeight + PaddingBetweenImages;
        }
        result += PaddingBetweenImages;
    }
//    NSLog(@"Final result is %f", result);
    return result;
}

@end
