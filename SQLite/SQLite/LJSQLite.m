//
//  LJSQLite.m
//  SQLLift
//
//  Created by Jun on 13-11-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "LJSQLite.h"
#import <sqlite3.h>
#import <objc/message.h>
#import <objc/runtime.h>

#define kFile(dbName) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:[dbName stringByAppendingPathExtension:@"db"]]

#define kTableName(objClass) [NSString stringWithFormat:@"t_%@",[NSStringFromClass(objClass) lowercaseString]]

@interface LJSQLite()
{
    sqlite3         * _db;
    
    //记录主键是否是自动增值的表格
    NSMutableSet    * _tablesAuto;
}

@end

@implementation LJSQLite
_shared_implement(LJSQLite)

-(id)init {
    self = [super init];
    if (self) {
        _tablesAuto = [NSMutableSet set];
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
-(void)openDB {
    
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
-(void)execSQL:(NSString *)sql msg:(NSString *)msg {
    //3.在数据库中生成表格
    char *errmsg;
    if (SQLITE_OK == sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg)){
#ifdef kLOG
        NSLog(@"%@成功",msg);
#endif
    } else {
#ifdef kLOG
        NSLog(@"%@失败 -- %s",msg,errmsg);
#endif
    }
    
#ifdef kLOG
    NSLog(@"%@",sql);
#endif
}

-(NSArray *)queryPersonsWithSql:(NSString *)sql objClass:(Class)objClass{
    sqlite3_stmt * stmt = NULL;
    //判断是否正常运行sql语句
    if (SQLITE_OK == sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL)) {
        
        NSMutableArray * arrayM = [NSMutableArray array];
        
        unsigned int outCount = 0;
        Ivar *ivars = class_copyIvarList(objClass, &outCount);
        
        //判断是否有下一条记录
        while(SQLITE_ROW == sqlite3_step(stmt)) {
            
            NSObject * obj = [[objClass alloc]init];
            
            for (int i = 0; i<outCount; i++) {
                Ivar ivar = ivars[i];
                
                // 1.属性名
                NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)];
                //去下划线
                name = [name substringFromIndex:1];
                
                //2.属性
                NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
                
                if([type hasPrefix:@"@"]) {
                    if ([type rangeOfString:@"String"].length) {
                        [obj setValue:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)] forKey:name];
                    } else if([type rangeOfString:@"Date"].length) {
                    } else if([type rangeOfString:@"Image"].length) {
                    }
                    
                } else  { // 非对象类型
                    if ([type isEqualToString:@"d"]||[type isEqualToString:@"f"]) {
                        [obj setValue:[NSNumber numberWithDouble:sqlite3_column_double(stmt, i)] forKey:name];
                    }  else {
                        [obj setValue:[NSNumber numberWithInteger:sqlite3_column_int(stmt, i)] forKey:name];
                    }
                }
            }
            
            [arrayM addObject:obj];
        }
        
        return arrayM;
    }
    
    return nil;
}


#pragma mark - 表格操作
/**
 *
 *  创建数据表
 *
 *  数据表名 ，默认在对象名前加上t_前缀并为小写 Person（对象名） -> t_person（生成表名）
 *
 *  默认含id的的属性名为主键，不分大小写
 *
 *  （注：只生成数据库里没有的表格）
 *
 *  @param objClassass 对象名
 */
#pragma mark - 生成表格
-(void)createTable:(Class)objClass autoincrement:(BOOL)autoincrement{
    //表名
    NSString * tableName = kTableName(objClass);
    if (autoincrement) {
        [_tablesAuto addObject:tableName];
    }
    
    NSMutableString * sql = [NSMutableString stringWithFormat:@"CREATE TABLE  %@ (",tableName];
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(objClass, &outCount);
    //判断是否有一个主键
    BOOL isPrimary = NO;
    
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        
        // 1.参数名
        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)];
        //去下划线
        name = [[name substringFromIndex:1] lowercaseString];
        //拼接
        [sql appendFormat:@"%@ ",name];
        
        //2.判断属性
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if([type hasPrefix:@"@"]) {
            if ([type rangeOfString:@"String"].length) {
                [sql appendFormat:@"text "];
            } else if([type rangeOfString:@"Date"].length) {
                [sql appendString:@"date "];
            } else if([type rangeOfString:@"Image"].length) {
                [sql appendString:@"blob "];
            }
            
        } else  { // 非对象类型
            if ([type isEqualToString:@"d"]||[type isEqualToString:@"f"]) {
                [sql appendFormat:@"float "];
            }  else {
                [sql appendFormat:@"integer "];
            }
        }
        
        //包含id字段为主键
        NSRange range = [name rangeOfString:@"id"];
        if ((range.length + range.location) == name.length && !isPrimary) {
            [sql appendFormat:@"PRIMARY KEY %@ " , (autoincrement ? @"AUTOINCREMENT" : @"")];
            isPrimary = YES;
        }
        [sql appendString:@","];
    }
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@");"];
    
    [self execSQL:sql msg:@"创建表格"];
    
