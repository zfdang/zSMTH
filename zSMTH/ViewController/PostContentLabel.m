//
//  ContentLabel.m
//  BBSAdmin
//
//  Created by HE BIAO on 3/17/14.
//  Copyright (c) 2014 newsmth. All rights reserved.
//

#import "PostContentLabel.h"
static CGFloat kPostContentFontSize = 17;

@interface PostContentLabel()
{
    NSMutableAttributedString *attString;
}
@end

@implementation PostContentLabel

- (void)setContentInfo:(NSString *)text
{
    // 设置TTT label的一些属性
    self.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;

    attString = [[NSMutableAttributedString alloc] initWithString:@""];

    // create font for attString
    UIFont *font = [self font];
    font = [UIFont fontWithName:font.fontName size:kPostContentFontSize];

    __block BOOL is_in_quota_mode = false;
    __block NSMutableString *subContent = [[NSMutableString alloc] initWithCapacity:2000];
    __block int empty_line_counter = 0;
    [text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop)
    {
        bool is_quota = false;
        
        if(line.length == 0){
            empty_line_counter += 1;
            if(empty_line_counter >= 2){
                // 当有多余两个空行出现时，只增加2个空行
                return;
            }
        } else {
            empty_line_counter = 0;
        }

        if([line compare:@"--"] == NSOrderedSame){
            // 签名档，skip剩余的所有行
            *stop = YES;
            return;
        }

        if([line hasPrefix:@": "])
        {
            // 引文
            is_quota = true;
        }

        if(is_quota != is_in_quota_mode)
        {
            // 首先给原来的内容加一个换行
            [subContent appendString:@"\n"];

            // 新一行的模式和之前的不一样了，需要把之前的内容加入到attString中去
            if(subContent.length > 0)
            {
                if(is_in_quota_mode)
                {
                    // 引文模式
                    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                            (id)[UIColor grayColor].CGColor, kCTForegroundColorAttributeName,
                                            font, NSFontAttributeName,
                                            [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                            [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                            nil];
                    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
                } else
                {
                    // 正文模式
                    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                            (id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName,
                                            font, NSFontAttributeName,
                                            [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                            [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                            nil];
                    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
                }

                // 更改模式，开始新的subContent的累积
                is_in_quota_mode = is_quota;
                [subContent setString:line];
            }
        } else
        {
            // 模式没有变化，则将当前行加入到subContent中
            if(subContent.length > 0){
                [subContent appendFormat:@"\n%@",line];
            } else {
                [subContent appendFormat:@"%@",line];
            }
        }
    }]; // enumerateLinesUsingBlock

    // 遗留下的subContent, 根据当前模式，添加到attString中去
    if(subContent.length > 0)
    {
        if(is_in_quota_mode)
        {
            // 引文模式
            NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id)[UIColor grayColor].CGColor, kCTForegroundColorAttributeName,
                                    font, NSFontAttributeName,
                                    [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                    [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                    nil];
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
        } else
        {
            // 正文模式
            NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName,
                                    font, NSFontAttributeName,
                                    [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                    [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                    nil];
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
        }
    }

    self.text = attString;
}

- (CGFloat)getContentHeight
{
    // create font for attString
    UIFont *font = [self font];
    font = [UIFont fontWithName:font.fontName size:kPostContentFontSize];

    // tableviewcell does not resize with UIScreen size, but I guess this issue can be fixed somehow
    // before we fix the issue, use UIScreen's width
    CGRect rect = [UIScreen mainScreen].bounds;
    // 12 is the trailing and leading to cellview -> contentview
    // CGSize frameSize = CGSizeMake(rect.size.width - 12, CGFLOAT_MAX);
    CGSize frameSize = CGSizeMake(rect.size.width - 12, CGFLOAT_MAX);
    // 采用 TTTAttributedLabel 提供的方法来算高度
//    CGRect newSize = [self.text boundingRectWithSize:frameSize
//                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
//                               attributes:@{NSFontAttributeName:font}
//                                  context:nil];
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attString withConstraints:frameSize limitedToNumberOfLines:0];
    return ceil(size.height);
}

// http://www.jamesvandyne.com/improve-performance-and-draw-your-own-strings-on-iphone/
//UILabel is great for displaying static or mostly static text on the screen. However
//if you are going to be updating it with any frequency, it is advantageous to draw text
//manually. UILabel uses the drawInRect: or drawAtPoint: methods to draw anyways, calling
//them directly saves your phone from a lot of unneeded calls. This equates to less execution
//faster which in turn means more battery life for your users. A win for everybody.
//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//}

@end
