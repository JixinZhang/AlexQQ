//
//  AlexQQTests.m
//  AlexQQTests
//
//  Created by ZhangBob on 4/3/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AlexQQDataPersistence.h"
#import "AlexQQContactsRequest.h"
@interface AlexQQTests : XCTestCase<AlexQQContactsRequestDelegate>

@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation AlexQQTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testOpenDataBase
{
    //given
    AlexQQDataPersistence *dataPersistence = [[AlexQQDataPersistence alloc] init];
    //when
    BOOL result = [dataPersistence openDataBase];
    //then
    XCTAssert(result);
}

- (void)testCloseDataBase
{
    //given
    AlexQQDataPersistence *dataPersistence = [[AlexQQDataPersistence alloc] init];
    //when
    BOOL result = [dataPersistence closeDataBase];
    //then
    XCTAssert(result);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testSendContactsRequestWithUrlAndDelegate
{
    NSString *urlString = @"http://7rf426.com2.z0.glb.qiniucdn.com/news.json";
    self.expectation = [self expectationWithDescription:@"Request Contacts"];
    
    AlexQQContactsRequest *request = [[AlexQQContactsRequest alloc] init];
    request.delegate = self;
    [request sendContactsRequestWithUrl:urlString delegate:self];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)ContactsRequestSuccess:(AlexQQContactsRequest *)request category:(NSMutableArray *)category authors:(NSMutableArray *)authors
{
    [self.expectation fulfill];
    XCTAssertEqual(5, category.count,@"category.count should be 5");
    XCTAssertEqual(132, authors.count,@"authors.count should be 132");
}

- (void)ContactsRequestFailed:(AlexQQContactsRequest *)request error:(NSError *)error
{
    [self.expectation fulfill];
    XCTAssertNotNil(error,@"请求数据失败时应收到错误信息");
}



@end
