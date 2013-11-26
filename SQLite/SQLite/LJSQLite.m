//
//  LJSQLite.m
//  SQLLift
//
//  Created by Jun on 13-  11- 24.
//  Copyright (c)2013年 Jun. All rights reserved.
//

#import "LJSQLite.h"

#import <sqlite3.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import "NSString+LJSQLite.h"
#import "NSObject+LJSQLite.h"
#import "NSDictionary+SQLite.h"

#define kFile(dbName) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[dbName stringByAppendingPathExtension:@"db"]]

#define kDateFmtStr @"yyyy-MM-dd hh:mm:ss"


@interface LJSQLite()
{
    sqlite3         * _db;
    
    //记录主键是否是自动增值的表格
    NSMutableSet    * _tablesAuto;
    //所有生成的表格
    NSMutableSet    * _tables;
}

@end

@implementation LJSQLite
_shared_implement(LJSQLite)

- (id)init {
    self = [super init];
    if (self){
        _tablesAuto = [NSMutableSet set];
        _tables = [NSMutableSet set];
        [self openDB];
    }
    return self;
}

/**
 *  创建或打开数据库
 *
 *  默认创建到沙盒中，并加.db后缀名
 *
 *  @param dbName 数据库的名字
 */
- (void)openDB {
    
//    NSLog(@"%@",kFile(dbName));
    _db = NULL;
    if(SQLITE_OK == sqlite3_open(kFile(kDBName).UTF8String, &_db)){
#ifdef kLOG
        NSLog(@"创建数据库成功");
#endif
    } else {
#ifdef kLOG
        NSLog(@"创建数据库失败");
#endif
    }
}
/**
 *  执行sql语句
 *
 *  @param sql sql语句
 *  @param msg 推送的消息
 */
- (void)execSQL:(NSString *)sql msg:(NSString *)msg {
    //3.在数据库中生成表格
    char *errmsg;
    if (SQLITE_OK == sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg)){
#ifdef kLOG
        NSLog(@"%@成功",msg);
#endif
    } else {
#ifdef kLOG
        NSLog(@"%@失败 - -  %s",msg,errmsg);
#endif
    }
    
#ifdef kLOG
    NSLog(@"%@",sql);
#endif
}
/**
 *  返回指定sql查询的结果集
 *
 *  @param sql      sql语句
 *  @param objClass 对象类
 *
 *  @return 结果集
 */
- (NSArray *)queryPersonsWithSql:(NSString *)sql objClass:(Class)objClass{
    sqlite3_stmt * stmt = NULL;
    //判断是否正常运行sql语句
    if (SQLITE_OK == sqlite3_prepare_v2(_db, sql.UTF8String, - 1, &stmt, NULL)){
        
        NSMutableArray * arrayM = [NSMutableArray array];
        
        //判断是否有下一条记录
        while(SQLITE_ROW == sqlite3_step(stmt)){
            
            NSObject * obj = [[objClass alloc]init];
            
            [objClass enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
                if([type hasPrefix:@"@"]){
                    if ([type rangeOfString:@"String"].length){
                        [obj setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, idx)] forKey:name];
                    } else if([type rangeOfString:@"Date"].length){
                        NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
                        [fmt setDateFormat:kDateFmtStr];
                        [obj setValue:[fmt dateFromString:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, idx)]]forKey:name];
                    } else if([type rangeOfString:@"Image"].length){
#warning image
                    } else { //模型对象 这里实现多表查询 表的嵌套关系
                        
                        //生成模型
                        Class subClass = NSClassFromString([type stringByReplacingClassName]);
                        NSValue * value = [NSNumber numberWithInteger:sqlite3_column_int(stmt, idx)];
                        if (value) {                            
                            //获取模型主键
                            NSString * primaryKey = [subClass primaryKeyName];
                            //获取对应的模型对象
                            NSObject * subObj = [self objectsWithObjClass:subClass params:@{primaryKey : value}];
                            [obj setValue:subObj forKey:name];
                        }
                    }
                    
                } else  { // 非对象类型
                    if ([type isEqualToString:@"d"]||[type isEqualToString:@"f"]){
                        [obj setValue:[NSNumber numberWithDouble:sqlite3_column_double(stmt, idx)] forKey:name];
                    }  else {
                        [obj setValue:[NSNumber numberWithInteger:sqlite3_column_int(stmt, idx)] forKey:name];
                    }
                }
            }];
            
            [arrayM addObject:obj];
        }
        
