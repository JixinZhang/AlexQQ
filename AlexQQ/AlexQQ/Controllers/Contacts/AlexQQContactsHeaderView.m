//
//  AlexQQContactsHeaderView.m
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQContactsHeaderView.h"


#define screenWidth self.frame.size.width
#define buttonWidth 74
#define buttonHeight 74

@implementation AlexQQContactsHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self searchBarView];
        [self fourButtonView];
    }
    return self;
}

- (void)searchBarView
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.placeholder = @"搜索";
    [self addSubview:searchBar];
    self.searchBar = searchBar;
}

- (void)fourButtonView
{
    CGFloat intervalOfButton = (screenWidth - buttonWidth * 4)/3.0;
    UIView *fourButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, screenWidth, 74)];
    
    UIButton *addFriendButton = [self makeButtonWithImage:[UIImage imageNamed:@"contacts_new_friend.png"] title:@"新朋友"];
    addFriendButton.frame = CGRectMake(0, 0, buttonWidth,buttonHeight);
    [fourButtonView addSubview:addFriendButton];
    self.addFriendButton = addFriendButton;
    
    UIButton *caresButton = [self makeButtonWithImage:[UIImage imageNamed:@"contacts_cares.png"] title:@"特别关心"];
    caresButton.frame = CGRectMake(buttonWidth + intervalOfButton, 0, buttonWidth, buttonHeight);
    [fourButtonView addSubview:caresButton];
    self.caresButton = caresButton;
    
    UIButton *groupButton = [self makeButtonWithImage:[UIImage imageNamed:@"contacts_group.png"] title:@"群组"];
    groupButton.frame = CGRectMake((buttonWidth * 2 + intervalOfButton *2), 0, buttonWidth, buttonHeight);
    [fourButtonView addSubview:groupButton];
    self.groupButton = groupButton;
    
    UIButton *publicNumberButton = [self makeButtonWithImage:[UIImage imageNamed:@"contacts_public_number.png"] title:@"公众号"];
    publicNumberButton.frame = CGRectMake(screenWidth - buttonWidth, 0, buttonWidth, buttonHeight);
    [fourButtonView addSubview:publicNumberButton];
    self.publicNumberButton = publicNumberButton;
    
    
    [self addSubview:fourButtonView];
}

-(UIButton*)makeButtonWithImage:(UIImage *)image title:(NSString*) title{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:image forState:(UIControlStateNormal)];
    button.adjustsImageWhenHighlighted = NO;
    [button setTitle:title forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -40, -45, -8);
    button.imageEdgeInsets = UIEdgeInsetsMake(-18, 15, 5, 0);
    return button;
}

@end
