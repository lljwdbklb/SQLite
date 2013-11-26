//
//  NSDictionary+SQLite.h
//  SQLite
//
//  Created by Jun on 13-11-26.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SQLite)
/**
 *  对字典参数进行拼接成Where语句
 *
 *  @return 返回Where语句
 */
- (NSString *)stringByWhereSQLConversion;
@end
