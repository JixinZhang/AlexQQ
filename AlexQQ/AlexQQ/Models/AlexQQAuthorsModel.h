//
//  AlexQQAuthorsModel.h
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlexQQAuthorsModel : NSObject

//联系人数据模型
@property (nonatomic, copy) NSString *followStatus;
@property (nonatomic, copy) NSString *subscriptionNum;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *id;

//category_id是便于从数据库里按照分组提取联系人数据
//category_id赋值是在数据解析的时候
@property (nonatomic, copy) NSString *category_id;

@end
