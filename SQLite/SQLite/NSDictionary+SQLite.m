//
//  NSDictionary+SQLite.m
//  SQLite
//
//  Created by Jun on 13-11-26.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "NSDictionary+SQLite.h"

@implementation NSDictionary (SQLite)
/**
 *  对字典参数进行拼接成Where语句
 *
 *  @return 返回Where语句
 */
- (NSString *)stringByWhereSQLConversion {
    //拼接where语句
    NSMutableString * whereStr = [NSMutableString stringWithString:@" WHERE "];
    NSArray * array = [self allKeys];
    for (NSString * name in array) {
        NSValue * value = self[name];
        if ([value isKindOfClass:[NSString class]]) {
            [whereStr appendFormat:@" %@ = '%@' and",[name lowercaseString],value];
        } else {
            [whereStr appendFormat:@" %@ = %@ and",[name lowercaseString],value];
        }
    }
    //去除最后and
    [whereStr deleteCharactersInRange:NSMakeRange(whereStr.length - 3, 3)];
    return whereStr;
}
@end
