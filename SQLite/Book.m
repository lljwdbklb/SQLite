//
//  Book.m
//  SQLite
//
//  Created by Jun on 13-11-25.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "Book.h"

@implementation Book
-(BOOL)isEqual:(id)object {
    Book * b = object;
    if (b.b_id == self.b_id) {
        return YES;
    } else if([b.name isEqualToString:self.name]) {
        return YES;
    }
    return NO;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<Book: %p , b_id: %d , name: %@>",self,self.b_id,self.name];
}
@end
