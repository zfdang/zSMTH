//
//  PostContentTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-22.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "PostContentTableViewController.h"
#import "SVPullToRefresh.h"
#import "PostContentTableViewCell.h"
#import "SMTHPost.h"

#define LABEL_WIDTH 300

@interface PostContentTableViewController ()
{
    NSMutableArray *mPosts;
    NSMutableDictionary *mHeights;
    int mPageIndex;
}

@end

@implementation PostContentTableViewController

@synthesize postID;
@synthesize boardName;
@synthesize postSubject;

- (void)viewDidLoad {
    [super viewDidLoad];

    // load first page
    mPosts = [[NSMutableArray alloc] init];
    mHeights = [[NSMutableDictionary alloc] init];
    self.title = self.postSubject;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.progressTitle = @"加载中...";
    [self startAsyncTask];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // add pull to refresh function at the top & bottom
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMorePostList];
    }];

    
}

- (void) loadMorePostList {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        mPageIndex += 1;
        NSArray *posts = [helper getPostContents:boardName postID:postID from:mPageIndex];
        long currentNumber = [mPosts count];
        if (posts != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView.infiniteScrollingView stopAnimating];
                [mPosts addObjectsFromArray:posts];
                [weakSelf.tableView beginUpdates];
                for (int i = 0; i < [posts count]; i++) {
                    [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentNumber+i inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                }
                [weakSelf.tableView endUpdates];
//                [weakSelf.tableView reloadData];
            });
        }
    });
}


- (void)asyncTask
{
    mPageIndex = 0;
    NSArray *results = [helper getPostContents:boardName postID:postID from:mPageIndex];
    [mPosts removeAllObjects];
    [mPosts addObjectsFromArray:results];
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

    CGFloat height = 0.0;
    
    id result = [mHeights objectForKey:indexPath];
    if(result != nil)
    {
        height = [((NSNumber*)result) floatValue];
    }
    return height;
}

- (NSString*) getIndexPathDesc:(NSIndexPath*) indexPath
{
    NSString *result = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, indexPath.row];
    return result;
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
        
        [cell setCellContent:post];
       
        NSNumber *height = [NSNumber numberWithFloat:[cell getCellHeight]];
        [mHeights setObject:height forKey:indexPath];
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
