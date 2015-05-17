//
//  BoardListTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-4.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "BoardListTableViewController.h"
#import "BoardListTableViewCell.h"
#import "SMTHBoard.h"
#import "PostListTableViewController.h"

@interface BoardListTableViewController ()
{
    NSMutableArray *boards;
    NSMutableArray *origBoards;
    NSString *lastUpdateTime;
}
@end

@implementation BoardListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // CGFloat top, left , bottom, right ;
//    self.tableView.contentInset = UIEdgeInsetsMake(0, -6, 0, 0);
    
    // load favorite boards
    boards = [[NSMutableArray alloc] init];
    origBoards = [[NSMutableArray alloc] init];
    [self startAsyncTask:nil];
    
    lastUpdateTime = @"加载版面列表中...";
    
    self.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
}


- (void)asyncTask:(NSMutableDictionary*) params
{
    NSArray *results = [helper getAllBoards];
    lastUpdateTime = [NSString stringWithFormat:@"列表更新时间：%@", [helper getCacheUpdateTime:@"BOARD" RootID:0]];
    
    [origBoards removeAllObjects];
    [origBoards addObjectsFromArray:results];

    [boards removeAllObjects];
    [boards addObjectsFromArray:results];
}

- (void)finishAsyncTask:(NSDictionary*) resultParams
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0 && boards != nil)
        return [boards count];
    return 0;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if(section == 0){
//        if(updateDescription != nil)
//            return updateDescription;
//        else
//            return @"全部版面的最近更新时间未知!";
//    }
//    return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if(sectionIndex == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 24)];
        view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, tableView.frame.size.width, 20)];
        label.text = lastUpdateTime;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        
        CGSize newSize = [label sizeThatFits:label.frame.size];
        CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, newSize.height);
        label.frame = newFrame;
        [view addSubview:label];

        return view;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BoardListTableViewCell";
    
    BoardListTableViewCell *cell = (BoardListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (BoardListTableViewCell*)[nibArray objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        SMTHBoard* board = (SMTHBoard*)[boards objectAtIndex:indexPath.row];
        // Configure the cell...
        cell.boardName.text =  [NSString stringWithFormat:@"%@(%@)", board.engName, board.chsName];
        cell.boardManagers.text = board.managers;
        cell.boardCategory.text = board.category;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        SMTHBoard* board = (SMTHBoard*)[boards objectAtIndex:indexPath.row];
        PostListTableViewController *postlist = [self.storyboard instantiateViewControllerWithIdentifier:@"postlistController"];
        postlist.chsName = board.chsName;
        postlist.engName = board.engName;
        postlist.boardID = board.boardID;
        [self.navigationController pushViewController:postlist animated:YES];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    int length = [self getStringLengthForChinese:searchText];
//    NSLog(@"Search Text Changed: %@, %d", searchText, length);

    // 2个英文字母，或者一个中文，可以开始查找了
    if(length >= 2){
        [boards removeAllObjects];
        // 中文版名，英文版名，还有版面类型
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"engName contains[c] %@ || chsName contains[c] %@ || category contains[c] %@", searchText, searchText, searchText];
        boards = [NSMutableArray arrayWithArray:[origBoards filteredArrayUsingPredicate:resultPredicate]];
        [self.tableView reloadData];
    } else {
        // show all boards
        [boards removeAllObjects];
        [boards addObjectsFromArray:origBoards];
        [self.tableView reloadData];
    }
}

//判断中英混合的的字符串长度
- (int)getStringLengthForChinese:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)refreshBoardList:(id)sender {
    [helper clearCacheStatus:@"BOARD" RootID:0];

    self.progressTitle = @"刷新中...";
    [self startAsyncTask:nil];
}
@end
