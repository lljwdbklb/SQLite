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
    NSValue * value = nil;
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(c, &outCount);
    
    for (int i = 0; i<outCount; i++){
        Ivar ivar = ivars[i];
        // 1.属性名
        NSString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)] ;
        
        //包含id为主键
        NSRange range = [[name lowercaseString] rangeOfString:@"id"];
        if ((range.length + range.location)== name.length){
            //去下划线
            name = [name substringFromIndex:1];
            value = [name valueForKey:name];
            break;
        }
    }
    return value;
}
@end