#ifdef kLOG
        NSLog(@"%@",sql);
#endif
        return arrayM;
    }
    
    return nil;
}


#pragma mark -  表格操作
/**
 *
 *  创建数据表
 *
 *  数据表名 ，默认在对象名前加上t_前缀并为小写 Person（对象名） - > t_person（生成表名）
 *
 *  默认含id的的属性名为主键，不分大小写
 *
 *  （注：只生成数据库里没有的表格）
 *
 *  @param objClassass 对象名
 */
#pragma mark -  生成表格
- (void)createTable:(Class)objClass autoincrement:(BOOL)autoincrement{
    //表名
    NSString * tableName = kTableName(objClass);
    if (autoincrement){
        [_tablesAuto addObject:tableName];
    }
    
    //判断死循环创建表格
    if ([_tables containsObject:tableName]){
        return;
    }
    [_tables addObject:tableName];
    
    NSMutableString * sql = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName];
    //判断是否有一个主键
    __block BOOL isPrimary = NO;
    
    
    [objClass enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {

        //2.判断属性
        if([type hasPrefix:@"@"]){
            if ([type rangeOfString:@"String"].length){
                [sql appendFormat:@"%@ text ",name];
            } else if([type rangeOfString:@"Date"].length){
                [sql appendFormat:@"%@ date ",name];
            } else if([type rangeOfString:@"Image"].length){
                [sql appendFormat:@"%@ blob ",name];
            } else {
                //截取类名 @"@"NSString""
                NSString * subName = [type stringByReplacingClassName];
                [self createTable:NSClassFromString(subName)autoincrement:YES];
                [sql appendFormat:@"%@_id integer",name];
            }

        } else  { // 非对象类型
            if ([type isEqualToString:@"d"]||[type isEqualToString:@"f"]){
                [sql appendFormat:@"%@ float ",name];
            }  else {
                [sql appendFormat:@"%@ integer ",name];
            }
        }

        //包含id字段为主键
        NSRange range = [name rangeOfString:@"id"];
        if ((range.length + range.location)== name.length && !isPrimary){
            [sql appendFormat:@"PRIMARY KEY %@ " , (autoincrement ? @"AUTOINCREMENT" : @"")];
            isPrimary = YES;
        }
        [sql appendString:@","];
    }];
    
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length -  1, 1)];
    [sql appendString:@");"];
    
    [self execSQL:sql msg:@"创建表格"];
    
#ifdef kLOG
    if (!isPrimary){
        NSLog(@"该对象的成员变量没有相应的ID");
    }
#endif
}

#pragma mark 删除表格
- (void)dropTable:(Class)objClass {
    //表名
    NSString * tableName = kTableName([objClass class]);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DROP TABLE  %@;",tableName];
    
    [self execSQL:sql msg:@"删除表格"];
    
}

#pragma mark -  数据操作
/**
 *  添加一个对象数据到相应表格中
 *
 *  @param obj 对象
 */
