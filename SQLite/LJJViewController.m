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

@interface LJJViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
}

//添加操作
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *height;
//删除操作
@property (weak, nonatomic) IBOutlet UITextField *ID;
//更新操作
@property (weak, nonatomic) IBOutlet UITextField *uID;
@property (weak, nonatomic) IBOutlet UITextField *uName;
@property (weak, nonatomic) IBOutlet UITextField *uAge;
@property (weak, nonatomic) IBOutlet UITextField *uHeight;
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

- (IBAction)deleteObj:(id)sender {
    Person * p = [[Person alloc]init];
    p.p_id = [_ID.text integerValue];
    [[LJSQLite sharedLJSQLite]deleteObject:p];
}

- (IBAction)updateObj {
    Person * p = [[Person alloc]init];
    p.p_id = [_uID.text integerValue];
    p.name = _uName.text;
    p.age = [_uAge.text integerValue];
    p.height = [_uHeight.text doubleValue];
    [[LJSQLite sharedLJSQLite] updateObject:p];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
