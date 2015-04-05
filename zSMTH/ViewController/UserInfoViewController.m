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
    self.progressTitle = @"加载中...";
    userID = helper.user.userID;
    [self startAsyncTask];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - LoginCompletionProtocol

- (void)refreshViewAfterLogin
{
    // refresh UserInformation
    if (helper.isLogined) {
        [self.imageAvatar sd_setImageWithURL:[helper.user getFaceURL] placeholderImage:[UIImage imageNamed:@"anonymous"]];
        self.imageAvatar.layer.cornerRadius = 30.0;
        self.imageAvatar.layer.borderWidth = 0;
        self.imageAvatar.clipsToBounds = YES;
        
        self.labelID.text = helper.user.userID;
        self.labelNick.text = helper.user.userNick;
        self.labelLevel.text = [helper.user getLifeLevel];
        
        [self.tableView reloadData];
    }
    
}

- (IBAction)logout:(id)sender {
    taskType = 1;
    [self startAsyncTask];
}

- (IBAction)doSearch:(id)sender {
    taskType = 0;
    userID = self.editUserID.text;
    [self startAsyncTask];
}

- (void)asyncTask
{
    // now different async task is distinguished by taskType, which is unsafe
    // it's better to add parameter to startAsyncTask->asyncTask->finishAsyncTask
    if(taskType == 0){
        user = [helper getUserInfo:userID];
    } else if(taskType == 1)
    {
        self.progressTitle = @"退出中...";
        [helper logout];
    }
}

- (void)finishAsyncTask
{
    if(!helper.isLogined){
        LoginViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
        login.delegate = self;
        [self.navigationController pushViewController:login animated:YES];
    }

    // update top information
    [self.imageAvatar sd_setImageWithURL:[user getFaceURL]];
    self.imageAvatar.layer.cornerRadius = 30.0;
    self.imageAvatar.layer.borderWidth = 0;
    self.imageAvatar.clipsToBounds = YES;
    
    self.labelID.text = user.userID;
    self.labelNick.text = user.userNick;
    self.labelLevel.text = [user getLifeLevel];
    
    // update tableview infors
    [self.tableView reloadData];
}
@end
