//
//  AlexQQMessageViewController.m
//  AlexQQ
//
//  Created by ZhangBob on 4/3/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQMessageViewController.h"
#import "AlexQQMessageTableViewCell.h"
#import "MJRefresh.h"
#import "AlexQQDataPersistence.h"
#import <SDWebImage/UIImageView+WebCache.h>


#define screenWidth self.view.frame.size.width
#define screenHeight self.view.frame.size.height

@interface AlexQQMessageViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,AlexQQContactsRequestDelegate>
{
    UITableView *messageTableView;          //信息TableView
    UIView *telephoneView;                  //电话View
    UISearchBar *mySearchBar;               //搜索栏
    NSMutableArray *messageDataArray;       //存放需要显示的消息数据
    NSMutableArray *arrayOfAllMessageData;  //存放加载的所有消息数据
    int indexOfLoadedData;                  //用于指示从messageDataArray加载了arrayOfAllMessageData的第 indexOfLoadedData条数据
    AlexQQDataPersistence *dataPersistence; //数据持久化类
    UILabel *remindNumberLabel;             //未读消息数量提醒Label
}

@end

@implementation AlexQQMessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    messageDataArray = [[NSMutableArray alloc] init];
    arrayOfAllMessageData = [[NSMutableArray alloc] init];
    [self loadAllMessage];
    
    [self installNavigationBar];
    [self installMessageTableView];
    [self.view addSubview:messageTableView];
    
    //进入之后立即刷新一次
    [messageTableView.mj_header beginRefreshing];
    
    
    //注册通知，当remindNumberLabel被“一键退朝”后，将tabBarItem的badgeValue置空
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetMessageTabbarItemBadgeValue)
                                                 name:@"noNewMessage"
                                               object:nil];
    
    //用于模拟每10s接收到消息
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(receiveMessage) userInfo:nil repeats:true];
    //将用于一键退朝的view添加到tableview上
    self.azMetaBallView = [[AZMetaBallCanvas alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.azMetaBallView.backgroundColor = [UIColor clearColor];
    [messageTableView addSubview:self.azMetaBallView];
    
}

#pragma mark - receiveMessage and remind
- (void)receiveMessage
{
    [remindNumberLabel removeFromSuperview];
    remindNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-30, 64, 16, 16)];
    remindNumberLabel.backgroundColor = [UIColor redColor];
    remindNumberLabel.font = [UIFont systemFontOfSize:14];
    remindNumberLabel.textAlignment = UITextAlignmentCenter;
    remindNumberLabel.textColor = [UIColor whiteColor];
    remindNumberLabel.layer.cornerRadius = 8;
    remindNumberLabel.clipsToBounds = YES;
    
    int remindNumber = arc4random()%10+1;
    remindNumberLabel.text = [NSString stringWithFormat:@"%u",remindNumber];
    [self.azMetaBallView attach:remindNumberLabel];
    [self.azMetaBallView addSubview:remindNumberLabel];
    self.messageTabBarItem.badgeValue = [NSString stringWithFormat:@"%u",remindNumber];
    [messageTableView reloadData];

}

- (void)resetMessageTabbarItemBadgeValue
{
    self.messageTabBarItem.badgeValue = nil;
    [remindNumberLabel removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - NavigationBar
- (void)installNavigationBar
{
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen] bounds].size.width, 44)];
    navigationBar.backgroundColor = [UIColor clearColor];
    //title
    UINavigationItem *navigationBarTitle = [[UINavigationItem alloc] init];
    //添加按钮
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    navigationBarTitle.rightBarButtonItem = addButton;
    
    [navigationBar pushNavigationItem:navigationBarTitle animated:YES];
    [self.view addSubview:navigationBar];
    
    UIButton *headerImageButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 22, 40, 40)];
    [headerImageButton setImage:[UIImage imageNamed:@"headImage.png"] forState:UIControlStateNormal];
    headerImageButton.layer.cornerRadius = 20;
    headerImageButton.clipsToBounds = YES;
    [self.view addSubview: headerImageButton];
    
    NSArray *array = [NSArray arrayWithObjects:@"消息",@"电话", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:array];
    segmentedControl.frame = CGRectMake(screenWidth/2.0 - 60, 28, 120, 29);
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
}



