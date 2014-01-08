//
//  LJSQLite+Where.m
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "LJSQLite+Where.h"

#import <sqlite3.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import "NSDictionary+SQLite.h"

@implementation LJSQLite (Where)

/**
 *  删除对应数据表的对象数据
 *
 *  @param objClass     对象
 *  @param params       查找条件 key：成员变量名 value：查询数据  如：@"name" : @"adf"
 *                      where name = @"adf" and ...;
 */
- (void) deleteObjects:(Class)objClass whereParams:(NSDictionary *)params {
    //拼接where语句
//    NSMutableString * whereStr = [NSMutableString string];
//    NSArray * array = [params allKeys];
//    for (NSString * name in array) {
//        NSValue * value = params[name];
//        if ([value isKindOfClass:[NSString class]]) {
//            [whereStr appendFormat:@" %@ = '%@' and",name,value];
//        } else {
//            [whereStr appendFormat:@" %@ = %@ and",name,value];
//        }
//        
//    }
//    //去除最后and
//    [whereStr deleteCharactersInRange:NSMakeRange(whereStr.length - 3, 3)];
    
    
    [self deleteObjects:objClass whereStr:[params stringByWhereSQLConversion]];
}
/**
 *  删除对应数据表的对象数据
 *
 *  @param objClass 对象类
 *  @param whereStr 判断字符串  例如：@"name = 'bac' and age = 12 or height > 1.1 and height < 5"
 */
- (void) deleteObjects:(Class)objClass whereStr:(NSString *)whereStr {
    //表名
    NSString * tableName = kTableName(objClass);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ ",tableName];
    
    [sql appendString:whereStr];
    
    [sql appendString:@";"];
    
    [self execSQL:sql msg:@"删除数据"];
}

/**
 *  更新对应数据表的对象数据
 *
 *  @param objClass     对象
 *  @param params  查找条件 key：成员变量名 value：查询数据  如：@"name" : @"adf"
 *                      where name = @"adf" and ...;
 */
- (void)updateObjects:(NSObject *)obj whereParams:(NSDictionary *)params {
    
}

/**
 *  删除对应数据表的对象数据
 *
 *  @param objClass 对象类
 *  @param whereStr 判断字符串  例如：@"name = 'bac' and age = 12 or height > 1.1 and height < 5"
 */
- (void) updateObjects:(Class)objClass whereStr:(NSString *)whereStr {
    //表名
    NSString * tableName = kTableName(objClass);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",tableName];
    
    [sql appendString:whereStr];
    
    [sql appendString:@";"];
    
    [self execSQL:sql msg:@"删除数据"];
}

@end
