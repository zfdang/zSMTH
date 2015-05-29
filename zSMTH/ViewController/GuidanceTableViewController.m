//
//  GuidanceViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "GuidanceTableViewController.h"
#import "GuidancePostTableViewCell.h"
#import "SMTHPost.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostContentTableViewController.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"

@interface GuidanceTableViewController ()
{
    NSMutableArray *m_sections;
}

@end

@implementation GuidanceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // change translucent, otherwise, tableview will be partially hidden
    self.navigationController.navigationBar.translucent = NO;

    // add pull to refresh function at the top & bottom
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshPostList];
    }];

    // load content now
    m_sections = [[NSMutableArray alloc] init];
    self.progressTitle = @"加载中...";
    self.tableView.showsPullToRefresh = NO;
    [self startAsyncTask:nil];

    // enable AppDelegate portrait + Landscape mode
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)asyncTask:(NSMutableDictionary*) params
{
    // 首先加载全站十大话题，然后在finishAsyncTask里加载剩余的分区话题
    NSArray *posts = [helper getGuidancePosts:0];
    [m_sections removeAllObjects];
    [m_sections addObject:posts];
}

- (void)finishAsyncTask:(NSDictionary*) resultParams
{
    // 显示全站十大话题
    [self.tableView reloadData];

    // 继续加载各分区的十大话题
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray* sectionList = [helper sectionList];
        for (int i = 1; i < [sectionList count]; i++) {
//            [NSThread sleepForTimeInterval:1.0f]; 
            NSLog(@"Loading guidance posts in section %@", [sectionList objectAtIndex:i]);
            NSArray *posts = [helper getGuidancePosts:i];

            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int j = 0; j < [posts count]; j++) {
                [array addObject:[NSIndexPath indexPathForRow:j inSection:i]];
            }
            // 开始更新tableview, 将新获取的分区十大显示出来
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView beginUpdates];
                [m_sections addObject:posts];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
            });
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.tableView.showsPullToRefresh = YES;
        });
    });
}

// http://stackoverflow.com/questions/21987067/using-weak-self-in-dispatch-async-function
- (void) refreshPostList {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView.pullToRefreshView stopAnimating];

        self.progressTitle = @"刷新中...";
        self.tableView.showsPullToRefresh = NO;
        [self startAsyncTask:nil];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [m_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(m_sections)
        return [[m_sections objectAtIndex:section ] count];
    else
        return 0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40.0;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerReuseIdentifier = @"TableViewSectionHeaderViewIdentifier";
    
    UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    if(sectionHeaderView == nil)
    {
        sectionHeaderView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerReuseIdentifier];
    }
    // 如果加载section内容失败，显示提示信息
    BOOL isSectionLoaded = NO;
    if([m_sections count] > section) {
        NSArray *posts = [m_sections objectAtIndex:section];
        if(posts && [posts count] > 0){
            isSectionLoaded = YES;
        }
    }
    if(isSectionLoaded){
        sectionHeaderView.textLabel.text = [helper.sectionList objectAtIndex:section];
    } else {
        sectionHeaderView.textLabel.text = [NSString stringWithFormat:@"%@(加载失败)",[helper.sectionList objectAtIndex:section]];
    }
    
    return sectionHeaderView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GuidancePostTableViewCell";
    
    GuidancePostTableViewCell *cell = (GuidancePostTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (GuidancePostTableViewCell*)[nibArray objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (m_sections !=nil) {
        NSArray *posts = [m_sections objectAtIndex:indexPath.section];
        SMTHPost* post = (SMTHPost*)[posts objectAtIndex:indexPath.row];
        
        [cell.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        cell.imageAvatar.layer.cornerRadius = 10.0;
        cell.imageAvatar.layer.borderWidth = 0;
        cell.imageAvatar.clipsToBounds = YES;

        cell.postBoard.text = [post postBoard];
        cell.postSubject.text = [post postSubject];
        cell.author.text = [post author];
        cell.postCount.text = [post postCount];
        // Configure the cell...
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *posts = [m_sections objectAtIndex:indexPath.section];
    SMTHPost* post = (SMTHPost*)[posts objectAtIndex:indexPath.row];
//    NSLog(@"Click on Post: Board = %@, Post = %@", post.postBoard, post.postID);

    PostContentTableViewController *postcontent = [self.storyboard instantiateViewControllerWithIdentifier:@"postcontentController"];
    // 首页导读页面，没有版面的ID和中文名，只有英文名
    [postcontent setBoardInfo:0 chsName:nil engName:post.postBoard];
    postcontent.postID = [post.postID doubleValue];
    postcontent.postSubject = post.postSubject;
    postcontent.isFromGuidance = YES;
    [self.navigationController pushViewController:postcontent animated:YES];
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

@end
