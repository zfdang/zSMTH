//
//  PostListTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-20.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "PostListTableViewController.h"
#import "PostListTableViewCell.h"
#import "SMTHPost.h"
#import "SVPullToRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PostListTableViewController ()
{
    NSMutableArray *mPosts;
    int mPageIndex;
}

@end

@implementation PostListTableViewController

@synthesize boardID;
@synthesize boardName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"boardID = %@, boardName = %@", boardID, boardName);
    self.navItem.title = [NSString stringWithFormat:@"%@(%@)", boardName, boardID];
    
    mPosts = [[NSMutableArray alloc] init];
    self.progressTitle = @"加载中...";
    [self startAsyncTask];

    self.navigationController.navigationBar.translucent = NO;
    
    // add pull to refresh function at the top & bottom
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshPostList];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMorePostList];
    }];
}

- (void) refreshPostList {
    __weak typeof(self) weakSelf = self;
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView.pullToRefreshView stopAnimating];

        weakSelf.progressTitle = @"刷新中...";
        [weakSelf startAsyncTask];
    });
}


- (void) loadMorePostList {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        mPageIndex += 1;
        NSArray *posts = [helper getPostsFromBoard:boardID from:mPageIndex];
        long currentNumber = [mPosts count];
        if (posts != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [mPosts addObjectsFromArray:posts];
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                [weakSelf.tableView beginUpdates];
                for (int i = 0; i < [posts count]; i++) {
                    [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentNumber+i inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                }
                [weakSelf.tableView endUpdates];
            });
        }
    });
}


- (void)asyncTask
{
    // this function will only load first page
    mPageIndex = 0;
    NSArray *posts = [helper getPostsFromBoard:boardID from:0];
    [mPosts removeAllObjects];
    [mPosts addObjectsFromArray:posts];
}

- (void)finishAsyncTask
{
    [self.tableView reloadData];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    NSLog(@"boardID = %@, boardName = %@", boardID, boardName);
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [mPosts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PostListTableViewCell";
    
    PostListTableViewCell *cell = (PostListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (PostListTableViewCell*)[nibArray objectAtIndex:0];
    }
    
    if (indexPath.section == 0) {
        SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:indexPath.row];
        [cell.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        cell.imageAvatar.layer.cornerRadius = 10.0;
        cell.imageAvatar.layer.borderWidth = 0;
        cell.imageAvatar.clipsToBounds = YES;

        cell.labelSubject.text = post.postSubject;
        if([post isDing]){
            cell.backgroundColor = [UIColor lightGrayColor];
        }
        cell.labelUserID.text = post.author;
        cell.labelPostTime.text = post.postDate;
        cell.labelReplyTime.text = post.replyPostDate;
        cell.labelCount.text = post.postCount;
        
        if(![post hasAttachment]){
            [cell.imageAttachs setHidden:YES];
        }
    }
    
    return cell;
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

- (IBAction)newPost:(id)sender {
    NSLog(@"New Post");
}
@end