#pragma mark - segmentedControl action
- (void)segmentedControlAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        NSLog(@"显示消息");
        [telephoneView removeFromSuperview];
        [self installMessageTableView];
        [messageTableView addSubview:self.azMetaBallView];
    }else {
        NSLog(@"显示电话");
        [messageTableView removeFromSuperview];
        [self installTelephoneView];
    }
}


#pragma mark - installMessageTableView
- (void)installMessageTableView
{
    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenWidth, screenHeight-64-49)];
    messageTableView.showsVerticalScrollIndicator = YES;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    messageTableView.tableHeaderView = [self installHeaderView];
    messageTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadMessageData)];
    messageTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(addMessageData)];
    [self.view addSubview:messageTableView];

}


#pragma mark - installTelephoneView
- (void)installTelephoneView
{
    [self.view addSubview:telephoneView];

}


#pragma mark - installHeaderView for tableHeaderView
- (UIView *)installHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    mySearchBar.searchBarStyle = UISearchBarStyleMinimal;
    mySearchBar.placeholder = @"搜索";
    mySearchBar.delegate = self;
    [headerView addSubview:mySearchBar];
    
    return headerView;

}



#pragma mark - UIsearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [mySearchBar resignFirstResponder];
}



#pragma mark - tableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (messageDataArray.count == 0) {
        return 10;
    }else {
        return messageDataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}



#pragma mark - tableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MessageTableCell";
    AlexQQMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AlexQQMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (messageDataArray.count != 0) {
        NSDictionary *dic = [messageDataArray objectAtIndex:indexPath.row];
        
        NSString *urlSting = [dic valueForKey:@"avatar"];
        NSURL *url = [NSURL URLWithString:urlSting];
        UIImageView *cacheImageView = [[UIImageView alloc] init];
        [cacheImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //添加圆角
            UIGraphicsBeginImageContextWithOptions(cell.avatarImageView.bounds.size, NO, 1.0);
            [[UIBezierPath bezierPathWithRoundedRect:cell.avatarImageView.bounds cornerRadius:25] addClip];
            [image drawInRect:cell.avatarImageView.bounds];
            cell.avatarImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

        }];
        cell.nicknameLabel.text = [dic valueForKey:@"nickname"];
        cell.messageLabel.text = [dic valueForKey:@"intro"];
    }
    return cell;

}



#pragma mark - loadAllMessage
- (void)loadAllMessage
{
    dataPersistence = [[AlexQQDataPersistence alloc] init];
    [dataPersistence createDataBase];
    [dataPersistence openDataBase];
    arrayOfAllMessageData = [dataPersistence selectMessageDataFomeAuthorTable];
    [dataPersistence closeDataBase];
    if (arrayOfAllMessageData == nil) {
        self.request = [[AlexQQContactsRequest alloc] init];
        NSString *urlString = @"http://7rf426.com2.z0.glb.qiniucdn.com/news.json";
        [self.request sendContactsRequestWithUrl:urlString delegate:self];

    }
}


#pragma mark - header and footer refresh
- (void)reloadMessageData
{
    [messageDataArray removeAllObjects];
    
    for (indexOfLoadedData = 0; indexOfLoadedData < 20; indexOfLoadedData++) {
        [messageDataArray addObject:arrayOfAllMessageData[indexOfLoadedData]];
    }
    if (indexOfLoadedData == 20) {
        [messageTableView.mj_header endRefreshing];
        [messageTableView reloadData];
    }
}

- (void)addMessageData
{
    int i = indexOfLoadedData;
    for (i ; i < indexOfLoadedData+20; i++) {
        if (i < arrayOfAllMessageData.count) {
            [messageDataArray addObject:arrayOfAllMessageData[i]];
        }else {
            break;
        }
    }
    if (i < arrayOfAllMessageData.count) {
        indexOfLoadedData = indexOfLoadedData +20;
        [messageTableView.mj_footer endRefreshing];
        [messageTableView reloadData];
    }else {
        [messageTableView.mj_footer endRefreshingWithNoMoreData];
        [messageTableView reloadData];
    }
}

#pragma mark - contactsRequestDelegate
- (void)ContactsRequestSuccess:(AlexQQContactsRequest *)request category:(NSMutableArray *)category authors:(NSMutableArray *)authors
{
    arrayOfAllMessageData = authors;
    [self reloadMessageData];
}

- (void)ContactsRequestFailed:(AlexQQContactsRequest *)request error:(NSError *)error
{
    
}


@end
