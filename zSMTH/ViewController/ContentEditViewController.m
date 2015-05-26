//
//  ContentEditViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-12.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "ContentEditViewController.h"
#import "AttachSelectorTableViewController.h"
#import "UpdateAttachmentsProtocol.h"
#import "ZSMTHSetting.h"
#import "smth_netop.h"
#import "UIView+Toast.h"
#import "UIImage+Resize.h"

@import AssetsLibrary;


@interface ContentEditViewController () <UITextViewDelegate, UpdateAttachmentsProtocol>
{
    long replyID;
    int mailPosition;

    NSString *origSubject;
    NSString *origContent;
    NSString *author;
    NSString *quotedContent;
    NSString *quotedSubject;
    long article_id;
}
@end

@implementation ContentEditViewController

@synthesize engName;
@synthesize recipient;
@synthesize mAttachments;
@synthesize actionType;

- (void)viewDidLoad {
    [super viewDidLoad];

    // 两种模式，发文/回文，或者发信/回信
    // 发信又分为两种情形，一种是在信箱里开始写新邮件，另一种是在文章内容时，直接回信给作者
    if(self.actionType == ACTION_REPLY_POST) {
        self.title = @"回复文章";
        self.txtAction.text = [NSString stringWithFormat:@"回帖 @ %@", self.engName];
        [self.navigationItem.rightBarButtonItem setTitle:@"回帖"];
    } else if (self.actionType == ACTION_NEW_POST) {
        self.title = @"发表文章";
        self.txtAction.text = [NSString stringWithFormat:@"发帖 @ %@", self.engName];
        [self.navigationItem.rightBarButtonItem setTitle:@"发贴"];
    } else if(self.actionType == ACTION_REPLY_POST_TO_MAIL) {
        // 在文章内容处，直接回信给作者
        self.title = @"回信给作者";
        self.txtAction.text = [NSString stringWithFormat:@"回信 => %@", self.recipient];
        self.btAttachment.enabled = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"回信"];
    } else if(self.actionType == ACTION_REPLY_MAIL) {
        // 在信箱里，回复邮件
        self.title = @"回复邮件";
        self.txtAction.text = [NSString stringWithFormat:@"回信 => %@", self.recipient];
        self.btAttachment.enabled = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"回信"];
    } else if(self.actionType == ACTION_NEW_MAIL){
        // 在信箱里，开始写新邮件
        self.title = @"写新邮件";
        self.txtAction.text = @"";
        [self.txtAction setEnabled:YES];
        self.btAttachment.enabled = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"发信"];
    }

    // receive content updating message
    self.txtContent.delegate = self;

    // reply post, set subject & conent at the beginning
    if(quotedContent) {
        [self.txtSubject  setText:quotedSubject];
        [self.txtContent setText:quotedContent];
        self.txtSummary.text = [NSString stringWithFormat:@"%lu", (unsigned long)quotedContent.length];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

- (void) setOrigPostInfo:(long)postID subject:(NSString*)subject author:(NSString*)_author content:(NSString*)content
{
    replyID = postID;
    origSubject = subject;
    origContent = content;
    author = _author;

    // set init subject and content
    // Re: 有遭遇过小米4的GPS门没
    if([origSubject hasPrefix:@"Re:"]){
        quotedSubject = origSubject;
    } else {
        quotedSubject = [NSString stringWithFormat:@"Re: %@",origSubject];
    }

    //    【 在 alroy (alroy) 的大作中提到: 】
    //    : 小米4到手快一个月了
    //    : 昨天开车，车载导航有个地址搜不到，就想试试手机上的百度导航
    //    : 结果发现坑爹了，小米4的GPS数一直是0，百度地图一直提示让我开到开阔地方去。
    //    : ...................
    __block int index = 0;
    __block NSString * bodyRef = [NSString stringWithFormat:@"\n\n【 在 %@ 的%@中提到: 】", author, @"大作"];
    [origContent enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSString *newline = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(newline.length > 0){
            if(index < 3){
                bodyRef = [bodyRef stringByAppendingFormat:@"\n: %@", newline];
            } else if(index == 3){
                bodyRef = [bodyRef stringByAppendingString:@"\n: ...................."];
            } else {
                *stop = YES;
            }
            index += 1;
        }
    }];
    quotedContent = bodyRef;
}

- (void) setOrigMailInfo:(int)position recipient:(NSString*)_recipient subject:(NSString*)_origSubject content:(NSString*)_origContent;
{
    // 设置好subject和content
    [self setOrigPostInfo:0 subject:_origSubject author:_recipient content:_origContent];
    
    // 在邮箱处发信，recipient和mailposition都为空/0
    // 在邮箱处回信，mailposition不为0
    // 在文章出回信，recipient不为空
    self.recipient = _recipient;
    mailPosition = position;
}

- (IBAction)editAttachments:(id)sender {
    // this implementation is bad, these two controllers are tightly combined
    AttachSelectorTableViewController *selector = [self.storyboard instantiateViewControllerWithIdentifier:@"attachselectController"];
    selector.delegate = self;
    selector.mAssets = [NSMutableArray arrayWithArray:self.mAttachments];
    [self.navigationController pushViewController:selector animated:YES];
}


- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
    self.progressTitle = @"发文中...";
    [self startAsyncTask];
}

#pragma mark - Async tasks from ExtendedUIViewController

