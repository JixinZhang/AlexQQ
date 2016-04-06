//
//  AlexQQDataPersistence.m
//  AlexQQ
//
//  Created by ZhangBob on 4/5/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQDataPersistence.h"
#import "AlexQQCategoryModel.h"
#import "AlexQQAuthorsModel.h"

@implementation AlexQQDataPersistence

- (void)openDataBase
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *currentFileName = [NSString stringWithFormat:@"Contacts.rdb"];
    NSString *currentFilePath = [documentPath stringByAppendingPathComponent:currentFileName];
    
    self.dataBase = [FMDatabase databaseWithPath:currentFilePath];
    [self.dataBase open];
}

- (void)closeDataBase
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *currentFileName = [NSString stringWithFormat:@"Contacts.rdb"];
    NSString *currentFilePath = [documentPath stringByAppendingPathComponent:currentFileName];
    
    self.dataBase = [FMDatabase databaseWithPath:currentFilePath];
    [self.dataBase close];
}

- (void)createDataBase
{
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *currentFileName = [NSString stringWithFormat:@"Contacts.rdb"];
    NSString *currentFilePath = [documentPath stringByAppendingPathComponent:currentFileName];
    
    self.dataBase = [FMDatabase databaseWithPath:currentFilePath];
}

- (BOOL)createCategoryTable
{
    if ([self.dataBase open]) {
        NSLog(@"打开数据库成功");
        NSString *sql = @"CREATE TABLE IF NOT EXISTS category (id integer PRIMARY KEY, category_name text NOT NULL);";
        BOOL result = [self.dataBase executeUpdate:sql];
        if (result) {
            NSLog(@"success to create table category");
            [self.dataBase close];
        }
        return result;
    }else {
        return NO;
    }
}

- (BOOL)createAuthorTable
{
    if ([self.dataBase open]) {
        NSLog(@"打开数据库成功");
        NSString *sqlAuthor = @"CREATE TABLE IF NOT EXISTS author (id integer PRIMARY KEY, avatar text, followStatus text, intro text, nickname text, subscription_num text, category_id text);";
        BOOL resultOfAuthor = [self.dataBase executeUpdate:sqlAuthor];
        if (resultOfAuthor) {
            NSLog(@"success to create table author");
            [self.dataBase close];
        }
        return resultOfAuthor;
    }else {
        return NO;
    }
}

- (void)insertIntoCategoryTable:(NSArray *)category
{
    if ([self.dataBase open]) {
        for (int i = 0; i < category.count; i++) {
            AlexQQCategoryModel *categoryModel = category[i];
            BOOL result = [self.dataBase executeUpdate:@"INSERT INTO category (id, category_name) VALUES (?, ?);",categoryModel.id,categoryModel.categoryName];
            if (!result) {
                continue;
            }
        }
        NSLog(@"联系人分组信息存储成功");
        [self.dataBase close];
    }
    
}

- (void)insertINtoAuthorTable:(NSArray *)authors
{
    if ([self.dataBase open]) {
        for (int i = 0; i < authors.count; i++) {
            AlexQQAuthorsModel *authorsModel = authors[i];
            BOOL result = [self.dataBase executeUpdateWithFormat:@"INSERT INTO author (id, avatar, followStatus, intro, nickname, subscription_num, category_id) VALUES (%@, %@, %@, %@, %@, %@, %@);",authorsModel.id, authorsModel.avatar, authorsModel.followStatus, authorsModel.intro, authorsModel.nickname, authorsModel.subscriptionNum, authorsModel.category_id];
            if (!result) {
                continue;
            }
        }
        NSLog(@"联系人存储成功");
        [self.dataBase close];
    }
}

- (NSMutableDictionary *)selectDataFromAuthorTable
{
    //获取category的组名，组成一个数组
    NSMutableArray *categoryNameArray = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [self.dataBase executeQuery:@"SELECT * FROM category;"];
    while ([resultSet next]) {
        int id = [resultSet intForColumn:@"id"];
        NSString *categoryName = [resultSet stringForColumn:@"category_name"];
        categoryNameArray[id] = categoryName;
    }
    NSLog(@"categoryNameArray = %@",categoryNameArray);
    
    //获取每个category分组中的author信息，组成一个Dictionary
    NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < categoryNameArray.count; i++) {
        FMResultSet *resultSetOfAuthor = [self.dataBase executeQueryWithFormat:@"SELECT * FROM author where category_id = %d;",i];
        NSMutableArray *category = [[NSMutableArray alloc] init];
        while ([resultSetOfAuthor next]) {
            NSString *avatar = [resultSetOfAuthor stringForColumn:@"avatar"];
            NSString *followStatus = [resultSetOfAuthor stringForColumn:@"followStatus"];
            NSString *intro = [resultSetOfAuthor stringForColumn:@"intro"];
            NSString *nickname = [resultSetOfAuthor stringForColumn:@"nickname"];
            NSString *subscriptionNum = [resultSetOfAuthor stringForColumn:@"subscription_num"];
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:avatar,@"avatar",followStatus,@"followStauts",intro,@"intro",nickname,@"nickname",subscriptionNum,@"subscriptionNum", nil];
            [category addObject:dic];
        }
        [categoryDict setValue:category forKey:categoryNameArray[i]];
    }
    NSLog(@"category dictionary = %@",categoryDict);
    return categoryDict;
}

- (NSMutableArray *)selectMessageDataFomeAuthorTable
{
    FMResultSet *resultSet = [self.dataBase executeQuery:@"SELECT * FROM author;"];
    NSMutableArray *messageDataArray = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSString *avatar = [resultSet stringForColumn:@"avatar"];
        NSString *followStatus = [resultSet stringForColumn:@"followStatus"];
        NSString *intro = [resultSet stringForColumn:@"intro"];
        NSString *nickname = [resultSet stringForColumn:@"nickname"];
        NSString *subscriptionNum = [resultSet stringForColumn:@"subscription_num"];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:avatar,@"avatar",followStatus,@"followStauts",intro,@"intro",nickname,@"nickname",subscriptionNum,@"subscriptionNum", nil];
        [messageDataArray addObject:dic];
    }
    return messageDataArray;
}


@end
