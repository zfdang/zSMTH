//
//  PostListTableViewCell.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-20.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelSubject;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelPostTime;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyTime;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet UILabel *labelUserID;
@property (weak, nonatomic) IBOutlet UIImageView *imageAttachs;

@end