#pragma mark 添加一条数据
- (void)addObject:(NSObject *)obj {
    Class c = [obj class];
    //表名
    NSString * tableName = kTableName(c);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"INSERT INTO  %@ ( ",tableName];
    
    //元素
    NSMutableArray * elems = [NSMutableArray array];
    //属性
    NSMutableArray * types = [NSMutableArray array];
    
    
    [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
         
        
        //包含id为主键
        //这句话只要是判断是否是有主键并判断是否有自动增值
        //有自动增值属性可以省去添加主键的操作
        //若没有则按照对象中的主键添加
//        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        //        if ((range.length + range.location) != name.length || ![_tablesAuto containsObject:tableName]){
        
        NSString * primaryKeyName = [c primaryKeyName];
        if (![primaryKeyName isEqualToString:name]) {
            NSValue * value = [obj valueForKey:name];
            //参数为空不运行
            if (value){
                //拼接
                if([type hasPrefix:@"@"]){
                    //是否模型类
                    if (![type rangeOfString:@"String"].length && ![type rangeOfString:@"Date"].length && ![type rangeOfString:@"Image"].length) {
                        [sql appendFormat:@"%@_id ,",[name lowercaseString]];
                    } else {
                        [sql appendFormat:@"%@ ,",[name lowercaseString]];
                    }
                } else {
                    [sql appendFormat:@"%@ ,",[name lowercaseString]];
                }
                //参数
                [elems addObject:value];
                [types addObject:type];
            }
        }
    }];
    
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length -  1, 1)];
    [sql appendString:@")VALUES ( "];
    
    for (int i = 0; i<elems.count; i++){
        //2.判断属性
        NSString *type =types[i];
        if([type hasPrefix:@"@"]){
            if ([type rangeOfString:@"String"].length){
                [sql appendFormat:@"'%@' ,",elems[i]];
            } else if([type rangeOfString:@"Date"].length){
                NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
                [fmt setDateFormat:kDateFmtStr];
                [sql appendFormat:@"'%@' ,",[fmt stringFromDate:elems[i]]];
            } else if([type rangeOfString:@"Image"].length){
#warning 图片格式
//                [sql appendFormat:@"'%@' ,",[UIImagePNGRepresentation(elems[i])bytes]];
            } else {
                NSValue * value = nil;
                //在数据表中查询该数据
                if (![self isObject:elems[i]]){ //添加数据对象
                    [self addObject:elems[i]];
                    /* 这里有问题，假设添加子数据出错了，下面会查找到最后一条数据赋值 */
                    value = [[self lastObject:[elems[i] class]] primaryKey];
                } else {//查找数据对象
                    value = [[self objectsWithObjClass:[elems[i] class] params:[elems[i] params]][0] primaryKey];
                }
                [sql appendFormat:@"%@ ,",value];
            }
        } else  { // 非对象类型
            [sql appendFormat:@"%@ ,",elems[i]];
        }
    }
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length -  1, 1)];
    [sql appendString:@");"];
    
    [self execSQL:sql msg:@"添加一条数据"];
}
/**
 *  从相应的表格中删除一条对象数据
 *
 *  按对应的主键（id）删除数据
 *
 *  @param obj 对象
 */
#pragma mark 删除一条数据
- (void)deleteObject:(NSObject *)obj {
    Class c = [obj class];
    //表名
    NSString * tableName = kTableName(c);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ ",tableName];
//    [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
//        //包含id为主键
//        NSString * primaryKeyName = [c primaryKeyName];
//        if ([primaryKeyName isEqualToString:name]) {
//            //拼接
//            [sql appendFormat:@"%@ = %@",[name lowercaseString] ,[obj valueForKey:name]];
//            *stop = YES;
//        }
//    }];
    if([obj primaryKeyAndValue]) {
        [sql appendString:[[obj primaryKeyAndValue] stringByWhereSQLConversion]];
    }
    
    [self execSQL:sql msg:@"删除一条数据"];
}

/**
 *  从相应的表格中修改对象数据
 *
 *  按对应的主键（id）修改数据
 *
 *  @param obj 对象
 */
