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
    NSArray * _dataList;
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
//查询
@property (weak, nonatomic) IBOutlet UITableView *tableview;


@end

/**
 *  在SQLite.h 设置数据库名
 */

@implementation LJJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    _dataList = [NSArray array];

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
- (IBAction)selectDatas:(id)sender {
    _dataList = [[LJSQLite sharedLJSQLite] allObjects:[Person class]];
    [_tableview reloadData];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Person * person = _dataList[indexPath.row];
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = [@(person.age) description];
    
    return cell;
}

@end
