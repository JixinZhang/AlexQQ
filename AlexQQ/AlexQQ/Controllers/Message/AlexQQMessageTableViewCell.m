//
//  AlexQQMessageTableViewCell.m
//  AlexQQ
//
//  Created by ZhangBob on 4/5/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQMessageTableViewCell.h"

@implementation AlexQQMessageTableViewCell

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
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        [self.contentView addSubview:self.avatarImageView];
        
        self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 25)];
        [self.contentView addSubview:self.nicknameLabel];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, [[UIScreen mainScreen] bounds].size.width-60-50, 20)];
        self.messageLabel.font = [UIFont systemFontOfSize:18.0];
        self.messageLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}


@end
