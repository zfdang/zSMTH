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
#import "UIView+Toast.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostContentTableViewController.h"
#import "ContentEditViewController.h"

typedef enum {
    TASK_RELOAD = 0,
    TASK_ADD_FAVORITE,
    TASK_SEARCH,
} TASKTYPE;


@interface PostListTableViewController ()
{
    // array of all posts
    NSMutableArray *mPosts;
    // the current loaded page index
    int mPageIndex;
    // number of 置顶的帖子数
    int iNumberOfDing;
    // 如果是YES, 则跳过置顶的帖子
    BOOL showDingPosts;
    
    // 当前async task的类型
    TASKTYPE taskType;
    BOOL asyncTaskResult;

    // 搜索结果的当前页面
    int mFilterPageIndex;
    NSString* filterTitle;
    NSString* filterAuthor;
}

@end

@implementation PostListTableViewController

@synthesize engName;
@synthesize chsName;
@synthesize boardID;

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
    // 在viewwilldisappear里手动隐藏菜单
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
    
    // 开始异步加载帖子列表
    showDingPosts = NO;
    mPosts = [[NSMutableArray alloc] init];
    self.progressTitle = @"加载中...";
    taskType = TASK_RELOAD;
    [self startAsyncTask:nil];
    
}

- (void) refreshPostList {
    __weak typeof(self) weakSelf = self;
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView.pullToRefreshView stopAnimating];

        weakSelf.progressTitle = @"刷新中...";
        [weakSelf startAsyncTask:nil];
    });
}


- (void) loadMorePostList {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        weakSelf.tableView.showsPullToRefresh = NO;

        NSArray *posts;
        if(taskType == TASK_RELOAD){
            mPageIndex += 1;
            posts = [helper getPostsFromBoard:engName from:mPageIndex];
        } else if(taskType == TASK_SEARCH) {
            mFilterPageIndex += 1;
            posts = [helper getFilteredPostsFromBoard:engName title:filterTitle user:filterAuthor from:mFilterPageIndex];
        }
        
        long currentNumber = [mPosts count];
        if(! showDingPosts)
            currentNumber -= iNumberOfDing;
        if (posts != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([posts count] > 0){
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    for (int i = 0; i < [posts count]; i++) {
                        [array addObject:[NSIndexPath indexPathForRow:currentNumber+i inSection:0]];
                    }

                    [weakSelf.tableView beginUpdates];
                    [mPosts addObjectsFromArray:posts];
                    [weakSelf.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
                    [weakSelf.tableView endUpdates];

                    [weakSelf.tableView.infiniteScrollingView stopAnimating];
                } else {
                    [weakSelf.tableView.infiniteScrollingView  makeToast:@"没有更多的帖子了..."
                                                                duration:0.5
                                                                position:CSToastPositionCenter];
                    
                }

                weakSelf.tableView.showsPullToRefresh = YES;
            });
        }
    });
}

- (void)asyncTask:(NSMutableDictionary*) params
{
    self.tableView.showsPullToRefresh = NO;
    self.tableView.showsInfiniteScrolling = NO;
    
    // this function will only load first page
    NSArray* posts;
    if(taskType == TASK_RELOAD){
        mPageIndex = 0;
        posts = [helper getPostsFromBoard:engName from:mPageIndex];
        [mPosts removeAllObjects];
        [mPosts addObjectsFromArray:posts];
    } else if (taskType == TASK_SEARCH){
        mFilterPageIndex = 0;
        posts = [helper getFilteredPostsFromBoard:engName title:filterTitle user:filterAuthor from:mFilterPageIndex];
        [mPosts removeAllObjects];
        [mPosts addObjectsFromArray:posts];
    } else if(taskType == TASK_ADD_FAVORITE){
        asyncTaskResult = [helper addFavorite:self.engName];
    }
}

