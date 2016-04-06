//
//  AlexQQContactsViewController.m
//  AlexQQ
//
//  Created by ZhangBob on 4/3/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQContactsViewController.h"
#import "AlexQQContactsHeaderView.h"
#import "AlexQQContactsRequest.h"
#import "AlexQQCategoryModel.h"
#import "AlexQQAuthorsModel.h"
#import "AlexQQContactsTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AlexQQDataPersistence.h"

#define screenWidth self.view.frame.size.width
#define screenHeight self.view.frame.size.height

@interface AlexQQContactsViewController ()<UITableViewDataSource,UITableViewDelegate,AlexQQContactsRequestDelegate>
{
    UITableView *contactsTableView;
    NSMutableArray *categoryNameArray;      //分组名数组
    NSMutableDictionary *categoryDic;       //按照categoryName区分authors，一个categoryName（key）对应一个authors数组（value）
    NSMutableArray *selectedArray;          //需要展开显示联系人的分组
    
    AlexQQDataPersistence *dataPersistence; //数据存储
    UIRefreshControl *refreshControl;       //下拉刷新
    NSMutableArray *followStatusArray;      //存放每组在线人数，由于返回的数据followStatus全部为0，所以此处自己随机生成在线人数
}

@property (nonatomic, strong) AlexQQContactsRequest *contactsRequest;

@end

@implementation AlexQQContactsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self contactsRequestAction];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self installNavigationBar];
    
    //初始化在线人数数组
    followStatusArray = [[NSMutableArray alloc] init];
    [self randomNumberOfOnlineCatacts];
    
    contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenWidth, screenHeight-64-49)];
    contactsTableView.showsVerticalScrollIndicator = YES;
    contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    contactsTableView.delegate = self;
    contactsTableView.dataSource = self;
    
    //给TableView添加HeaderView
    contactsTableView.tableHeaderView = [self installTableHeaderView];
    
    [self.view addSubview:contactsTableView];
    
    //下拉刷新
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
    [contactsTableView addSubview:refreshControl];
    
    [refreshControl beginRefreshing];
    
    //初始化一下两个NSMutableArray
    categoryNameArray = [[NSMutableArray alloc] init];
    categoryDic = [[NSMutableDictionary alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    
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
    UINavigationItem *navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@"联系人"];
    //添加按钮
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:nil];
    navigationBarTitle.rightBarButtonItem = addButton;
    
    
    [navigationBar pushNavigationItem:navigationBarTitle animated:YES];
    [self.view addSubview:navigationBar];
    
    UIButton *headerImageButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 24, 40, 40)];
    [headerImageButton setImage:[UIImage imageNamed:@"headImage.png"] forState:UIControlStateNormal];
    headerImageButton.layer.cornerRadius = 20;
    headerImageButton.clipsToBounds = YES;
    [self.view addSubview: headerImageButton];
}



