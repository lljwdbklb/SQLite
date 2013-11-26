//
//  NSObject+LJSQLite.h
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IvarNamesUsingBlock)(NSString * name,NSString * type,int idx,BOOL *stop);

@interface NSObject (LJSQLite)
/**
 *  获取当前对象中的主键值
 *
 *
 *  @return 返回对象主键值
 */
- (id)primaryKey NS_DEPRECATED_IOS(6_0, 7_0, "有更新的 NSObject primaryKeyAndValue");
/**
 *  获取当前对象中的主键名和对应参数
 *
 *  @return key主键名 value对应参数
 */
- (NSDictionary *)primaryKeyAndValue ;

/**
 *  获取类/对象中成员变量主键名
 *
 *  主键的判断是，要不是id为名，或后缀名_id
 *  如：ID 或 p_id、b_id.....
 *
 *  @return 返回主键
 */
- (NSString *)primaryKeyName;
+ (NSString *)primaryKeyName;
//在分类中不能添加成员变量
//@property (nonatomic,strong,readonly) NSString * primaryKeyName;

/**
 *  遍历类的所有成员变量
 *
 *  @param block 遍历block ，成员遍历名、数据类型名、位置、是否暂停，默认为no
 */
+ (void)enumerateIvarNamesUsingBlock:(IvarNamesUsingBlock)block;

/**
 *  获取当前对象的成员变量名与对应的参数
 *
 *  @return 返回字典 key成员变量名 value参数
 */
- (NSDictionary *)params;
@end
