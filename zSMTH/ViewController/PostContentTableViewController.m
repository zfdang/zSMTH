//
//  PostContentTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-22.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "PostContentTableViewController.h"
#import "SVPullToRefresh.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostContentTableViewCell.h"
#import "SMTHPost.h"

#define LABEL_WIDTH 300

@interface PostContentTableViewController ()
{
    NSMutableArray *mPosts;
    NSMutableDictionary *mHeights;
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

    self.progressTitle = @"加载中...";
    [self startAsyncTask];
}

- (void)asyncTask
{
    NSArray *results = [helper getPostContents:boardName postID:postID from:0];
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

    CGFloat height = 150.0;
    
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
       
        [cell.imageAvatar sd_setImageWithURL:[helper getFaceURLByUserID:[post author]] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        cell.imageAvatar.layer.cornerRadius = 10.0;
        cell.imageAvatar.layer.borderWidth = 0;
        cell.imageAvatar.clipsToBounds = YES;
        
        cell.postAuthor.text = post.author;
        cell.postTime.text = post.postDate;
        
        if(post.replyIndex == 0){
            cell.postIndex.text = @"楼主";
        } else {
            cell.postIndex.text = [NSString stringWithFormat:@"%ld楼",post.replyIndex];
        }
        
        // set content
        [cell.postContent setContentInfo:post.postContent];
        CGFloat pos = [cell.postContent get_height] + cell.postContent.frame.origin.y + 10;
        NSNumber *height = [NSNumber numberWithFloat:pos];
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
