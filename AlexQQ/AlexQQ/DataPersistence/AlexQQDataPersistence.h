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

- (BOOL)openDataBase;

- (BOOL)closeDataBase;

- (BOOL)createDataBase;

- (BOOL)createCategoryTable;

- (BOOL)createAuthorTable;

- (void)insertIntoCategoryTable:(NSArray *)category;

- (void)insertINtoAuthorTable:(NSArray *)authors;

- (NSMutableDictionary *)selectDataFromAuthorTable;

- (NSMutableArray *)selectMessageDataFomeAuthorTable;

@end
