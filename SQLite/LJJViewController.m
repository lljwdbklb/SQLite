//
//  LJJViewController.m
//  SQLite
//
//  Created by Jun on 13-11-24.
//  Copyright (c) 2013年 Jun. All rights reserved.
//

#import "LJJViewController.h"
#import "LJSQLite.h"
#import "Person.h"

@interface LJJViewController ()

@end

/**
 *  在SQLite.h 设置数据库名
 */

@implementation LJJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

#pragma mark 常见表格
-(IBAction)createTable {
    [[LJSQLite sharedLJSQLite] createTable:[Person class] autoincrement:YES];
}

@end
