//
//  SQLiteTests.m
//  SQLiteTests
//
//  Created by Jun on 13-11-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LJSQLiteConnection.h"
#import "Person.h"
#import "Book.h"
#import "NSObject+LJSQLite.h"

@interface SQLiteTests : XCTestCase

@end

@implementation SQLiteTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    [[LJSQLite sharedLJSQLite] createTable:[Person class] autoincrement:YES];
    
    [[LJSQLite sharedLJSQLite] deleteObjects:[Person class] whereParams:@{
               @"age":@"5"
    }];
}

- (void)testObj {
    [[LJSQLite sharedLJSQLite] createTable:[Person class] autoincrement:YES];
    Person * p = [[Person alloc]init];
    p.p_id = 1;
    
    
    NSLog(@"%d",[[LJSQLite sharedLJSQLite] isObject:p]);
}

- (void)testObjs {
    [[LJSQLite sharedLJSQLite] createTable:[Person class] autoincrement:YES];
    Person * p = [[Person alloc]init];
    p.name = @"asdf";
    p.age = 1;
    p.height = 1.3;
    
    Book * b = [[Book alloc]init];
    b.name = @"988k";
    
    p.book = b;
    
    [[LJSQLite sharedLJSQLite] createTable:[Person class] autoincrement:YES];
    
    [[LJSQLite sharedLJSQLite] addObject:p];
    
}

- (void)testObjPrimaryKeyName {
    Person * p = [[Person alloc]init];
    p.p_id = 12;
    NSLog(@"%@",[p primaryKeyName]);
    NSLog(@"%@",[p primaryKeyAndValue]);
}

- (void)testObjAndSubObj {
    Person * p = (Person *)[[LJSQLite sharedLJSQLite] objectsWithObjClass:[Person class] params:@{@"name":@"323"}];
    NSLog(@"%@",p);
}

- (void)testInsertObj {
    [[LJSQLite sharedLJSQLite] createTable:[Person class] autoincrement:YES];
    Person * p = [[Person alloc]init];
    p.name = @"asdf";
    p.age = 1;
    p.height = 1.3;
    
    Book * b = [[Book alloc]init];
    b.b_id = 12;
    
    p.book = b;
    
    [[LJSQLite sharedLJSQLite] addObject:p];
}

- (void)testInsertsObj {
    for (NSInteger i = 0; i < 30; i++) {
        Person * p = [[Person alloc]init];
        p.name = [NSString stringWithFormat:@"sdf --- %d",i];
        p.age = 1;
        p.height = 1.3;
        [[LJSQLite sharedLJSQLite] addObject:p];
    }
}

- (void)testObjsAndWhere {
    int count = 0;
    NSArray * array = [[LJSQLite sharedLJSQLite]objectsWithObjClass:[Person class] whereStr:@"Where age > 0" orderBy:nil limit:NSMakeRange(7, 2) count:&count];
    NSLog(@"%@ \n-- count %d",array,count);
}

@end