- (void)asyncTask
{
    article_id = 0;
    
    // 1. upload attachment one by one
    if(self.mAttachments){
        int index = 1;
        for (id item in self.mAttachments) {
            // set progress bar title
            progressBar.labelText = [NSString stringWithFormat:@"上载图片%d/%lu...", index, (unsigned long)[self.mAttachments count]];
            
            ALAsset *asset = (ALAsset*)item;
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            
            // get temp filename
            NSString* filename = [representation filename];
            NSString *tempfile = [setting getAttachmentFilepath:filename];

            // resize image
            CGImageRef cgimage = [representation fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
            // resize image
            CGSize size = CGSizeMake(1280,1280);
            UIImage *sizedImage = [UIImage imageWithImage:image scaledToFitToSize:size];
//            NSLog(@"Image resized from %f*%f ==> %f*%f", image.size.width, image.size.height, sizedImage.size.width, sizedImage.size.height);

            // find proper compression ratio
            CGFloat qs = 1.0f;
            CGFloat max_size = 1.0 * 1024 * 1024;
            NSData * data = UIImageJPEGRepresentation(sizedImage, 1.0);
            int cur_size = (int)[data length];
//            int resized_size = cur_size;
            while(cur_size > max_size && qs > 0.1f){
                qs -= 0.1f;
                data = UIImageJPEGRepresentation(sizedImage, qs);
                cur_size = (int)[data length];
            }
//            NSLog(@"Impression compressed from %d ==> %d, ratio = %f", resized_size, cur_size, qs);
            
            // write image to temp file
            [UIImageJPEGRepresentation(sizedImage, qs) writeToFile:tempfile atomically:YES];

            // upload temp file to server
//            NSLog(@"Handle attachment: %@, %@", filename, tempfile);

            int error;
            int ret = apiNetAddAttachment(tempfile, &error);
            if(ret != 0){
//                NSLog(@"Upload attachment [%@] failure: %d, %d, %@", filename, error, helper.smth->net_error, helper.smth->net_error_desc);
                NSString * errlog = [NSString stringWithFormat:@"添加附件%@出错!",filename];
                UIAlertView *altview = [[UIAlertView alloc]initWithTitle:@"错误" message:errlog delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [altview show];
                return;
            }
            
            index += 1;
        }
    }

    // 2. post file content
    // set progress bar title

    NSString *title = self.txtSubject.text;
    NSString *content = [NSString stringWithFormat:@"%@\n#发送自zSMTH@IOS", self.txtContent.text];
    NSString *target = [self.txtAction.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.actionType == ACTION_REPLY_POST){
        progressBar.labelText = @"发表回复中...";
        article_id = [helper.smth net_ReplyArticle:self.engName :replyID :title :content];
    } else if (self.actionType == ACTION_NEW_POST){
        progressBar.labelText = @"发表文章中...";
        article_id = [helper.smth net_PostArticle:self.engName :title :content];
    } else if (self.actionType == ACTION_NEW_MAIL){
        progressBar.labelText = @"寄信中...";
        article_id = [helper.smth net_PostMail:target :title :content];
    } else if (self.actionType == ACTION_REPLY_MAIL){
        progressBar.labelText = @"回信中...";
        article_id = [helper.smth net_ReplyMail:mailPosition :title :content];
    } else if (self.actionType == ACTION_REPLY_POST_TO_MAIL){
        progressBar.labelText = @"回信到作者中...";
        article_id = [helper.smth net_PostMail:recipient :title :content];
    }
}

- (void)finishAsyncTask
{
    if(self.actionType == ACTION_REPLY_POST || self.actionType == ACTION_NEW_POST) {
        if(helper.smth->net_error != 0)
        {
            NSLog(@"Post articile failure: %d, %@", helper.smth->net_error, helper.smth->net_error_desc);
            NSString * errlog = [NSString stringWithFormat:@"文章发表失败(%d, %@)!请稍后重试...", helper.smth->net_error, helper.smth->net_error_desc];
            UIAlertView *altview = [[UIAlertView alloc]initWithTitle:@"发表失败" message:errlog delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [altview show];
        } else {
            NSString *message = [NSString stringWithFormat:@"文章发表成功, id = %ld", article_id];
            UIAlertView *altview = [[UIAlertView alloc]initWithTitle:@"发表成功!" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [altview show];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if(helper.smth->net_error != 0)
        {
            NSLog(@"Send mail failure: %d, %@", helper.smth->net_error, helper.smth->net_error_desc);
            NSString * errlog = [NSString stringWithFormat:@"发信失败(%d, %@)!请稍后重试...", helper.smth->net_error, helper.smth->net_error_desc];
            UIAlertView *altview = [[UIAlertView alloc]initWithTitle:@"发信失败" message:errlog delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [altview show];
        } else {
            NSString *message = [NSString stringWithFormat:@"信件发送成功"];
            UIAlertView *altview = [[UIAlertView alloc]initWithTitle:@"发信成功!" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [altview show];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark - UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView
{
    self.txtSummary.text = [NSString stringWithFormat:@"%lu",(unsigned long)textView.text.length];
}

#pragma mark - UpdateAttachmentsProtocol

- (void)updateAttachments:(NSArray *)attachments
{
    self.mAttachments = [NSMutableArray arrayWithArray:attachments];
    if(self.mAttachments)
    {
        self.txtAttach.text = [NSString stringWithFormat:@"共有%lu个附件",(unsigned long)[self.mAttachments count]];
    } else {
        self.txtAttach.text = @"无附件";
    }
}
@end