#pragma mark 更新数据
- (void)updateObject:(NSObject *)obj {
    Class c = [obj class];
    //表名
    NSString * tableName = kTableName(c);
    //update t_person set name = 'nimei',age = 12 , height = 1.8 where id = 0
    NSMutableString * sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",tableName];

    //存放id
//    __block NSString * ID;
//    __block NSString * IDValue;
    
    [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
        //包含id为主键
        NSString * primaryKeyName = [c primaryKeyName];
//        if ([primaryKeyName isEqualToString:name])
//        {
//            //拼接
//            ID = [name lowercaseString];
//            IDValue = [obj valueForKey:name];
//        }
//        else {
        if (![primaryKeyName isEqualToString:name]) {
            NSValue * value = [obj valueForKey:name];
            //判断是否有字符串
            if (value) {
                if([type hasPrefix:@"@"]){
                    if (![type rangeOfString:@"String"].length && ![type rangeOfString:@"Date"].length && ![type rangeOfString:@"Image"].length) {//模型对象
                        [sql appendFormat:@"%@_id = %@,",[name lowercaseString],[obj valueForKey:name]];
                    } else if([type rangeOfString:@"Date"].length) {//时间格式
                        NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
                        [fmt setDateFormat:kDateFmtStr];
                        [sql appendFormat:@"%@ = '%@' ,",[name lowercaseString],[fmt stringFromDate:(NSDate*)value]];
                    } else {//字符串
                        [sql appendFormat:@"%@ = '%@' ,",[name lowercaseString],value];
                    }
                } else{//数据类型
                    [sql appendFormat:@"%@ = %@ ,",[name lowercaseString],value];
                }
            }
        }
    }];
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length -  1, 1)];
    
//    if (ID){
//    [sql appendFormat:@" WHERE %@ = %@;",ID,IDValue];
//    }
    if ([obj primaryKeyAndValue]) {
        [sql appendString:[[obj primaryKeyAndValue] stringByWhereSQLConversion]];
    }

    [self execSQL:sql msg:@"更新一条数据"];
}

/**
 *  查询相应类的表格的所有数据
 *
 *  @param objClass 对应的对象
 */
#pragma mark 查询表格
- (NSArray *)allObjects:(Class)objClass {
//    NSString * tableName = kTableName(objClass);
    //sql语句
//    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ;",tableName];
    
//    return [self queryPersonsWithSql:sql objClass:objClass];
    return [self objectsWithObjClass:objClass params:nil];
}

/**
 *  判断该对象数据是否存在对应数据表中
 *
 *  该判定按照对象中的 isEqual: 方法来判定
 *  （注：建议重写isEqual: 方法）
 *
 *  @param obj 对象
 *
 *  @return YES:存在  NO:不存在
 */
- (BOOL)isObject:(NSObject *)obj {
    Class c = [obj class];
//    return [[self allObjects:c] containsObject:obj];
    return [self objectsWithObjClass:c params:[obj params]].count;
}

/**
 *  从对应数据表中获取最后一个对象，性能有问题，不建议使用
 *
 *  @param objClass 对象类
 *
 *  @return 返回最后一个对象
 */
- (id)lastObject:(Class)objClass {
    return [self allObjects:objClass].lastObject;
}

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
- (NSArray *)objectsWithObjClass:(Class)objClass params:(NSDictionary *)params {
    //表名
    NSString * tableName = kTableName(objClass);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    if (params) {
        NSMutableString * where = [NSMutableString stringWithString:@" WHERE "];
        __block BOOL isWhere = NO;
        [objClass enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
            
            NSValue * value = params[name];
            if(value) {
                //包含id为主键
                NSString * primaryKeyName = [objClass primaryKeyName];
                if ([primaryKeyName isEqualToString:name]) {
                    if (![value isEqualToValue:@0]) {
                        [where appendFormat:@" %@ = %@ and",name,value];
                        isWhere = YES;
                    }
                } else {
                    if ([value isKindOfClass:[NSString class]]) {
                        [where appendFormat:@" %@ = '%@' and",name,value];
                    } else {
                        [where appendFormat:@" %@ = %@ and",name,value];
                    }
                    isWhere = YES;
                }
            }
        }];
        if (isWhere) {
            //去除最后and
            [where deleteCharactersInRange:NSMakeRange(where.length - 3, 3)];
        }
        [sql appendFormat:@"%@",where];
    }
    [sql appendString:@";"];
    
    return [self queryPersonsWithSql:sql objClass:objClass];
}
@end