#ifdef kLOG
    if (!isPrimary) {
        NSLog(@"该对象的成员变量没有相应的ID");
    }
#endif
}

#pragma mark 删除表格
-(void)dropTable:(Class)objClass {
    //表名
    NSString * tableName = kTableName([objClass class]);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DROP TABLE  %@;",tableName];
    
    [self execSQL:sql msg:@"删除表格"];
    

}

#pragma mark - 数据操作
/**
 *  添加一个对象数据到相应表格中
 *
 *  @param obj 对象
 */
#pragma mark 添加一条数据
-(void)addObject:(NSObject *)obj {
    Class c = [obj class];
    //表名
    NSString * tableName = kTableName(c);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"INSERT INTO  %@ (",tableName];
    
    NSMutableArray * elems = [NSMutableArray array];
    NSMutableArray * types = [NSMutableArray array];
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(c, &outCount);
    
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        
        // 1.属性名
        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)];
        //去下划线
        name = [name substringFromIndex:1];
        
        //包含id为主键
        //这句话只要是判断是否是有主键并判断是否有自动增值
        //有自动增值属性可以省去添加主键的操作
        //若没有则按照对象中的主键添加
        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        if ((range.length + range.location) == name.length && [_tablesAuto containsObject:tableName]) {
            continue;
        }
        
        //拼接
        [sql appendFormat:@"%@ ,",[name lowercaseString]];
        //参数
        [elems addObject:[obj valueForKey:name]];
        
        //2.属性
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        [types addObject:type];
        
    }
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@") VALUES ( "];
    
    for (int i = 0; i<elems.count; i++) {
        //2.判断属性
        NSString *type =types[i];
        if([type hasPrefix:@"@"]) {
            [sql appendFormat:@"'%@' ,",elems[i]];
        } else  { // 非对象类型
            [sql appendFormat:@"%@ ,",elems[i]];
        }
    }
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@"); "];
    
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
-(void)deleteObject:(NSObject *)obj {
    Class c = [obj class];
    //表名
    NSString * tableName = kTableName(c);
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE ",tableName];
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(c, &outCount);
    
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        // 1.属性名
        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)] ;
        
        //包含id为主键
        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        if ((range.length + range.location) == name.length) {
            //去下划线
            name = [name substringFromIndex:1];
            //拼接
            [sql appendFormat:@"%@ = %@",[name lowercaseString] ,[obj valueForKey:name]];
            break;
        }
        
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
-(void)updateObject:(NSObject *)obj {
    Class c = [obj class];
    //表名
    NSString * tableName = kTableName(c);
    //update t_person set name = 'nimei',age = 12 , height = 1.8 where id = 0
    NSMutableString * sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",tableName];

    //存放id
    NSString * ID;
    NSString * IDValue;
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(c, &outCount);
    
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        // 1.属性名
        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)] ;
        //去下划线
        name = [name substringFromIndex:1];
        
        //包含id为主键
        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        
        if ((range.length + range.location) == name.length) {
            //拼接
            ID = [name lowercaseString];
            IDValue = [obj valueForKey:name];
            continue;
        }
        
        //判断是否有字符串
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if([type hasPrefix:@"@"]) {
            [sql appendFormat:@"%@ = '%@' ,",[name lowercaseString],[obj valueForKey:name]];
        } else{
            [sql appendFormat:@"%@ = %@ ,",[name lowercaseString],[obj valueForKey:name]];
        }
        
    }
    //去除最后的逗号
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    
    if (ID) {
        [sql appendFormat:@" WHERE %@ = %@;",ID,IDValue];
    }

    [self execSQL:sql msg:@"更新一条数据"];
}

/**
 *  查询相应类的表格的所有数据
 *
 *  @param objClass 对应的对象
 */
#pragma mark 查询表格
-(NSArray *)allObjects:(Class)objClass {
    NSString * tableName = kTableName(objClass);
    //sql语句
    NSMutableString * sql = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ;",tableName];
    
    return [self queryPersonsWithSql:sql objClass:objClass];
}

@end
