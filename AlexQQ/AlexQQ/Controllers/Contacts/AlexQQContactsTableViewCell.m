//
//  AlexQQContactsTableViewCell.m
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQContactsTableViewCell.h"

@implementation AlexQQContactsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        [self.contentView addSubview:self.avatarImage];
        
        self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 25)];
        [self.contentView addSubview:self.nicknameLabel];
        
        self.followStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, 35, 5)];
        self.followStatusLabel.font = [UIFont systemFontOfSize:10.0];
        [self.contentView addSubview:self.followStatusLabel];
        
        self.introLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, [[UIScreen mainScreen] bounds].size.width-90-20, 5)];
        self.introLabel.font = [UIFont systemFontOfSize:10.0];
        [self.contentView addSubview:self.introLabel];
        
        self.networkImage = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 20, 5, 15, 10)];
        [self.contentView addSubview:self.networkImage];
    }
    
    return self;
}

@end
