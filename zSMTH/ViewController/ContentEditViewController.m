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

}
@end

@implementation ContentEditViewController

@synthesize engName;
@synthesize origContent;
@synthesize origSubject;
@synthesize replyID;
@synthesize mAttachments;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title;
    if(self.replyID != 0){
        title = [NSString stringWithFormat:@"回帖@%@", self.engName];
    } else {
        title = [NSString stringWithFormat:@"发帖@%@", self.engName];
    }
    self.title = title;

    // receive content updating message
    self.txtContent.delegate = self;
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
    if(self.mAttachments){
        // upload attachment one by one
        for (id item in self.mAttachments) {
            // set progress bar title
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
            NSLog(@"Image resized from %f*%f ==> %f*%f", image.size.width, image.size.height, sizedImage.size.width, sizedImage.size.height);

            // find proper compression ratio
            CGFloat qs = 1.0f;
            CGFloat max_size = 1.0 * 1024 * 1024;
            NSData * data = UIImageJPEGRepresentation(sizedImage, 1.0);
            int cur_size = (int)[data length];
            int resized_size = cur_size;
            while(cur_size > max_size && qs > 0.1f){
                qs -= 0.1f;
                data = UIImageJPEGRepresentation(sizedImage, qs);
                cur_size = (int)[data length];
            }
            NSLog(@"Impression compressed from %d ==> %d, ratio = %f", resized_size, cur_size, qs);
            
            // write image to temp file
            [UIImageJPEGRepresentation(sizedImage, qs) writeToFile:tempfile atomically:YES];

            // upload temp file to server
            NSLog(@"Handle attachment: %@, %@", filename, tempfile);

            int error;
            int ret = apiNetAddAttachment(tempfile, &error);
            if(ret != 0){
                NSLog(@"Upload attachment [%@] failure: %d, %d, %@", filename, error, helper.smth->net_error, helper.smth->net_error_desc);
                NSString * errlog = @"添加附件出错";
                UIAlertView *altview = [[UIAlertView alloc]initWithTitle:@"错误" message:errlog delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [altview show];
                return;
            } else {
                NSLog(@"Upload attachment [%@] success", filename);
                [self.view  makeToast:[NSString stringWithFormat:@"上载附件%@完成!",filename]
                                                            duration:0.5
                                                            position:CSToastPositionCenter];
            }
        }
    }

    // post file content
    NSString *title = self.txtSubject.text;
    NSString *content = self.txtContent.text;
    long article_id = [helper.smth net_PostArticle:self.engName :title :content];
    if(helper.smth->net_error == 0){
        [self.view  makeToast:@"发帖成功!"
                     duration:0.5
                     position:CSToastPositionCenter];
        
    } else {
        NSLog(@"Post articile failure: %d, %@", helper.smth->net_error, helper.smth->net_error_desc);
    }
}

- (void)finishAsyncTask
{
    
}


#pragma mark - UITextViewDelegate

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.txtSummary.text = [NSString stringWithFormat:@"%ld",textView.text.length];
}

#pragma mark - UpdateAttachmentsProtocol

- (void)updateAttachments:(NSArray *)attachments
{
    self.mAttachments = [NSMutableArray arrayWithArray:attachments];
    if(self.mAttachments)
    {
        self.txtAttach.text = [NSString stringWithFormat:@"共有%ld个附件",[self.mAttachments count]];
    } else {
        self.txtAttach.text = @"无附件";
    }
}
@end
