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


@interface FavoriteTableViewController ()
{
    NSArray *favorites;
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
    [self startAsyncTask];
    
    if(favoriteRootName && favoriteRootID != 0){
        self.title = [NSString stringWithFormat:@"收藏夹 | %@", favoriteRootName];
        self.leftButton.image =  [UIImage imageNamed:@"return"];
    }
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

- (void)asyncTask
{
    if(helper.isLogined)
        favorites = [helper getFavorites:favoriteRootID];
}

- (void)finishAsyncTask
{
    if(helper.isLogined)
        [self.tableView reloadData];
}

#pragma mark - Table view data source

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
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BoardListTableViewCell";
    
    BoardListTableViewCell *cell = (BoardListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (BoardListTableViewCell*)[nibArray objectAtIndex:0];
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
            [cell.imageFolder setHidden:false];
        }
    }
    
    return cell;
}

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
            postlist.boardName = board.chsName;
            postlist.boardID = board.engName;
            [self.navigationController pushViewController:postlist animated:YES];
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


#pragma mark - LoginCompletionProtocol

- (void)refreshViewAfterLogin
{
    [self startAsyncTask];
}

@end
