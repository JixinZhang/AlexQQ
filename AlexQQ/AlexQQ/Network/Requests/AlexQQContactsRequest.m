//
//  AlexQQContactsRequest.m
//  AlexQQ
//
//  Created by ZhangBob on 4/4/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "AlexQQContactsRequest.h"
#import <AFNetworking.h>
#import "AlexQQContactsRequestParser.h"

@implementation AlexQQContactsRequest

- (void)sendContactsRequestWithUrl:(NSString *)url
                          delegate:(id<AlexQQContactsRequestDelegate>)delegate
{
    self.delegate = delegate;
    NSString *urlSting = url;
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    [session GET:urlSting parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        AlexQQContactsRequestParser *parser = [[AlexQQContactsRequestParser alloc] init];
        NSMutableDictionary *parsedDictionary = [parser parserArray:responseObject];
        
        if ([_delegate respondsToSelector:@selector(ContactsRequestSuccess:category:authors:)]) {
            [_delegate ContactsRequestSuccess:self category:[parsedDictionary objectForKey:@"category"] authors:[parsedDictionary objectForKey:@"authors"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([_delegate respondsToSelector:@selector(ContactsRequestFailed:error:)]) {
            [_delegate ContactsRequestFailed:self error:error];
        }
    }];
}


@end
