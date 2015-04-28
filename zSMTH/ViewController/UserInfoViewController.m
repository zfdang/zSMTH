//
//  UserInfoViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-17.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "UserInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoTableViewCell.h"
#import "LoginViewController.h"


@interface UserInfoViewController ()
{
    int taskType;
    SMTHUser *user;
    NSString* userID;
}

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // set userinfo
    if (helper.isLogined) {
        [self.imageAvatar sd_setImageWithURL:[helper.user getFaceURL] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        self.imageAvatar.layer.cornerRadius = 30.0;
        self.imageAvatar.layer.borderWidth = 0;
        self.imageAvatar.clipsToBounds = YES;
        
        self.labelID.text = helper.user.userID;
        self.labelNick.text = helper.user.userNick;
        self.labelLevel.text = [helper.user getLifeLevel];
    }
    
    taskType = 0;
    self.progressTitle = @"加载信息中...";
    userID = helper.user.userID;
    [self startAsyncTask];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRightButton:(id)sender {
    if([user.userID compare:helper.user.userID] == NSOrderedSame) {
        // 显示的是当前用户的信息，按钮的作用是退出
        taskType = 1;
        self.progressTitle = @"退出中...";
        [self startAsyncTask];
    } else {
        // 显示的是查询用户的信息，按钮的作用是返回到当前用户信息页
        taskType = 0;
        self.progressTitle = @"加载信息中...";
        userID = helper.user.userID;
        [self startAsyncTask];
    }
}

- (IBAction)doSearch:(id)sender {
    taskType = 0;
    self.progressTitle = @"查询用户中...";
    userID = self.editUserID.text;
    [self startAsyncTask];
}

#pragma mark - ExpandedTableView -- async task

- (void)asyncTask
{
    // now different async task is distinguished by taskType, which is unsafe
    // it's better to add parameter to startAsyncTask->asyncTask->finishAsyncTask
    if(taskType == 0){
        user = [helper getUserInfo:userID];
    } else if(taskType == 1)
    {
        [helper logout];
    }
}

- (void)finishAsyncTask
{
    if(taskType == 1 && !helper.isLogined) {
        // 当上一个任务是退出，并且用户已经退出时，显示登录窗口
        LoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    
    // update top information
    [self.imageAvatar sd_setImageWithURL:[user getFaceURL] placeholderImage:[UIImage imageNamed:@"anonymous"]];
    self.imageAvatar.layer.cornerRadius = 30.0;
    self.imageAvatar.layer.borderWidth = 0;
    self.imageAvatar.clipsToBounds = YES;
    
    self.labelID.text = user.userID;
    self.labelNick.text = user.userNick;
    self.labelLevel.text = [user getLifeLevel];
    
    // update tableview infors
    [self.tableView reloadData];
    
    // update icon of right button
    if([user.userID compare:helper.user.userID] == NSOrderedSame){
        // 显示的是登录用户的信息，显示退出按钮
        [self.buttonRight setImage:[UIImage imageNamed:@"logout"]];
    } else {
        [self.buttonRight setImage:[UIImage imageNamed:@"return"]];
    }
}


#pragma mark - UITableViewDelegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserInfoTableViewCell";
    
    UserInfoTableViewCell *cell = (UserInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = (UserInfoTableViewCell*)[nibArray objectAtIndex:0];
    }
    
    if (indexPath.section == 0) {
        if(user == nil){
            cell.rowLabel.text = @"属性";
            cell.rowValue.text = @"值";
        } else {
            if(indexPath.row == 0){
                cell.rowLabel.text = @"性别";
                cell.rowValue.text = user.userGender;
            } else if (indexPath.row == 1){
                cell.rowLabel.text = @"年龄";
                cell.rowValue.text = user.userAge;
            } else if (indexPath.row == 2){
                cell.rowLabel.text = @"论坛身份";
                cell.rowValue.text = user.userTitle;
            } else if (indexPath.row == 3){
                cell.rowLabel.text = @"";
                cell.rowValue.text = @"";
            } else if (indexPath.row == 4){
                cell.rowLabel.text = @"注册时间";
                cell.rowValue.text = user.firstLogin;
            } else if (indexPath.row == 5){
                cell.rowLabel.text = @"上次登录";
                cell.rowValue.text = user.lastLogin;
            } else if (indexPath.row == 6){
                cell.rowLabel.text = @"登陆次数";
                cell.rowValue.text = user.totalLogins;
            } else if (indexPath.row == 7){
                cell.rowLabel.text = @"帖子总数";
                cell.rowValue.text = user.totalPosts;
            } else if (indexPath.row == 8){
                cell.rowLabel.text = @"积分";
                cell.rowValue.text = user.userScore;
            }
        }
    }
    
    return cell;
}

// remove leading space of separator in tableview
// http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working/25788003#25788003
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
