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
    
    [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
        //包含id为主键
        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        if ((range.length + range.location)== name.length){
            value = [self valueForKey:name];
            *stop = YES;
        }
    }];
    
    return value;
}
/**
 *  获取当前对象中的主键名和对应参数
 *
 *  @return key主键名 value对应参数
 */
- (NSDictionary *)primaryKeyAndValue {
//    Class c = [self class];
    NSDictionary * primary = nil;
//    [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
//        //包含id为主键
//        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
//        if ((range.length + range.location)== name.length){
//            primary = @{name : [self valueForKey:name]};
//            *stop = YES;
//        }
//    }];
    NSString * name = [self primaryKeyName];
    NSValue * value = [self valueForKey:name];
    if (value && ![value isEqualToValue:@0]) {
        primary = @{name:value};
    }
    
    return primary;
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
        //去下划线
        name = [name substringFromIndex:1];
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
        NSValue * value = [self valueForKey:name];
        if (value) {
            NSString* primaryKeyName = [self primaryKeyName];
            if ([primaryKeyName isEqualToString:name]) {
                if(![value isEqualToValue:@0]) {
                    [params setObject:value forKey:name];
                }
            }else {
                [params setObject:value forKey:name];
            }
        }
    }];
    return params;
}

- (NSString *)primaryKeyName {
    return [[self class] primaryKeyName];
}
/**
 *  获取类中主键名
 *
 *  主键的判断是，要不是id为名，或后缀名_id
 *  如：ID 或 p_id、b_id.....
 *
 *  @return 返回主键
 */
+(NSString *)primaryKeyName {
    __block NSString * primaryKeyName = nil;
    if (primaryKeyName == nil) {
        Class c = [self class];
        [c enumerateIvarNamesUsingBlock:^(NSString *name, NSString *type, int idx, BOOL *stop) {
            NSString * lowerName = [name lowercaseString];
            //包含id为主键
            NSRange range = [lowerName rangeOfString:@"_id"];
//            if ((range.length + range.location)== name.length){
            if([lowerName isEqualToString:@"id"] || (range.length + range.location) == lowerName.length) {
                primaryKeyName = name;
                *stop = YES;
            }
        }];
    }
    return primaryKeyName;
}
@end
