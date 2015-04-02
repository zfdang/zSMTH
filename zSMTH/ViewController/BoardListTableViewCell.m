//
//  BoardTableViewCell.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-16.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "BoardListTableViewCell.h"

@implementation BoardListTableViewCell
@synthesize boardCategory;
@synthesize boardName;
@synthesize boardManagers;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
