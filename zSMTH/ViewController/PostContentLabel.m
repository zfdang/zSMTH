//
//  ContentLabel.m
//  BBSAdmin
//
//  Created by HE BIAO on 3/17/14.
//  Copyright (c) 2014 newsmth. All rights reserved.
//

#import "PostContentLabel.h"
static CGFloat kEspressoDescriptionTextFontSize = 17;

@interface PostContentLabel()
{
}
@end

@implementation PostContentLabel

- (void)setContentInfo:(NSString *)text
{
    // 设置TTT label的一些属性
    self.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    if(text.length < 2000){
        // 当文本太长时，不做链接的检查，否则性能会太差
        self.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    }

    // 去除开始、结尾的空格、换行符
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(text && [text length] > 0) {
        // 过滤ASCII控制符，参照
        // http://www.newsmth.net/bbs0an.php?path=%2Fgroups%2Fsystem.faq%2FASCIIart%2Ffaq%2Ffaq02
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[;0-9]*m" options:NSRegularExpressionCaseInsensitive error:&error];
        text = [regex stringByReplacingMatchesInString:text
                                               options:0
                                                 range:NSMakeRange(0, [text length])
                                          withTemplate:@""];
    }

    // UILabel has maximum height, if content size is too large, content will be invisible
    //    http://stackoverflow.com/questions/14125563/uilabel-view-disappear-when-the-height-greater-than-8192
    //    http://stackoverflow.com/questions/1493895/uiview-what-are-the-maximum-bounds-dimensions-i-can-use
    // 所以需要限制text的长度
    // 截取前5000个字符
    BOOL truncated = NO;
    if(text.length > 3500){
        text = [text substringToIndex:3500];
        truncated = YES;
    }

    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    // create font for attString
    UIFont * font = [self font];
    kEspressoDescriptionTextFontSize = font.pointSize;
    CTFontRef font_ref = CTFontCreateWithName((CFStringRef)font.fontName, kEspressoDescriptionTextFontSize, nil);
    
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

        if([line hasPrefix:@"--"]){
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
                                            font_ref, kCTFontAttributeName,
                                            [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                            [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                            nil];
                    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
                } else
                {
                    // 正文模式
                    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                            (id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName,
                                            font_ref, kCTFontAttributeName,
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
                                    font_ref, kCTFontAttributeName,
                                    [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                    [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                    nil];
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
        } else
        {
            // 正文模式
            NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName,
                                    font_ref, kCTFontAttributeName,
                                    [UIColor whiteColor].CGColor, kCTStrokeColorAttributeName,
                                    [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                    nil];
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:subContent attributes:attrs]];
        }
    }

    // 加上被截取的提示信息
    if(truncated) {
        NSString *hint = @"\n\n帖子太长，阅读全文请在浏览器中打开...";
        NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)[UIColor redColor].CGColor, kCTForegroundColorAttributeName,
                                font_ref, kCTFontAttributeName,
                                [UIColor grayColor].CGColor, kCTStrokeColorAttributeName,
                                [NSNumber numberWithFloat:0.0f], kCTStrokeWidthAttributeName,
                                nil];
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",hint] attributes:attrs]];
    }

    CFRelease(font_ref);
    self.text = attString;
}

- (CGFloat)getContentHeight
{
    static CGFloat padding = 0.0;

    UIFont *systemFont = [UIFont systemFontOfSize:kEspressoDescriptionTextFontSize];
//    CGSize textSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX); // rough accessory size
    // tableviewcell does not resize with UIScreen size, but I guess this issue can be fixed somehow
    // before we fix the issue, use UIScreen's width
    CGRect rect = [UIScreen mainScreen].bounds;
    // 12 is the trailing and leading to cellview -> contentview
    CGSize textSize = CGSizeMake(rect.size.width - 12, CGFLOAT_MAX); // rough accessory size
    CGSize sizeWithFont = [self.text sizeWithFont:systemFont constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat result =  sizeWithFont.height + padding;
    return result;
}

// http://www.jamesvandyne.com/improve-performance-and-draw-your-own-strings-on-iphone/
//UILabel is great for displaying static or mostly static text on the screen. However
//if you are going to be updating it with any frequency, it is advantageous to draw text
//manually. UILabel uses the drawInRect: or drawAtPoint: methods to draw anyways, calling
//them directly saves your phone from a lot of unneeded calls. This equates to less execution
//faster which in turn means more battery life for your users. A win for everybody.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

@end
