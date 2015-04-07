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
//#import "SIAlertView.h"
#import "RNGridMenu.h"

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
    self.tableView.allowsSelection = NO;
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
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        
        CGSize newSize = [label sizeThatFits:label.frame.size];
        CGRect newFrame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, newSize.height);
        label.frame = newFrame;

        // update height for header
        iHeaderHeight = newSize.height + 4;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, iHeaderHeight)];
        view.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:0.9f];
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

        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.6; //seconds
        [cell addGestureRecognizer:lpgr];
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

- (void) handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    // only when gesture was recognized, not when ended
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        // get affected cell
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        // get indexPath of cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        // now start our action on long press
        NSLog(@"Long click on post %ld, %ld", indexPath.section, indexPath.row);

        SMTHPost *post = (SMTHPost*)[mPosts objectAtIndex:indexPath.row];
        NSArray *items = @[
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"arrow"]
                                                           title:@"转发到版面"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"0", post.postID);
                                                          }],
                           
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"]
                                                           title:@"回信给作者"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"1", post.postID);
                                                          }],
                           
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"block"]
                                                           title:@"浏览器打开"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"2", post.postID);
                                                          }],
                           
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"]
                                                           title:@"转寄到信箱"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"3", post.postID);
                                                          }],
                           
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"reply"]
                                                           title:@"回复"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"4", post.postID);
                                                          }],

                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"]
                                                           title:@"复制帖子"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"5", post.postID);
                                                          }],

                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"search"]
                                                           title:@"转寄给他人"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"6", post.postID);
                                                          }],

                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"anonymous"]
                                                           title:@"查询作者"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"7", post.postID);
                                                          }],

                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"]
                                                           title:@"分享"
                                                          action:^{
                                                              NSLog(@"%@, %@", @"8", post.postID);
                                                          }],
                           ];
        RNGridMenu *av = [[RNGridMenu alloc] initWithItems:items];
        av.backgroundColor = [UIColor lightGrayColor];
        av.itemTextColor = [UIColor darkTextColor];
        av.itemTextAlignment = NSTextAlignmentCenter;
        av.blurLevel = 0.1;
        av.itemFont = [UIFont boldSystemFontOfSize:15];
        av.itemSize = CGSizeMake(100, 100);
        av.menuStyle = RNGridMenuStyleGrid;
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
        
// SIAlertView: be replaced by RNGridMenuItem
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:nil];
//        
//        [alertView addButtonWithTitle:@"回复"
//                                 type:SIAlertViewButtonTypeDestructive
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"Button1 Clicked");
//                              }];
//        [alertView addButtonWithTitle:@"私信回复"
//                                 type:SIAlertViewButtonTypeDefault
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"Button2 Clicked");
//                              }];
//        [alertView addButtonWithTitle:@"转寄"
//                                 type:SIAlertViewButtonTypeDefault
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"Button3 Clicked");
//                              }];
//        [alertView addButtonWithTitle:@"转发到版面"
//                                 type:SIAlertViewButtonTypeDefault
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"Button3 Clicked");
//                              }];
//        [alertView addButtonWithTitle:@"查看作者信息"
//                                 type:SIAlertViewButtonTypeDefault
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"Button3 Clicked");
//                              }];
//        [alertView addButtonWithTitle:@"取消"
//                                 type:SIAlertViewButtonTypeCancel
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"Button3 Clicked");
//                              }];
        
//        alertView.willShowHandler = ^(SIAlertView *alertView) {
//            NSLog(@"%@, willShowHandler", alertView);
//        };
//        alertView.didShowHandler = ^(SIAlertView *alertView) {
//            NSLog(@"%@, didShowHandler", alertView);
//        };
//        alertView.willDismissHandler = ^(SIAlertView *alertView) {
//            NSLog(@"%@, willDismissHandler", alertView);
//        };
//        alertView.didDismissHandler = ^(SIAlertView *alertView) {
//            NSLog(@"%@, didDismissHandler", alertView);
//        };
//        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
//        [alertView show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (IBAction)clickRightButton:(id)sender {
}
@end