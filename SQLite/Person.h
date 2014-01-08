//
//  Person.h
//  SQLLift
//
//  Created by Jun on 13-11-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Book;
@interface Person : NSObject

@property (nonatomic,assign)    int         p_id;

@property (nonatomic,strong)    NSString    * name;

@property (nonatomic,assign)    int         age;

@property (nonatomic,assign)    double      height;

@property (nonatomic,strong)    NSDate      * time;

@property (nonatomic,strong)    Book        * book;
@end
