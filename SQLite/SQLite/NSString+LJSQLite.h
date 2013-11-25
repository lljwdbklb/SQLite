//
//  NSString+LJSQLite.h
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LJSQLite)
/**
 *  自动截取对象类名
 *  @"\@"NSString"" -> @"NSString"
 *  @return 返回对象类名
 */
- (NSString *) stringByReplacingClassName;
@end
