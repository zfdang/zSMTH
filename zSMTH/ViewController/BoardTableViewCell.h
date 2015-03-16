//
//  BoardTableViewCell.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *boardCategory;
@property (weak, nonatomic) IBOutlet UILabel *boardName;
@property (weak, nonatomic) IBOutlet UILabel *boardManagers;
@property (weak, nonatomic) IBOutlet UIImageView *imageFolder;
@property (weak, nonatomic) IBOutlet UIImageView *imageBoard;

@end
