//
//  AlexQQDataPersistence.h
//  AlexQQ
//
//  Created by ZhangBob on 4/5/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface AlexQQDataPersistence : NSObject

@property (nonatomic, strong) FMDatabase *dataBase;

- (void)openDataBase;

- (void)closeDataBase;

- (void)createDataBase;

- (BOOL)createCategoryTable;

- (BOOL)createAuthorTable;

- (void)insertIntoCategoryTable:(NSArray *)category;

- (void)insertINtoAuthorTable:(NSArray *)authors;

- (NSMutableDictionary *)selectDataFromAuthorTable;

- (NSMutableArray *)selectMessageDataFomeAuthorTable;

@end
