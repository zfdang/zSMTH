//
//  PostContentTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-22.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "PostContentTableViewController.h"
#import "SVPullToRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostContentTableViewCell.h"
#import "SMTHPost.h"

@interface PostContentTableViewController ()
{
    NSArray *mPosts;
}

@end

@implementation PostContentTableViewController

@synthesize postID;
@synthesize boardName;

- (void)viewDidLoad {
    [super viewDidLoad];

    // load first page
    mPosts = [[NSMutableArray alloc] init];
    self.progressTitle = @"加载中...";
    
    [self startAsyncTask];
}

- (void)asyncTask
{
    mPosts = [helper getPostContents:boardName postID:postID from:0];
}


- (void)finishAsyncTask
{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [mPosts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PostContentTableViewCell";
    
    PostContentTableViewCell *cell = (PostContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (PostContentTableViewCell*)[nibArray objectAtIndex:0];
    }

    SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:indexPath.row];

    UIWebView *aWebView = cell.webContent;
    aWebView.scrollView.scrollEnabled = NO;
    [aWebView loadHTMLString:post.postContent baseURL:nil];
    
    CGRect frame = aWebView.frame;
    frame.size.height = 1;

    CGSize fittingSize = [aWebView sizeThatFits:frame.size];
//    frame.size.height = aWebView.scrollView.contentSize.height;
    
    return fittingSize.height + 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PostContentTableViewCell";
    
    PostContentTableViewCell *cell = (PostContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (PostContentTableViewCell*)[nibArray objectAtIndex:0];
    }
    
    if (indexPath.section == 0) {
        SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:indexPath.row];
        
        [cell.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        cell.imageAvatar.layer.cornerRadius = 10.0;
        cell.imageAvatar.layer.borderWidth = 0;
        cell.imageAvatar.clipsToBounds = YES;
        
        cell.postAuthor.text = post.author;
        cell.postTime.text = post.postDate;
        
        if(post.replyIndex == 0){
            cell.postIndex.text = @"楼主";
        } else {
            cell.postIndex.text = [NSString stringWithFormat:@"%ld楼",post.replyIndex];
        }
        
        
        [cell.webContent loadHTMLString:post.postContent baseURL:nil];
        cell.webContent.scrollView.scrollEnabled = NO;
    }
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)return:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
