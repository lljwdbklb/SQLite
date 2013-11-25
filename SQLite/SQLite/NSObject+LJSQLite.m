//
//  NSObject+LJSQLite.m
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "NSObject+LJSQLite.h"
#import <objc/message.h>
#import <objc/runtime.h>
@implementation NSObject (LJSQLite)
/**
 *  获取当前对象中的主键值
 *
 *
 *  @return 返回对象主键值
 */
- (id)primaryKey {
    Class c = [self class];
    __block NSValue * value = nil;
    
//    unsigned int outCount = 0;
//    Ivar *ivars = class_copyIvarList(c, &outCount);
//
//    for (int i = 0; i<outCount; i++){
//        Ivar ivar = ivars[i];
//        // 1.属性名
//        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)] ;
//        
//        //包含id为主键
//        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
//        if ((range.length + range.location)== name.length){
//            //去下划线
//            name = [name substringFromIndex:1];
//            value = [name valueForKey:name];
//            break;
//        }
//    }
    
    [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
        //包含id为主键
        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        if ((range.length + range.location)== name.length){
            //去下划线
            name = [name substringFromIndex:1];
            value = [self valueForKey:name];
            *stop = YES;
        }
    }];
    
    return value;
}
/**
 *  遍历类的所有成员变量
 *
 *  @param block 遍历block ，成员遍历名、数据类型名、位置、是否暂停，默认为no
 */
+ (void)enumerateIvarNamesUsingBlock:(IvarNamesUsingBlock)block {
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(self, &outCount);
    
    for (int i = 0; i<outCount; i++){
        Ivar ivar = ivars[i];
        // 1.属性名
        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)] ;
        //2.数据类型
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        BOOL stop = NO;
        if (block) {
            block(name,type,i,&stop);
        }
        
        if (stop) {
            break;
        }
        
    }
}


- (NSDictionary *)params {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [[self class] enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
        //去下划线
        name = [name substringFromIndex:1];
        NSValue * value = [self valueForKey:name];
        if (value) {
            [params setObject:value forKey:name];
        }
    }];
    return params;
}
@end
