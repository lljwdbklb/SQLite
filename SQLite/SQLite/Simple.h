//
//  Simple.h
//  WeiBo
//
//  Created by Jun on 13-11-1.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#ifndef WeiBo_Simple_h
#define WeiBo_Simple_h

#define _shared_interface(class) +(class *)shared##class;

#define _shared_implement(class)\
static class * instance;\
+(id)allocWithZone:(struct _NSZone *)zone {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        instance = [super allocWithZone:zone];\
    });\
return instance;\
}\
\
+(class *)shared##class {\
    if (instance == nil) {\
        instance = [[class alloc]init];\
    }\
    return instance;\
}


#endif
