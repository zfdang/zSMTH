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

const CGFloat PaddingBetweenSubviews = 4.0;

@interface PostContentTableViewCell()
{
    long postID;
    NSMutableArray *contentSegments;
    NSMutableArray *contentSubviews;
}
@end

@implementation PostContentTableViewCell

@synthesize delegate;
@synthesize idxPost;


- (void)awakeFromNib {
    // Initialization code
    contentSegments = [[NSMutableArray alloc] init];
    contentSubviews = [[NSMutableArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) parseSingleContentSegment:(NSString*) segment
{
    // 去除开始、结尾的空格、换行符
    segment = [segment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 检查segment是否为空
    if(segment.length > 0){
        // 如果某个内容过长，还需要对内容进一步进行拆分，避免单个content的高度太高
        // UILabel has maximum height, if content size is too large, content will be invisible
        //    http://stackoverflow.com/questions/14125563/uilabel-view-disappear-when-the-height-greater-than-8192
        //    http://stackoverflow.com/questions/1493895/uiview-what-are-the-maximum-bounds-dimensions-i-can-use
        // 所以需要限制segment的长度
        const int maxLength = 2000;
        while (segment.length > maxLength) {
            NSRange range = NSMakeRange(maxLength, segment.length - maxLength);
            NSRange result = [segment rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                                      options:0
                                                        range:range];
            if(result.location == NSNotFound) {
                result.location = maxLength;
                result.length = 0;
            }
            NSString *partialSegment = [segment substringToIndex:result.location];
            [contentSegments addObject:partialSegment];

            // 继续处理剩下的文本
            segment = [segment substringFromIndex:result.location + result.length];
        }
        [contentSegments addObject:segment];
    }
}

- (void) parsePostIntoSegments:(SMTHPost*) post
{
    // saved images index which have been shown in content
    NSMutableIndexSet *attachIndex = [[NSMutableIndexSet alloc] init];

    // 避免[img=http://xxxx.xxx][/img]的情形被detect错链接
    post.postContent = [post.postContent stringByReplacingOccurrencesOfString:@"][/img]" withString:@" ][/img]"];
    // 将内容分成不同的片段，分别显示
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

         [self parseSingleContentSegment:segment];

         // 将upload也放到数组里
         NSString *matchedString = [post.postContent substringWithRange:match.range];
         NSString *matchedIndex = [matchedString substringWithRange:NSMakeRange(8, matchedString.length - 18)];
         // index是从1开始的, 但是图片附件是从0开始的
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
    [self parseSingleContentSegment:segment];

    // 如果有些图片附件不在文章内容里，还需要将对应图片放到后面去
    for(int i=0; i<[post.attachments count]; i++){
        if(![attachIndex containsIndex:i]){
            [contentSegments addObject:[NSNumber numberWithInt:i]];
        }
    }

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
}

-(float) calculateContentOffsetForSubview:(int)index initialOffset:(float) initialOffset
{
    float result = initialOffset;
    for (int j = 0; j < index; j++) {
        // calculate sum of previous images's height
        // 这里可以被优化，其实只看最后一个的位置就可以了
        if(j < [contentSubviews count]) {
            UIView *subview = (UIView*) [contentSubviews objectAtIndex:j];
            float subviewHeight = subview.frame.size.height;
            result += subviewHeight + PaddingBetweenSubviews;
        } else {
            result += PaddingBetweenSubviews;
        }
    }
    return result;
}

-(void) setCellContent:(SMTHPost*)post
{
    NSLog(@"Post Information: %d", post.postID);

    CGRect rect = self.postContentHeader.frame;
    // tableviewcell does not resize with UIScreen size, but I guess this issue can be fixed somehow
    // before we fix the issue, use UIScreen's width
    CGRect rectScreen = [UIScreen mainScreen].bounds;
    // 12 is not a magic number;
    // cellView is 4 + 4 smaller than screen
    // post content is 2 + 2 smaller than cellview;
    rect.size.width = rectScreen.size.width - 12;
    float initialViewOffset = rect.origin.y + rect.size.height;

    if(post.postID == nil || [post.postID doubleValue] != postID) {
        NSLog(@"new cell or re-used cell, parse content into segments");

        // cell被重用了，或者是新的cell, 我们需要清理cell的信息
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

        // 将内容分成连续的segments
        [contentSegments removeAllObjects];
        [self parsePostIntoSegments:post];

        // 将postID保存下来
        postID = [post.postID doubleValue];

        // set cell border
        [self.cellView.layer setBorderColor:[UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0].CGColor];
        self.cellView.layer.cornerRadius = 5.0;
        [self.cellView.layer setBorderWidth:0.5f];
    }
    
    // 因为cell可能是被重用的，所以要先清除之前可能添加进去的subview
    //        NSArray *subviews = [self.cellView subviews];
    //        for (id subview in subviews) {
    //            if([subview isKindOfClass:[TapImageView class]] || [subview isKindOfClass:[TTTAttributedLabel class]]){
    //                UIView *view = (UIView*) subview;
    //                [view removeFromSuperview];
    //            }
    //        }
    for (UIView *view in contentSubviews) {
        [view removeFromSuperview];
    }
    [contentSubviews removeAllObjects];

    NSLog(@"****************************");
    // 将每个segment添加到cellView中去
    for (int i = 0; i < [contentSegments count]; i++) {
        id item = [contentSegments objectAtIndex:i];
        if([item isKindOfClass:[NSString class]]) {
            // 这是帖子内容的一个片段
            NSString *content = (NSString*) item;

            PostContentLabel * labelView = [[PostContentLabel alloc] init];
            if(post.postContent.length < 1000) {
                labelView.enabledTextCheckingTypes = NSTextCheckingTypeLink;
                labelView.delegate = self.delegate;
            } else {
                // 当文本太长时，不做链接的检查，否则性能会太差
                labelView.enabledTextCheckingTypes = 0;
            }
            [labelView setContentInfo:content];

            // 设置view的尺寸
            CGFloat selfHeight = [labelView getContentHeight];
            labelView.frame = CGRectMake(rect.origin.x, [self calculateContentOffsetForSubview:i initialOffset:initialViewOffset], rect.size.width, selfHeight);
            [self.cellView addSubview:labelView];

            [contentSubviews addObject:labelView];

            NSLog(@"Content view (%d): y = %f, height = %f", i, labelView.frame.origin.y, labelView.frame.size.height);
        } else if ([item isKindOfClass:[NSNumber class]]) {
            // 这是帖子的一个附件
            NSNumber *num = (NSNumber*)item;

            SMTHAttachment *att = (SMTHAttachment*)[post.attachments objectAtIndex:[num intValue]];
            if(![att isImage]){
                // this is not an image
                continue;
            }

            // 创建图片附件subview
            TapImageView * imageview = [[TapImageView alloc] init];
            imageview.idxPost = self.idxPost;
            imageview.idxImage = [num intValue];
            imageview.delegate = self.delegate;

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
                                        
                                        // 缩小图片，否则占用内存会太大
                                        if(image.size.height > curImageHeight) {
                                            // NSLog(@"resize image, from %f * %f ==> %f * %f", image.size.width, image.size.height, rect.size.width, curImageHeight);
                                            CGSize size = CGSizeMake(rect.size.width, curImageHeight);
                                            image = [UIImage imageWithImage:image scaledToFitToSize:size];
                                        }

                                        // update height & width of imageview
                                        CGRect frame = imageview.frame;
                                        frame.origin.y = [self calculateContentOffsetForSubview:i initialOffset:initialViewOffset];
                                        frame.size.height = curImageHeight;
                                        frame.size.width = rect.size.width;
                                        imageview.frame = frame;

                                        // if image was not loaded before, refresh tableview
                                        if(self.delegate && att.loaded == NO){
                                            att.loaded = YES;
                                            [self.delegate RefreshTableView];
                                        }
                                    }
                                }];

            if(att.loaded == NO){
                imageview.frame = CGRectMake(rect.origin.x, [self calculateContentOffsetForSubview:i initialOffset:initialViewOffset], 100, 20);
            }
            [self.cellView addSubview:imageview];

            [contentSubviews addObject:imageview];
            NSLog(@"Image view (%d): %f, %f", i, imageview.frame.origin.y, imageview.frame.size.height);
        }
    }
}

-(CGFloat) getCellHeight
{
    CGRect rect = self.postContentHeader.frame;
    CGFloat result = rect.origin.y + rect.size.height;

    for (int i = 0; i < [contentSubviews count]; i++) {
        // calculate sum of previous images's height
        UIView *subview  = (UIView*)[contentSubviews objectAtIndex:i];
        result += subview.frame.size.height + PaddingBetweenSubviews;
    }
    result += PaddingBetweenSubviews;

//    NSLog(@"Cell Height = %f", result);
    return result;
}

@end
