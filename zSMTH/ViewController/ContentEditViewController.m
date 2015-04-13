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
    selector.mAssets = self.mAttachments;
    [self.navigationController pushViewController:selector animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
}

#pragma mark - Async tasks from ExtendedUIViewController


- (void)asyncTask
{
    
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
    self.mAttachments = attachments;
    if(self.mAttachments)
    {
        self.txtAttach.text = [NSString stringWithFormat:@"共有%ld个附件",[self.mAttachments count]];
    } else {
        self.txtAttach.text = @"无附件";
    }
}
@end
