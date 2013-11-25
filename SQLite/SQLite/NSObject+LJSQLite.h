//
//  NSObject+LJSQLite.h
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LJSQLite)
/**
 *  获取当前对象中的主键值
 *
 *
 *  @return 返回对象主键值
 */
- (id)primaryKey;
@end
