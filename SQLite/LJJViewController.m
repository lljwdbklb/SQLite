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
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *height;

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
#pragma mark 添加一条数据
- (IBAction)addData {
    Person * p = [[Person alloc]init];
    p.name = _name.text;
    p.age = [_age.text integerValue];
    p.height = [_height.text doubleValue];
    [[LJSQLite sharedLJSQLite]addObject:p];
}

@end