#pragma mark - TableView HeaderView
- (UIView *)installTableHeaderView
{
    AlexQQContactsHeaderView *headerView =
                        [[AlexQQContactsHeaderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 114)];
    
    [headerView.addFriendButton setBackgroundImage:[UIImage imageNamed:@"head_button_selected.png"] forState:UIControlStateHighlighted];
    [headerView.caresButton setBackgroundImage:[UIImage imageNamed:@"head_button_selected.png"] forState:UIControlStateHighlighted];
    [headerView.groupButton setBackgroundImage:[UIImage imageNamed:@"head_button_selected.png"] forState:UIControlStateHighlighted];
    [headerView.publicNumberButton setBackgroundImage:[UIImage imageNamed:@"head_button_selected.png"] forState:UIControlStateHighlighted];
    
    [headerView.addFriendButton addTarget:self
                    action:@selector(addFriendButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [headerView.caresButton addTarget:self
                    action:@selector(caresButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [headerView.groupButton addTarget:self
                    action:@selector(groupButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [headerView.publicNumberButton addTarget:self
                    action:@selector(publicNumberButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    
    
    return headerView;
}



#pragma mark - four HeadButton Action
- (void)addFriendButtonClicked:(id *)sender
{
    NSString *message = @"点击了新朋友";
    [self showMessageAlert:message];
}

- (void)caresButtonClicked:(id *)sender
{
    NSString *message = @"点击了特别关心";
    [self showMessageAlert:message];
}

- (void)groupButtonClicked:(id *)sender
{
    NSString *message = @"点击了群组";
    [self showMessageAlert:message];
}

- (void)publicNumberButtonClicked:(id *)sender
{
    NSString *message = @"点击了公众号";
    [self showMessageAlert:message];
}



#pragma mark - AlertController
- (void)showMessageAlert:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return categoryNameArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *string = [NSString stringWithFormat:@"%ld",section];
    if ([selectedArray containsObject:string]) {
        NSString *keyString = [categoryNameArray objectAtIndex:section];
        NSArray *array = [categoryDic objectForKey:keyString];
        return array.count;
    }else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, self.view.frame.size.width-100, 30)];
    titleLabel.text = [categoryNameArray objectAtIndex:section];
    [view addSubview:titleLabel];
    
    UILabel *onlineNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-35, 5, 35, 30)];
    onlineNumberLabel.font = [UIFont systemFontOfSize:12.0];
    onlineNumberLabel.textColor = [UIColor lightGrayColor];
    
    NSString *categoryNameOfSection = [NSString stringWithFormat:@"%@",[categoryNameArray objectAtIndex:section]];
    NSInteger numberOfCategory = [[categoryDic objectForKey:categoryNameOfSection] count];
    NSInteger numberOfOnlineContacts = [followStatusArray[section] integerValue];
    onlineNumberLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)numberOfOnlineContacts,(long)numberOfCategory];
    [view addSubview:onlineNumberLabel];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 10, 10)];
    imageView.tag = 20000+section;
    NSString *string = [NSString stringWithFormat:@"%ld",section];
    if ([selectedArray containsObject:string]) {
        imageView.image = [UIImage imageNamed:@"arrow_down.png"];
    }else {
        imageView.image = [UIImage imageNamed:@"arrow_right.png"];
    }
    [view addSubview:imageView];
    
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headerButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    headerButton.tag = 10000+section;
    [headerButton addTarget:self
                     action:@selector(headerButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:headerButton];
    
    return view;

}


#pragma mark - tableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indexString = [NSString stringWithFormat:@"%ld",indexPath.section];
    
    NSString *keyString = [categoryNameArray objectAtIndex:indexPath.section];
    NSArray *array = [categoryDic objectForKey:keyString];
    static NSString *CellIdentifier = @"CellIdentifier";
    AlexQQContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AlexQQContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
