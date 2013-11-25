//
//  NSString+LJSQLite.m
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "NSString+LJSQLite.h"

@implementation NSString (LJSQLite)
- (NSString *) stringByReplacingClassName {
    NSRange range = [self rangeOfString:@"@\""];
    NSString * subName = [self stringByReplacingCharactersInRange:range withString:@""];
    return [subName substringWithRange:NSMakeRange(0, subName.length - 1)];
}
@end
