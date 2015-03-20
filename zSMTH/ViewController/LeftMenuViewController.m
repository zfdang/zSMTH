//
//  LeftMenuViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UIViewController+REFrostedViewController.h"
#import "LeftMenuViewController.h"
#import "NavigationViewController.h"
#import "REFrostedRootViewController.h"
#import "GuidanceViewController.h"
#import "LoginViewController.h"
#import "FavoriteTableViewController.h"
#import "UserInfoViewController.h"
#import "PostListTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface LeftMenuViewController ()
{
    NSArray *leftMenu;
    UIImageView *imageView;
    UILabel *labelUser;
}
@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init left menu
    leftMenu = @[@[@"节名", @"首页导读", @"个人收藏夹",  @"全部讨论区"],
                 @[@"我的水木", @"邮箱", @"短信息",@"文章提醒"]];
    
    // create table view
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        
        // user avatar
        // http://images.newsmth.net/nForum/uploadFace/M/mozilla.jpg
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"avatar"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 30.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 0;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        // user name
        labelUser = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        labelUser.text = @"点击登录";
        labelUser.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        labelUser.backgroundColor = [UIColor clearColor];
        labelUser.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [labelUser sizeToFit];
        labelUser.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        
        // enable single tap on imager
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarClicked)];
        singleTap.numberOfTapsRequired = 1;
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:singleTap];

        // enable single tap on user name
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userAvatarClicked)];
        singleTap1.numberOfTapsRequired = 1;
        [labelUser setUserInteractionEnabled:YES];
        [labelUser addGestureRecognizer:singleTap1];
        
        [view addSubview:imageView];
        [view addSubview:labelUser];
        view;
    });
}

-(void)userAvatarClicked{
//    NSLog(@"single Tap on user avatar or username");
    [self switchViewto:VIEW_USER_INFO];
}

-(void)switchViewto:(SMTHVIEW)target
{
    NavigationViewController *navigationController = (NavigationViewController*)self.frostedViewController.contentViewController;
    
    if (target == VIEW_GUIDANCE) {
        // top view is guidance view
        GuidanceViewController *guidance = [self.storyboard instantiateViewControllerWithIdentifier:@"guidanceController"];
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:guidance animated:YES];
    } else if (target == VIEW_FAVORITE) {
        FavoriteTableViewController *favorite = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteController"];
        [navigationController popToRootViewControllerAnimated:NO];

        // user logined?
        if(! helper.isLogined)
        {
            [navigationController pushViewController:favorite animated:NO];
            LoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
            login.delegate = favorite;
            [navigationController pushViewController:login animated:YES];
        } else {
            [navigationController pushViewController:favorite animated:YES];
        }

    } else if (target == VIEW_USER_INFO) {
        UserInfoViewController *userinfo = [self.storyboard instantiateViewControllerWithIdentifier:@"userinfoController"];
        [navigationController popToRootViewControllerAnimated:NO];

        // user logined?
        if(! helper.isLogined)
        {
            [navigationController pushViewController:userinfo animated:NO];
            LoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
            login.delegate = userinfo;
            [navigationController pushViewController:login animated:YES];
        } else {
            [navigationController pushViewController:userinfo animated:YES];
        }
    } else if (target == VIEW_POST_LIST) {
        PostListTableViewController *postlist = [self.storyboard instantiateViewControllerWithIdentifier:@"postlistController"];
        postlist.boardID = @"DigiHome";
        postlist.boardName = @"数字家庭";
        [navigationController popToRootViewControllerAnimated:NO];

        [navigationController pushViewController:postlist animated:YES];
    }
    
    [self.frostedViewController hideMenuViewController];
}

- (void)refreshTableHeadView
{
    if(helper.isLogined){
        NSComparisonResult result = [labelUser.text compare:helper.user.userID];
        if(result != NSOrderedSame){
            NSLog(@"Label=%@, userID=%@", labelUser.text, helper.user.userID);
            // update avatar & userID when necessary
            [imageView sd_setImageWithURL:[helper.user getFaceURL]];
            labelUser.text = helper.user.userID;
        }
    }
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    NSString *sectionLabel = [[leftMenu objectAtIndex:sectionIndex] objectAtIndex:0];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = sectionLabel;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // switch view
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self switchViewto:VIEW_GUIDANCE];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self switchViewto:VIEW_FAVORITE];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [self switchViewto:VIEW_POST_LIST];
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [leftMenu count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSArray *sections = [leftMenu objectAtIndex:sectionIndex];
    return [sections count] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

//    NSLog(@"%@", indexPath);

    NSArray *sections = [leftMenu objectAtIndex:indexPath.section];
    NSString *menuString = [sections objectAtIndex:(indexPath.row  + 1)];
    cell.textLabel.text = menuString;
    
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

@end
