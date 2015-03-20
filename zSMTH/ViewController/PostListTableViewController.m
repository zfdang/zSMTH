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

@interface PostListTableViewController ()
{
    NSMutableArray *mPosts;
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
    [self startAsyncTask];
}

- (void)asyncTask
{
    NSArray *posts = [helper getPostsFromBoard:boardID from:0];
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
        cell.labelSubject.text = post.postSubject;
        cell.labelUserID.text = post.author;
        cell.labelPostTime.text = post.postDate;
        cell.labelReplyTime.text = post.replyPostDate;
        cell.labelCount.text = post.postCount;
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
