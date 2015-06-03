//
//  LeftMenuViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-14.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UIViewController+REFrostedViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Toast.h"
#import "LeftMenuViewController.h"
#import "NavigationViewController.h"
#import "REFrostedRootViewController.h"
#import "GuidanceTableViewController.h"
#import "LoginViewController.h"
#import "FavoriteTableViewController.h"
#import "UserInfoViewController.h"
#import "PostListTableViewController.h"
#import "BoardListTableViewController.h"
#import "SettingViewController.h"
#import "MailTableViewController.h"
#import "AboutViewController.h"
#import "JDStatusBarNotification.h"
#import "SMTHHelper.h"
#import "PostContentTableViewController.h"

@interface LeftMenuViewController ()
{
    NSArray *leftMenu;
    UIImageView *imageView;
    UILabel *labelUser;
    SMTHHelper *helper;
    
    GuidanceTableViewController *guidance;
    FavoriteTableViewController *favorite;
    UserInfoViewController *userinfo;
    LoginViewController *login;
    BoardListTableViewController *boardlist;
    SettingViewController *setting;
    MailTableViewController *mail;
    AboutViewController *about;
}
@end

@implementation LeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    helper = [SMTHHelper sharedManager];

    // init left menu
    leftMenu = @[@[@"节名", @"首页导读", @"个人收藏夹",  @"全部讨论区"],
//                 @[@"我的水木", @"邮箱", @"文章提醒", @"设置", @"关于"]];
                  @[@"我的水木", @"邮箱", @"设置", @"关于", @"测试"]];
    
    // create table view
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({

        // 我们使用修改过menuView的大小，宽度为180
        // 头像区域为一个180 * 180的正方形
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 180.0f)];

        // user avatar
        // http://images.newsmth.net/nForum/uploadFace/M/mozilla.jpg
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"avatar"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 30.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 0;
//        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        // user name
        labelUser = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 180, 24)];
        labelUser.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        labelUser.textAlignment = NSTextAlignmentCenter;
        labelUser.text = @"点击登录";
        labelUser.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        labelUser.backgroundColor = [UIColor clearColor];
        labelUser.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"Update left menu before show");
    if(helper.user) {
        // update avatar & userID when necessary
        NSComparisonResult result = [labelUser.text compare:helper.user.userID];
        if(result != NSOrderedSame){
            [imageView sd_setImageWithURL:[helper.user getFaceURL]
                         placeholderImage:[UIImage imageNamed:@"anonymous"]
                                  options:SDWebImageRefreshCached];
            labelUser.text = helper.user.userID;
        }
    } else {
        imageView.image = [UIImage imageNamed:@"avatar"];
        labelUser.text = @"点击登录";
    }
}

-(void)userAvatarClicked {
//    NSLog(@"single Tap on user avatar or username");
    [self switchViewto:VIEW_USER_INFO];
}

-(void)switchViewto:(SMTHVIEW)target
{
    // 如果用户未登录，或者登录状态已超时，则显示登录界面
    if(! helper.user)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    NavigationViewController *navigationController = (NavigationViewController*)self.frostedViewController.contentViewController;
    if (target == VIEW_GUIDANCE) {
        // top view is guidance view
        if( guidance == nil){
            guidance = [self.storyboard instantiateViewControllerWithIdentifier:@"guidanceController"];
        }
        [navigationController popToRootViewControllerAnimated:YES];
    } else if (target == VIEW_FAVORITE) {
        if( favorite == nil){
            favorite = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteController"];
        }
        favorite.favoriteRootID = 0;
        favorite.favoriteRootName = @"个人收藏夹";
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:favorite animated:YES];
    } else if (target == VIEW_USER_INFO) {
        if(userinfo == nil){
            userinfo = [self.storyboard instantiateViewControllerWithIdentifier:@"userinfoController"];
        }
        [userinfo setQueryTask:0 userID:nil];
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:userinfo animated:YES];
    } else if (target == VIEW_BOARD_LIST) {
        if(boardlist == nil){
            boardlist = [self.storyboard instantiateViewControllerWithIdentifier:@"boardlistController"];
        }
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:boardlist animated:YES];
    } else if(target == VIEW_MAIL) {
        if( mail == nil) {
            mail = [self.storyboard instantiateViewControllerWithIdentifier:@"mailController"];
        }
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:mail animated:YES];
    } else if(target == VIEW_NOTIFICATION) {
        [JDStatusBarNotification showWithStatus:@"暂未实现\"文章提醒\"!"
                                   dismissAfter:1.0
                                      styleName:JDStatusBarStyleWarning];
    } else if(target == VIEW_SETTING) {
        if(setting == nil){
            setting = [self.storyboard instantiateViewControllerWithIdentifier:@"settingController"];
        }
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:setting animated:YES];
    } else if(target == VIEW_ABOUT) {
        if(about == nil){
            about = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutController"];
        }
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:about animated:YES];
    } else if(target == VIEW_TEST) {

        PostContentTableViewController *postcontent = [self.storyboard instantiateViewControllerWithIdentifier:@"postcontentController"];
        // 首页导读页面，没有版面的ID和中文名，只有英文名
        [postcontent setBoardInfo:0 chsName:nil engName:@"Test"];
        postcontent.postID = 907144;
        postcontent.postSubject = @"[Test]版主别删，是用来测试客户端的显示效果的";
        postcontent.isFromGuidance = YES;

        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:postcontent animated:YES];
    }

    [self.frostedViewController hideMenuViewController];
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
        [self switchViewto:VIEW_BOARD_LIST];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self switchViewto:VIEW_MAIL];
    } else if (indexPath.section == 1 && indexPath.row == 1){
        [self switchViewto:VIEW_SETTING];
    } else if (indexPath.section == 1 && indexPath.row == 2){
        [self switchViewto:VIEW_ABOUT];
    } else if (indexPath.section == 1 && indexPath.row == 3){
        [self switchViewto:VIEW_TEST];
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
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
