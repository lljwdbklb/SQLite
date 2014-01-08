//
//  LJSQLite+Where.h
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "LJSQLite.h"



@interface LJSQLite (Where)
/**
 *  删除对应数据表的对象数据
 *
 *  @param objClass     对象类
 *  @param params       查找条件 key：成员变量名 value：查询数据  如：@"name" : @"adf"
 *                  where name = @"adf" and ...;
 */
- (void)deleteObjects:(Class)objClass whereParams:(NSDictionary *)params;

/**
 *  删除对应数据表的对象数据
 *
 *  @param objClass 对象类
 *  @param whereStr 判断字符串  例如：@"name = 'bac' and age = 12 or height > 1.1 and height < 5"
 */
- (void)deleteObjects:(Class)objClass whereStr:(NSString *)whereStr;
@end
