//
//  MailTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-29.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "MailTableViewController.h"
#import "SVPullToRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Toast.h"
#import "PostListTableViewCell.h"
#import "SMTHPost.h"
#import "PostContentTableViewController.h"

typedef enum {
    TASK_MAIL_INBOX = 1,
    TASK_MAIL_OUTBOX,
    TASK_NOTIFICATION,
} TASKTYPE;

@interface MailTableViewController ()
{
    // array of all posts
    NSMutableArray *mPosts;
    // the current loaded page index
    int mPageIndex;
    
    // 当前async task的类型
    TASKTYPE taskType;
    BOOL asyncTaskResult;

    UIColor *readedColor;
    UIColor *unreadedColor;
    
    SINavigationMenuView *menu;
}

@end

@implementation MailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // 开启上拉加载和和下拉刷新
    // add pull to refresh function at the top & bottom
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadMoreMailList];
    }];
    
    // 防止tableview的顶部被navigation bar挡住
    self.navigationController.navigationBar.translucent = NO;

    // add dropdown menu for navigation bar
    // 有一个bug, 当点击了navigation bar的其他按钮后，如果菜单处于弹出状态，居然也不消失
    // 在viewwilldisappear里手动隐藏菜单
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        menu = [[SINavigationMenuView alloc] initWithFrame:frame title:@"邮箱"];
        //Set in which view we will display a menu
        [menu displayMenuInView:self.navigationController.view];
        //Create array of items
        menu.items = @[@"收件箱", @"发件箱"];
        menu.delegate = self;
        self.navigationItem.titleView = menu;
    }

    // initialize color
    unreadedColor = [UIColor colorWithRed:255/255.0 green:245/255.0 blue:238/255.0 alpha:1.0];
    readedColor = [UIColor whiteColor];

    // 开始异步加载帖子列表
    mPosts = [[NSMutableArray alloc] init];
    self.progressTitle = @"加载中...";
    taskType = TASK_MAIL_INBOX;
    self.tableView.showsInfiniteScrolling = NO;
    [self startAsyncTask:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.hidesBarsOnSwipe = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
//    SINavigationMenuView *menu = (SINavigationMenuView*) self.navigationItem.titleView;
    if (menu.menuButton.isActive) {
        //        NSLog(@"dropdown menu is active, turn off it now");
        [menu onHideMenu];
    }
    [super viewWillDisappear:animated];
}

-(void)loadMoreMailList
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        weakSelf.tableView.showsPullToRefresh = NO;
        
        NSArray *posts;
        mPageIndex += 1;
        posts = [helper getMailList:taskType from:mPageIndex];

        long currentNumber = [mPosts count];
        if (posts != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([posts count] > 0){
                    [self.tableView.infiniteScrollingView stopAnimating];

                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int i = 0; i < [posts count]; i++) {
                        [array addObject:[NSIndexPath indexPathForRow:currentNumber+i inSection:0]];
                    }
                    
                    [self.tableView beginUpdates];
                    [mPosts addObjectsFromArray:posts];
                    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
                    [self.tableView endUpdates];
                } else {
                    [self.tableView.infiniteScrollingView  makeToast:@"没有更多的邮件了..."
                                                                duration:0.5
                                                                position:CSToastPositionCenter];
                    [self.tableView.infiniteScrollingView stopAnimating];
                }
            });
        }
    });
    
}

-(void)asyncTask:(NSMutableDictionary *)params
{
    // this function will only load first page
    NSArray* posts;
    mPageIndex = 0;
    posts = [helper getMailList:taskType from:mPageIndex];
    [mPosts removeAllObjects];
    [mPosts addObjectsFromArray:posts];
}


-(void)finishAsyncTask:(NSDictionary *)resultParams
{
    [self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0){
        if(mPosts != nil){
            return [mPosts count];
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PostListTableViewCell";
    
    PostListTableViewCell *cell = (PostListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (PostListTableViewCell*)[nibArray objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // hide unnecessary item
        [cell.labelReply setHidden:YES];
        [cell.labelReplyTime setHidden:YES];
        [cell.labelReplyCount setHidden:YES];
        [cell.imageAttachs setHidden:YES];
    }
    
    if (indexPath.section == 0) {
        long postIdx = indexPath.row;
        SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:postIdx];
        
        [cell.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        cell.imageAvatar.layer.cornerRadius = 10.0;
        cell.imageAvatar.layer.borderWidth = 0;
        cell.imageAvatar.clipsToBounds = YES;
        
        cell.labelSubject.text = post.postSubject;
        cell.labelUserID.text = post.author;
        cell.labelPostTime.text = post.postDate;
        
        if([post isMailUnread]) {
            cell.backgroundColor = unreadedColor;
        } else {
            cell.backgroundColor = readedColor;
        }
        
        cell.labelCount.text = [NSString stringWithFormat:@"信件ID:%ld", post.postPosition];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long postIdx = indexPath.row;
    SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:postIdx];
    NSLog(@"Click on Mail: Author = %@, subject = %@", post.author, post.postSubject);

    // mark mail as read if it's unreaded
    if([post isMailUnread]) {
        [post markMailAsRead];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = readedColor;
    }

    // show mail content
    PostContentTableViewController *postcontent = [self.storyboard instantiateViewControllerWithIdentifier:@"postcontentController"];
    if(taskType == TASK_MAIL_INBOX) {
        [postcontent setMailInfo:CONTENT_INBOX position:post.postPosition subject:post.postSubject];
    } else if (taskType == TASK_MAIL_OUTBOX) {
        [postcontent setMailInfo:CONTENT_OUTBOX position:post.postPosition subject:post.postSubject];
    }
    [self.navigationController pushViewController:postcontent animated:YES];
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickRightButton:(id)sender {
    self.progressTitle = @"刷新中...";
//    taskType = TASK_MAIL_INBOX;
    self.tableView.showsInfiniteScrolling = NO;
    [self startAsyncTask:nil];
}

#pragma mark - SINavigationMenuDelegate

-(void)didSelectItemAtIndex:(NSUInteger)index
{
    if(index == 0){
        NSLog(@"切换到收件箱");
        self.progressTitle = @"加载中...";
        taskType = TASK_MAIL_INBOX;
        self.tableView.showsInfiniteScrolling = NO;
        [self startAsyncTask:nil];
    } else if (index == 1){
        NSLog(@"切换到发件箱");
        self.progressTitle = @"加载中...";
        taskType = TASK_MAIL_OUTBOX;
        self.tableView.showsInfiniteScrolling = NO;
        [self startAsyncTask:nil];
    }
}

@end
