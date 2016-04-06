//
//  AlexQQContactsRequestParser.h
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlexQQContactsRequestParser : NSObject

//数据解析，将服务器返回的数据按照categoryModel和authorsModel解析为两种类型
//最后将两者放在同一个字典里
- (NSMutableDictionary *)parserArray:(NSMutableArray *)receivedArray;

@end
