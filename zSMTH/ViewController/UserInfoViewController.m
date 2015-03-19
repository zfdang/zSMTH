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

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // set userinfo
    if (helper.isLogined) {
        [self.imageAvatar sd_setImageWithURL:[helper.user getFaceURL]];
        self.imageAvatar.layer.cornerRadius = 30.0;
        self.imageAvatar.layer.borderWidth = 0;
        self.imageAvatar.clipsToBounds = YES;

        self.labelID.text = helper.user.userID;
        self.labelNick.text = helper.user.userNick;
        self.labelLevel.text = [helper.user getLifeLevel];
    }
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
    return 8;
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
        cell.rowLabel.text = @"标题";
        cell.rowValue.text = @"内容";
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

@end
