//
//  AlexQQContactsRequest.h
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlexQQContactsRequest;

@protocol AlexQQContactsRequestDelegate <NSObject>

- (void)ContactsRequestSuccess:(AlexQQContactsRequest *)request
                      category:(NSMutableArray *)category
                       authors:(NSMutableArray *) authors;

- (void)ContactsRequestFailed:(AlexQQContactsRequest *)request error:(NSError *)error;

@end

@interface AlexQQContactsRequest : NSObject

@property (nonatomic, assign) id<AlexQQContactsRequestDelegate> delegate;

- (void)sendContactsRequestWithUrl:(NSString *)url
                          delegate:(id<AlexQQContactsRequestDelegate>) delegate;

@end
