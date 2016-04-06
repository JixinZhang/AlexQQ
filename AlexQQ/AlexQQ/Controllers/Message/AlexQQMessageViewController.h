//
//  AlexQQMessageViewController.h
//  AlexQQ
//
//  Created by ZhangBob on 4/3/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlexQQContactsRequest.h"
#import "AZMetaBallCanvas.h"

@interface AlexQQMessageViewController : UIViewController


//联系人请求
@property (nonatomic, strong) AlexQQContactsRequest *request;

//消息tabBarItem
@property (weak, nonatomic) IBOutlet UITabBarItem *messageTabBarItem;

//“一键退朝”的View，这里集成了github上Xieyupeng520的代码
//Github链接: https://github.com.Xieyupeng520/AZMetaBall 
@property (nonatomic, strong) AZMetaBallCanvas *azMetaBallView;

@end
