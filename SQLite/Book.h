//
//  Book.h
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Person;
@interface Book : NSObject
@property (nonatomic,assign)    int         b_id;
@property (nonatomic,strong)    NSString    * name;
//@property (nonatomic,assign)    Person      * author;
@end
