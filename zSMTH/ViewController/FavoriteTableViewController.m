//
//  FavoriteTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "FavoriteTableViewController.h"
#import "REFrostedViewController.h"
#import "SMTHBoard.h"
#import "BoardListTableViewCell.h"
#import "PostListTableViewController.h"
#import "SVPullToRefresh.h"

typedef enum {
    TASK_RELOAD = 0,
    TASK_DELETE,
} TASKTYPE;


@interface FavoriteTableViewController ()
{
    NSMutableArray *favorites;
    NSString *toBeDeletedFavoriteBoardEngName;
    NSIndexPath *toBeDeletedIndex;

    TASKTYPE taskType;
    BOOL taskResult;
}

@end

@implementation FavoriteTableViewController

@synthesize favoriteRootID;
@synthesize favoriteRootName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // load favorite boards
    favorites = nil;
    taskType = TASK_RELOAD;
    [self startAsyncTask:nil];
    
    if(favoriteRootName && favoriteRootID != 0){
        self.title = [NSString stringWithFormat:@"收藏夹 | %@", favoriteRootName];
        self.leftButton.image =  [UIImage imageNamed:@"return"];
    }
    
    // 开启上拉加载和和下拉刷新
    self.navigationController.navigationBar.translucent = NO;
    // add pull to refresh function at the top & bottom
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshFavorite];
    }];
}


- (IBAction)showLeftMenu:(id)sender {
    
    if(favoriteRootID == 0){
        [super showLeftMenu:self];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Favorite List Loading

- (void) refreshFavorite {
    // clear cache
    [helper clearCacheStatus:@"FAVORITE" RootID:self.favoriteRootID];

    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView.pullToRefreshView stopAnimating];
        
        self.progressTitle = @"刷新中...";
        taskType = TASK_RELOAD;
        [self startAsyncTask:nil];
    });
}

- (void)asyncTask:(NSMutableDictionary*) params
{
    if(taskType == TASK_RELOAD){
        favorites = [NSMutableArray arrayWithArray:[helper getFavorites:favoriteRootID]];
    } else if (taskType == TASK_DELETE){
        taskResult = [helper removeFavorite:toBeDeletedFavoriteBoardEngName];
    }
}

- (void)finishAsyncTask:(NSDictionary*) resultParams
{
    if(taskType == TASK_RELOAD){
        [self.tableView reloadData];
    } else if (taskType == TASK_DELETE){
        // invalid cache for this favorite folder
        [helper clearCacheStatus:@"FAVORITE" RootID:self.favoriteRootID];
        
        if(taskResult){
            // delete selected board from array and server
            [favorites removeObjectAtIndex:toBeDeletedIndex.row];
            
            // delete selected board from tableview
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:toBeDeletedIndex] withRowAnimation:UITableViewRowAnimationLeft];
            
            UIAlertView *altview = [[UIAlertView alloc] initWithTitle:@"删除成功"
                                                              message:[NSString stringWithFormat:@"删除版面%@成功",toBeDeletedFavoriteBoardEngName]
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil];
            [altview show];
        } else {
            UIAlertView *altview = [[UIAlertView alloc] initWithTitle:@"删除失败"
                                                              message:[NSString stringWithFormat:@"删除版面%@失败",toBeDeletedFavoriteBoardEngName]
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil];
            [altview show];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0)
    {
        if (favorites)
            return [favorites count];
        else
            return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BoardListTableViewCell";
    
    BoardListTableViewCell *cell = (BoardListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (BoardListTableViewCell*)[nibArray objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        SMTHBoard* board = (SMTHBoard*)[favorites objectAtIndex:indexPath.row];
        // Configure the cell...
        cell.boardName.text = board.chsName;
        cell.boardCategory.text = board.engName;
//        cell.boardManagers.text = [board.managers truncateToWidth:150 withFont:[UIFont systemFontOfSize:12.0]];
        cell.boardManagers.text = board.managers;
        
        if(board.type == GROUP){
            cell.boardCategory.text = @"[目录]";
            [cell.imageFolder setHidden:NO];
        } else {
            [cell.imageFolder setHidden:YES];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        SMTHBoard* board = (SMTHBoard*)[favorites objectAtIndex:indexPath.row];
        if(board.type == GROUP){
            UINavigationController *navigationController = self.navigationController;
            FavoriteTableViewController *favorite = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteController"];
            favorite.favoriteRootID = board.boardID;
            favorite.favoriteRootName = board.chsName;
            
            [navigationController pushViewController:favorite animated:YES];
        } else
        {
            PostListTableViewController *postlist = [self.storyboard instantiateViewControllerWithIdentifier:@"postlistController"];
            postlist.engName = board.engName;
            postlist.chsName = board.chsName;
            postlist.boardID = board.boardID;
            [self.navigationController pushViewController:postlist animated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 从收藏夹中删除版面
    if(indexPath.section == 0){
        SMTHBoard* board = (SMTHBoard*)[favorites objectAtIndex:indexPath.row];
        if(board.type == GROUP){
            // alert it's a group
            UIAlertView *altview = [[UIAlertView alloc] initWithTitle:@"不支持文件夹删除"
                                                              message:[NSString stringWithFormat:@"删除%@失败，请登录Web进行操作!",board.chsName]
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil];
            [altview show];
        } else {
            // delete board from server
            self.progressTitle = @"从服务器删除中...";
            taskType = TASK_DELETE;
            toBeDeletedFavoriteBoardEngName = [board.engName copy];
            toBeDeletedIndex = [indexPath copy];
            [self startAsyncTask:nil];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIViewController* view = segue.destinationViewController;
//    if ([view respondsToSelector:@selector(setBoardID:)]) {
//        [view setValue:nil forKey:@"boardID"];
//    }
}


@end