//    //根据返回数据中followStatus决定在线状态和在线时的网络类型
//    if ([selectedArray containsObject:indexString]) {
//        NSDictionary *dic = [array objectAtIndex:indexPath.row];
//    __unsafe_unretained AlexQQContactsTableViewCell *weakCell = cell;
//    NSString *urlSting = [dic valueForKey:@"avatar"];
//    NSURL *url = [NSURL URLWithString:urlSting];
//    UIImageView *cacheImageView = [[UIImageView alloc] init];
//    [cacheImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"xiaohongdian.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        //添加圆角
//        UIGraphicsBeginImageContextWithOptions(cell.avatarImage.bounds.size, NO, 1.0);
//        [[UIBezierPath bezierPathWithRoundedRect:cell.avatarImage.bounds cornerRadius:25] addClip];
//        [cacheImageView.image drawInRect:cell.avatarImage.bounds];
//        cell.avatarImage.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        if (image ==nil) {
//            cell.avatarImage.image = [UIImage imageNamed:@"xiaohongdian.png"];
//        }
//        [weakCell setNeedsLayout];
//    }];
//
//
//        cell.nicknameLabel.text = [dic valueForKey:@"nickname"];
//        cell.introLabel.text = [dic valueForKey:@"intro"];
//        int followStatus = (int)[[dic valueForKey:@"followStatus"] integerValue];
//        if (followStatus == 0 ) {
//            cell.followStatusLabel.text = @"[离线]";
//        }else {
//            cell.followStatusLabel.text = @"[在线]";
//            UIImage *networkImage4G = [UIImage imageNamed:@"contacts_network_4g.png"];
//            UIImage *networkImageWiFi = [UIImage imageNamed:@"contacts_network_wifi.png"];
//            if ((arc4random()%2) == 0) {
//                cell.networkImage.image = networkImage4G;
//            }else {
//                cell.networkImage.image = networkImageWiFi;
//            }
//        }
//    }
    
    //根据随机生成的followStatus决定在线状态和在线时的网络类型
    NSInteger numberOfOnlineContacts = [followStatusArray[indexPath.section] integerValue];
    if (indexPath.row < (long)numberOfOnlineContacts) {
        if ([selectedArray containsObject:indexString]) {
            NSDictionary *dic = [array objectAtIndex:indexPath.row];
            __unsafe_unretained AlexQQContactsTableViewCell *weakCell = cell;
            NSString *urlSting = [dic valueForKey:@"avatar"];
            NSURL *url = [NSURL URLWithString:urlSting];
            UIImageView *cacheImageView = [[UIImageView alloc] init];
            [cacheImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"xiaohongdian.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                //添加圆角
                UIGraphicsBeginImageContextWithOptions(cell.avatarImage.bounds.size, NO, 1.0);
                [[UIBezierPath bezierPathWithRoundedRect:cell.avatarImage.bounds cornerRadius:25] addClip];
                [cacheImageView.image drawInRect:cell.avatarImage.bounds];
                cell.avatarImage.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                if (image ==nil) {
                    cell.avatarImage.image = [UIImage imageNamed:@"xiaohongdian.png"];
                }
                [weakCell setNeedsLayout];
            }];
            
            cell.nicknameLabel.text = [dic valueForKey:@"nickname"];
            cell.introLabel.text = [dic valueForKey:@"intro"];
            cell.followStatusLabel.text = @"[在线]";
            UIImage *networkImage4G = [UIImage imageNamed:@"contacts_network_4g.png"];
            UIImage *networkImageWiFi = [UIImage imageNamed:@"contacts_network_wifi.png"];
            if ((arc4random()%2) == 0) {
                cell.networkImage.image = networkImage4G;
            }else {
                cell.networkImage.image = networkImageWiFi;
            }
        }
    }else {
        if ([selectedArray containsObject:indexString]) {
            NSDictionary *dic = [array objectAtIndex:indexPath.row];
            __unsafe_unretained AlexQQContactsTableViewCell *weakCell = cell;
            NSString *urlSting = [dic valueForKey:@"avatar"];
            NSURL *url = [NSURL URLWithString:urlSting];
            UIImageView *cacheImageView = [[UIImageView alloc] init];
            [cacheImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"xiaohongdian.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                //添加圆角
                UIGraphicsBeginImageContextWithOptions(cell.avatarImage.bounds.size, NO, 1.0);
                [[UIBezierPath bezierPathWithRoundedRect:cell.avatarImage.bounds cornerRadius:25] addClip];
                [cacheImageView.image drawInRect:cell.avatarImage.bounds];
                cell.avatarImage.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                if (image ==nil) {
                    cell.avatarImage.image = [UIImage imageNamed:@"xiaohongdian.png"];
                }
                [weakCell setNeedsLayout];
            }];

            cell.nicknameLabel.text = [dic valueForKey:@"nickname"];
            cell.introLabel.text = [dic valueForKey:@"intro"];
            int followStatus = (int)[[dic valueForKey:@"followStatus"] integerValue];
            if (followStatus == 0 ) {
                cell.followStatusLabel.text = @"[离线]";
            }else {
                cell.followStatusLabel.text = @"[在线]";
                UIImage *networkImage4G = [UIImage imageNamed:@"contacts_network_4g.png"];
                UIImage *networkImageWiFi = [UIImage imageNamed:@"contacts_network_wifi.png"];
                if ((arc4random()%2) == 0) {
                    cell.networkImage.image = networkImage4G;
                }else {
                    cell.networkImage.image = networkImageWiFi;
                }
            }
        }
    }
    return cell;
}