- (void)finishAsyncTask:(NSDictionary*) resultParams
{
    if(taskType == TASK_RELOAD || taskType == TASK_SEARCH){
        iNumberOfDing = [self getNumberOfDingPosts];
        [self.tableView reloadData];
    } else if(taskType == TASK_ADD_FAVORITE){
        UIAlertView *altview = [[UIAlertView alloc] initWithTitle:@"收藏成功"
                                                          message:[NSString stringWithFormat:@"收藏版面%@成功, 请刷新收藏夹!", self.engName]
                                                         delegate:nil
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
        [altview show];
        taskType = TASK_RELOAD;
    }

    self.tableView.showsPullToRefresh = YES;
    self.tableView.showsInfiniteScrolling = YES;
}

- (int) getNumberOfDingPosts
{
    int result = 0;
    for(int i = 0; i < [mPosts count]; i ++)
    {
        SMTHPost *post = [mPosts objectAtIndex:i];
        if(post.isDing){
            result += 1;
        } else {
            break;
        }
    }
    return result;
}

#pragma mark - Navigation Buttons

- (IBAction)clickLeftButton:(id)sender {
    if(taskType == TASK_SEARCH){
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.progressTitle = @"重新加载版面列表中...";
        taskType = TASK_RELOAD;
        [self startAsyncTask:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)newPost:(id)sender {
    ContentEditViewController *editor = [self.storyboard instantiateViewControllerWithIdentifier:@"contenteditController"];
    
    editor.engName = self.engName;
//    editor.origSubject = @"我发的一个帖子";
//    editor.origContent = @"梯子的内容是什么啊？";
//    editor.replyID = 1234;
    [self.navigationController pushViewController:editor animated:YES];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    NSLog(@"boardID = %@, boardName = %@", boardID, boardName);
//}

#pragma mark - UIView life cycle methods

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

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(mPosts == nil)
        return 0;

    if(showDingPosts){
        return [mPosts count];
    } else {
        // 刨去置顶的帖子数
        return [mPosts count] - iNumberOfDing;
    }
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
    }
    
    if (indexPath.section == 0) {
        long postIdx = indexPath.row;
        if(!showDingPosts){
            postIdx += iNumberOfDing;
        }
        SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:postIdx];
        
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
    long postIdx = indexPath.row;
    if(!showDingPosts){
        postIdx += iNumberOfDing;
    }
    SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:postIdx];
//    NSLog(@"Click on Post: Board = %@, Post = %@", post.postBoard, post.postID);
    
    PostContentTableViewController *postcontent = [self.storyboard instantiateViewControllerWithIdentifier:@"postcontentController"];
    
    [postcontent setBoardInfo:self.boardID chsName:self.chsName engName:self.engName];
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

-(void) popupSearchDialog
{
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"搜索帖子"
                                        message:nil preferredStyle:UIAlertControllerStyleAlert];

    //添加输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"主题关键字";
    }];//可以在block之中对textField进行相关的操作
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"用户名";
        textField.secureTextEntry = NO;//输入框密文显示格式
    }];
    
    //添加其他按钮
    /**
     *  UIAlertAction对象的 style的三种样式:
     // 默认的格式
     1.UIAlertActionStyleDefault
     // 取消操作. 该种格式只能由一个UIAlertAction的对象使用, 不能超过两个
     UIAlertActionStyleCancel
     //警告样式, 按钮颜色为红色, 提醒用户这样做可能会改变或者删除某些数据
     UIAlertActionStyleDestructive
     */
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                      style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                          //对应每个按钮处理事件操作
//                                                          NSLog(@"点击了取消");
                                                      }];//可以在对应的action的block中处理相应的事件, 无需使用代理方式
    UIAlertAction *actionSearch = [UIAlertAction actionWithTitle:@"搜索"
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                          //  开始真正的search工作
                                                          
                                                          UITextField *keyword = alertController.textFields[0];
                                                          filterTitle = keyword.text;
                                                          UITextField *author = alertController.textFields[1];
                                                          filterAuthor = author.text;
//                                                          NSLog(@"点击了搜索:%@, %@", filterTitle, filterAuthor);

                                                          // 禁止右侧的发帖按钮
                                                          self.navigationItem.rightBarButtonItem.enabled = NO;
                                                          
                                                          // 开始搜索
                                                          self.progressTitle = @"搜索中...";
                                                          taskType = TASK_SEARCH;
                                                          [self startAsyncTask:nil];
                                                      }];
    //添加action
    [alertController addAction:actionCancel];//为alertController添加action
    [alertController addAction:actionSearch];
    
    //方法
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) showInvalidAlert
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [self.tableView  makeToast:@"搜索模式下无法使用!"
                      duration:0.8
                      position:[NSValue valueWithCGPoint:CGPointMake(bounds.size.width * 0.5, self.tableView.contentOffset.y + bounds.size.height * 0.7)]];
    
}

#pragma mark - SINavigationMenuDelegate

-(void)didSelectItemAtIndex:(NSUInteger)index
{
    if(taskType != TASK_RELOAD){
        // 只有在正常列表下，菜单项才有效
        [self showInvalidAlert];
        return;
    }
    if(index == 1){
        // 切换置顶
        showDingPosts = !showDingPosts;
        [self.tableView reloadData];
    } else if (index == 0){
        [self popupSearchDialog];
    } else if(index == 2){
        // 添加收藏
        self.progressTitle = @"收藏版面中...";
        taskType = TASK_ADD_FAVORITE;
        [self startAsyncTask:nil];
    }
//    NSLog(@"%ld clicked in navigation menu", index);
}

@end
