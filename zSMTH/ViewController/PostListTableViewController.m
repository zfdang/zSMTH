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
#import "PostContentTableViewController.h"


@interface PostListTableViewController ()
{
    NSMutableArray *mPosts;
    int mPageIndex;
}

@end

@implementation PostListTableViewController

@synthesize engName;
@synthesize chsName;

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设定title的内容，和下拉菜单
    NSString* navTitle = nil;
    if(self.chsName){
        navTitle = [NSString stringWithFormat:@"%@(%@)", chsName, engName];
    } else {
        // 从导读-> 帖子 -> 回到版面时，版面没有中文名称
        navTitle = engName;
    }
    // add dropdown menu for navigation bar
    // 有一个bug, 当点击了navigation bar的其他按钮后，如果菜单处于弹出状态，居然也不消失
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        SINavigationMenuView *menu = [[SINavigationMenuView alloc] initWithFrame:frame title:navTitle];
        //Set in which view we will display a menu
        [menu displayMenuInView:self.navigationController.view];
        //Create array of items
        menu.items = @[@"搜索帖子", @"切换置顶显示",  @"收藏本版"];
        menu.delegate = self;
        self.navigationItem.titleView = menu;
    }

    // 开始异步加载帖子列表
    mPosts = [[NSMutableArray alloc] init];
    self.progressTitle = @"加载中...";
    [self startAsyncTask];

    // 开启上拉加载和和下拉刷新
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
        NSArray *posts = [helper getPostsFromBoard:engName from:mPageIndex];
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
    NSArray *posts = [helper getPostsFromBoard:engName from:0];
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

- (void)viewWillDisappear:(BOOL)animated
{
    SINavigationMenuView *menu = (SINavigationMenuView*) self.navigationItem.titleView;
    if (menu.menuButton.isActive) {
//        NSLog(@"dropdown menu is active, turn off it now");
        [menu onHideMenu];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [mPosts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:indexPath.row];
    NSLog(@"Click on Post: Board = %@, Post = %@", post.postBoard, post.postID);
    
    PostContentTableViewController *postcontent = [self.storyboard instantiateViewControllerWithIdentifier:@"postcontentController"];
    postcontent.engName = post.postBoard;
    postcontent.postID = [post.postID doubleValue];
    postcontent.postSubject = post.postSubject;    
    [self.navigationController pushViewController:postcontent animated:YES];
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

#pragma mark - SINavigationMenuDelegate

-(void)didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"%ld clicked in navigation menu", index);
}

@end
