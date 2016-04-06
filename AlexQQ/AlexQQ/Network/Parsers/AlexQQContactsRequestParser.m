//
//  AlexQQContactsRequestParser.m
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQContactsRequestParser.h"
#import "AlexQQAuthorsModel.h"
#import "AlexQQCategoryModel.h"
@implementation AlexQQContactsRequestParser

- (NSMutableDictionary *)parserArray:(NSMutableArray *)receivedArray
{
    //存放category数据
    NSMutableArray *category = [[NSMutableArray alloc] init];
    
    //存放authors数据
    NSMutableArray *authors = [[NSMutableArray alloc] init];
    //将category中的id转化为category_id存放在author里，便于通过category的id取出对应的所有author
    NSString *category_id = nil;
    if ([[receivedArray class] isSubclassOfClass:[NSArray class]]) {
        NSLog(@"receivedArray is sub class of class");
    }
    for (int i = 0; i < [receivedArray count]; i++) {
        AlexQQCategoryModel *categoryModel = [[AlexQQCategoryModel alloc] init];
        [categoryModel setValuesForKeysWithDictionary:[receivedArray[i] objectForKey:@"category"]];
        [category addObject:categoryModel];
        category_id = [NSString stringWithFormat:@"%d",i];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        array = [receivedArray[i] objectForKey:@"authors"];
        for (int counter = 0 ;counter < array.count ; counter++) {
            AlexQQAuthorsModel *authorsModel = [[AlexQQAuthorsModel alloc] init];
            [authorsModel setValuesForKeysWithDictionary:array[counter]];
            authorsModel.category_id = category_id;
            [authors addObject:authorsModel];
            
        }
    }
    
    //将得到的category和authors放在parsedDictionary;
    NSMutableDictionary *parsedDictionary = [[NSMutableDictionary alloc] init];
    [parsedDictionary setValue:category forKey:@"category"];
    [parsedDictionary setValue:authors forKey:@"authors"];
    
    return parsedDictionary;
}

@end