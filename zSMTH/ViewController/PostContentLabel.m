//
//  ContentLabel.m
//  BBSAdmin
//
//  Created by HE BIAO on 3/17/14.
//  Copyright (c) 2014 newsmth. All rights reserved.
//

#import "PostContentLabel.h"
#import "UIView+Toast.h"

static CGFloat const kEspressoDescriptionTextFontSize = 17;

@interface PostContentLabel() <TTTAttributedLabelDelegate, UIActionSheetDelegate>
{
}
@end

@implementation PostContentLabel


- (void) initTTTAttributedLabel
{
    self.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.delegate = self;
}

- (void)setContentInfo:(NSString *)text
{
    [self initTTTAttributedLabel];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@""];
    
    UIFont * font = [self font];
    CTFontRef font_ref = CTFontCreateWithName((CFStringRef)font.fontName, kEspressoDescriptionTextFontSize, nil);
    
    __block BOOL prev_line_empty = false;
    
    [text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        bool is_quota = false;
        
        unsigned long len = [line length];
        
        if(len == 0){
            prev_line_empty = true;
            return;
        }else{
            if(len >= 2){
                NSString * head = [line substringToIndex:2];
                if([head isEqualToString:@": "]){
                    is_quota = true;
                }
                if(len == 2 && [head isEqualToString:@"--"]){
                    *stop = YES;
                    return;
                }
            }
            
            if(prev_line_empty){
                NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:(id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName, font_ref, kCTFontAttributeName, [UIColor whiteColor].CGColor, (NSString *)kCTStrokeColorAttributeName, [NSNumber numberWithFloat:0.0f],(NSString *)kCTStrokeWidthAttributeName, nil];
                
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrs]];
                prev_line_empty = false;
            }
        }

        if(is_quota){
            NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:(id)[UIColor grayColor].CGColor, kCTForegroundColorAttributeName, font_ref, kCTFontAttributeName, [UIColor whiteColor].CGColor, (NSString *)kCTStrokeColorAttributeName, [NSNumber numberWithFloat:0.0f],(NSString *)kCTStrokeWidthAttributeName, nil];
            
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",line] attributes:attrs]];
        }else{
            NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:(id)[UIColor blackColor].CGColor, kCTForegroundColorAttributeName, font_ref, kCTFontAttributeName, [UIColor whiteColor].CGColor, (NSString *)kCTStrokeColorAttributeName, [NSNumber numberWithFloat:0.0f],(NSString *)kCTStrokeWidthAttributeName, nil];
            
            [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",line] attributes:attrs]];
        }
    }];
    
    CFRelease(font_ref);
    
    self.text = attString;
}

- (CGFloat)getContentHeight
{
    static CGFloat padding = 0.0;

    UIFont *systemFont = [UIFont systemFontOfSize:kEspressoDescriptionTextFontSize];
    CGSize textSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX); // rough accessory size
    CGSize sizeWithFont = [self.text sizeWithFont:systemFont constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat result =  sizeWithFont.height + padding;
    return result;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString]
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"取消", nil)
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"复制链接", nil), NSLocalizedString(@"在浏览器中打开", nil),nil
      ]
     showInView:self];
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didLongPressLinkWithURL:(__unused NSURL *)url atPoint:(__unused CGPoint)point
{
    // 长按链接，直接打开URL
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setURL:[NSURL URLWithString:actionSheet.title]];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;

        // 找到最上层的tableview, 这样好确定toast的位置
        UIView *view = self.superview;
        while (! [view isKindOfClass:[UITableView class]]){
            view = view.superview;
        }
        UITableView *tableview = (UITableView*) view;
        [tableview  makeToast:@"URL已复制到剪切板!"
                duration:0.8
                position:[NSValue valueWithCGPoint:CGPointMake(screenWidth*0.5, tableview.contentOffset.y + screenHeight*0.7)]];
    
    } else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
    }
    
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
