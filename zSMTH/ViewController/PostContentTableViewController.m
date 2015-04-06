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
#import "UIView+Toast.h"

#define LABEL_WIDTH 300

@interface PostContentTableViewController ()
{
    NSMutableArray *mPosts;
    NSMutableDictionary *mHeights;
    int mPageIndex;
    CGFloat iHeaderHeight;
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
    iHeaderHeight  = 22.0;
    self.title = [helper getFullBoardName:self.boardName];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    self.progressTitle = @"加载中...";
    [self startAsyncTask];
    
    // add pull to refresh function at the top & bottom
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMorePostList];
    }];
    // change translucent, otherwise, tableview will be partially hidden
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void) loadMorePostList {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        mPageIndex += 1;
        NSArray *posts = [helper getPostContents:boardName postID:postID from:mPageIndex];
        long currentNumber = [mPosts count];
        if (posts != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([posts count] > 0) {
                    [weakSelf.tableView beginUpdates];
                    [mPosts addObjectsFromArray:posts];
                    for (int i = 0; i < [posts count]; i++) {
                        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentNumber+i inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                    }
                    [weakSelf.tableView endUpdates];
                    [weakSelf.tableView.infiniteScrollingView stopAnimating];
                    
                    // scroll to the new location
//                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentNumber-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

                } else {
                    [weakSelf.tableView.infiniteScrollingView stopAnimating];

                    [weakSelf.tableView.infiniteScrollingView  makeToast:@"没有更多的帖子了..."
                                duration:0.5
                                position:CSToastPositionCenter];
                }
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

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return iHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.frame.size.width - 10, 36)];
        label.numberOfLines = 2;
        label.text = self.postSubject;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        
        CGSize newSize = [label sizeThatFits:label.frame.size];
        CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, newSize.height);
        label.frame = newFrame;

        // update height for header
        iHeaderHeight = newSize.height + 4;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, iHeaderHeight)];
        view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
        [view addSubview:label];
        
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 70.0;
    
    id result = [mHeights objectForKey:indexPath];
    if(result != nil)
    {
        height = [((NSNumber*)result) floatValue];
    }
    
//    NSLog(@"%@ height=%f", indexPath, height);
    return height;
}

// http://tewha.net/2015/01/how-to-fix-uitableview-rows-changing-size/
// http://blog.jldagon.me/blog/2013/12/07/auto-layout-and-uitableview-cells/
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PostContentTableViewCell";
    
    PostContentTableViewCell *cell = (PostContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (PostContentTableViewCell*)[nibArray objectAtIndex:0];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (indexPath.section == 0) {
        SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:indexPath.row];
        
        post.postBoard = self.boardName;
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

#pragma mark - RefreshTableViewProtocol
- (void)RefreshTableView
{
//    [self.tableView setNeedsDisplay];
    [self.tableView reloadData];
}

@end