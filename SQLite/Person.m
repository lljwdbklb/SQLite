//
//  Person.m
//  SQLLift
//
//  Created by Jun on 13-11-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "Person.h"

@implementation Person
-(NSString *)description {
    return [NSString stringWithFormat:@"<Person: %p , id: %d , name: %@ , age: %d ,height: %g >",self,self.p_id,self.name,self.age,self.height];
}
@end