#pragma mark - contactsRequest
- (void)contactsRequestAction
{
    self.contactsRequest = [[AlexQQContactsRequest alloc] init];
    NSString *urlString = @"http://7rf426.com2.z0.glb.qiniucdn.com/news.json";
    [self.contactsRequest sendContactsRequestWithUrl:urlString delegate:self];
    dataPersistence = [[AlexQQDataPersistence alloc] init];
    [dataPersistence createDataBase];
    [dataPersistence createCategoryTable];
    [dataPersistence createAuthorTable];
}



#pragma mark - AlexQQContactsRequestDelegate
- (void)ContactsRequestSuccess:(AlexQQContactsRequest *)request category:(NSMutableArray *)category authors:(NSMutableArray *)authors
{
    [refreshControl endRefreshing];
    if (category)
    {
        NSLog(@"联系人请求成功");
//        NSLog(@"%@ \n %@",category,authors);
        
        //将解析完成的category和authors存到数据库里
        [dataPersistence insertIntoCategoryTable:category];
        [dataPersistence insertINtoAuthorTable:authors];
        
        //开辟线程处理数据
        //将分组名赋给categoryNameArray
        //用字典存储联系人信息，组名为key，该组下面的联系人为value
        dispatch_queue_t dataProcessQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(dataProcessQueue, ^{
            for (int indexOfCategory = 0; indexOfCategory < category.count; indexOfCategory++) {
                AlexQQCategoryModel *categoryModel = category[indexOfCategory];
                [categoryNameArray addObject:categoryModel.categoryName];
                
                NSMutableArray *category = [[NSMutableArray alloc] init];
                
                for (int index = 0; index < authors.count; index++) {
                    AlexQQAuthorsModel *authorsModel = authors[index];
                    if ([authorsModel.category_id intValue] == indexOfCategory) {
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:authorsModel.avatar,@"avatar",authorsModel.followStatus,@"followStauts",authorsModel.intro,@"intro",authorsModel.nickname,@"nickname",authorsModel.subscriptionNum,@"subscriptionNum", nil];
                        [category addObject:dic];
                    }
                }
                [categoryDic setValue:category forKey:categoryNameArray[indexOfCategory]];
            }
//            NSLog(@"%@",categoryDic);
          
            //数据处理完成后，通过主线程更新tableView
            dispatch_queue_t getMainQueue = dispatch_get_main_queue();
            dispatch_async(getMainQueue, ^{
                [contactsTableView reloadData];
            });
        });
    }else {
        NSLog(@"联系人请求失败");
        
    }
}

- (void)ContactsRequestFailed:(AlexQQContactsRequest *)request error:(NSError *)error
{
    NSLog(@"请求失败，错误原因:%@",error);
    [dataPersistence openDataBase];
    categoryDic = [dataPersistence selectDataFromAuthorTable];
    [dataPersistence closeDataBase];
    for (id keyOfCategoryDic in categoryDic) {
        [categoryNameArray addObject:keyOfCategoryDic];
    }
}



#pragma mark - headerButton clicked action
- (void)headerButtonClicked:(UIButton *)sender
{
    NSString *string = [NSString stringWithFormat:@"%ld",sender.tag-10000];
    
    if ([selectedArray containsObject:string]) {
        [selectedArray removeObject:string];
    }else {
        [selectedArray addObject:string];
    }
    
    [contactsTableView reloadData];
}



#pragma mark - RefreshControl action
- (void)refreshControlAction
{
    [categoryNameArray removeAllObjects];
    [categoryDic removeAllObjects];
    [self contactsRequestAction];
    [followStatusArray removeAllObjects];
    [self randomNumberOfOnlineCatacts];
}



#pragma mark - random number of online contacts
- (void)randomNumberOfOnlineCatacts
{
    for (int i = 0; i < 5; i++) {
        [followStatusArray addObject:[NSNumber numberWithInt:arc4random()%13]];
    }
}

@end
