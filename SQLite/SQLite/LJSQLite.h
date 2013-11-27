//
//  LJSQLite.h
//  SQLLift
//
//  Created by Jun on 13-11-24.
//  Copyright (c)2013年 Jun. All rights reserved.
//
//  SQLite 封装
//

#import <Foundation/Foundation.h>
#import "Simple.h"

#ifdef DEBUG
#define kLOG
#endif



#define kTableName(objClass) [NSString stringWithFormat:@"t_%@",[NSStringFromClass(objClass)lowercaseString]]

//不用后缀名，数据库名即可
#define kDBName         @"ljj"

#define kOrderByASC     @"ASC"
#define kOrderByDESC    @"ASC"

@interface LJSQLite : NSObject
_shared_interface(LJSQLite)

/**
 *  创建或打开数据库
 *
 *  默认创建到沙盒中，并加.db后缀名
 *  默认调用
 *
 *  @param dbName 数据库的名字
 */
//- (void)openDB:(NSString *)dbName;

/**
 *  执行sql语句
 *
 *  @param sql sql语句
 *  @param msg 推送的消息
 */
- (void)execSQL:(NSString *)sql msg:(NSString *)msg;

/**
 *
 *  创建数据表
 *
 *  数据表名 ，默认在对象名前加上t_前缀并为小写 Person（对象名） - > t_person（生成表名）
 *
 *  默认含id的的属性名为主键,不分大小写
 *
 *  （注：只生成数据库里没有的表格）
 *
 *  @param objClass         对象类
 *  @param autoincrement    主键自动增值属性，默认为NO
 *
 */
- (void)createTable:(Class)objClass autoincrement:(BOOL)autoincrement;

/**
 *  删除对象对应表格
 *
 *  @param objClass 对象类
 */
- (void)dropTable:(Class)objClass;

/**
 *  添加一个对象数据到相应表格中
 *
 *  @param obj 对象
 */
- (void)addObject:(NSObject *)obj;

/**
 *  从相应的表格中删除一条对象数据
 *
 *  按对应的主键（id）删除数据
 *
 *  @param obj 对象
 */
- (void)deleteObject:(NSObject *)obj;

/**
 *  从相应的表格中修改属性
 *
 *  按对应的主键（id）修改数据
 *
 *  @param obj 对象
 */
- (void)updateObject:(NSObject *)obj;

/**
 *  查询相应类的表格的所有数据
 *
 *  @param objClass 对象类
 */
- (NSArray *)allObjects:(Class)objClass;

/**
 *  返回指定sql查询的结果集
 *
 *  @param sql      sql语句
 *  @param objClass 对象类
 *
 *  @return 结果集
 */
- (NSArray *)queryPersonsWithSql:(NSString *)sql objClass:(Class)objClass;

/**
 *  判断该对象数据是否存在对应数据表中
 *
 *  @param obj 对象
 *
 *  @return YES:存在  NO:不存在
 */
- (BOOL)isObject:(NSObject *)obj;

/**
 *  从对应的数据表中查找相应记录
 *
 *  @param objClass 对象名
 *  @param params   参数名 , 参数为空 返回所有表中对象
 *                  key：成员变量名 value：查询数据  如：@"name" : @"adf"
 *                  where name = @"adf" and ...;
 *
 *  @return 返回的对象
 */
- (NSArray *)objectsWithObjClass:(Class)objClass params:(NSDictionary *)params NS_DEPRECATED_IOS(6_0, 7_0, "有更新的 - objectsWithObjClass:whereParams:limit:count:");

/**
 *  从对应的数据表中查找相应记录
 *
 *  @param objClass 对象名
 *  @param whereStr where语句  where name = @"adf" and ... or ...
 *  @param orderBy  需要排序的字段 ，key该成员变量名，value 为 kOrderByASC 或者 kOrderByDESC
 *  @param limit    结果范围，{当前位置（页数*长度），长度}。（用于分页）
 长度为0，则返回全部数据
 *  @param count    返回长度，发送为0 则无数据
 *
 *  @return 结果集
 */
- (NSArray *)objectsWithObjClass:(Class)objClass whereStr:(NSString *)whereStr orderBy:(NSDictionary *)orderBy limit:(NSRange)limit count:(int *)count;
/**
 *  从对应的数据表中查找相应记录
 *
 *  @param objClass 对象名
 *  @param params   参数名 , 参数为空 返回所有表中对象
 *                  key：成员变量名 value：查询数据  如：@"name" : @"adf"
 *                  where name = @"adf" and ...;
 *
 *  @param orderBy  需要排序的字段 ，key该成员变量名，value 为 kOrderByASC 或者 kOrderByDESC
 *  @param limit    结果范围，{当前位置（页数*长度），长度}。（用于分页）
 长度为0，则返回全部数据
 *  @param count    返回长度，发送为0 则无数据
 *
 *  @return 结果集
 */
- (NSArray *)objectsWithObjClass:(Class)objClass whereParams:(NSDictionary *)params orderBy:(NSDictionary *)orderBy limit:(NSRange)limit count:(int *)count;

/**
 *  从对应的数据表中查找相应记录
 *
 *  @param objClass 对象名
 *  @param params   参数名 , 参数为空 返回所有表中对象
 *                  key：成员变量名 value：查询数据  如：@"name" : @"adf"
 *                  where name = @"adf" and ...;
 *
 *  @param limit    结果范围，{当前位置（页数*长度），长度}。（用于分页）
 长度为0，则返回全部数据
 *  @param count    返回长度，发送为0 则无数据
 *
 *  @return 结果集
 */
- (NSArray *)objectsWithObjClass:(Class)objClass whereParams:(NSDictionary *)params limit:(NSRange)limit count:(int *)count;
@end
