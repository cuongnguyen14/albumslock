//
//  PLLeftMenuTableViewController.m
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLLeftMenuTableViewController.h"
#import "PLLeftMenuItem.h"
#import "PLLeftMenuTableViewCell.h"

@interface PLLeftMenuTableViewController ()

@property (nonatomic) NSMutableArray *data;

@end

@implementation PLLeftMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PLLeftMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"ReusedCell"];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(50, 0, 0, 10)];
}

-(void)initData {
    self.data = [NSMutableArray new];
    
    PLLeftMenuItem *categories = [[PLLeftMenuItem alloc] initWithIconName:@"categories" title:@"CATEGORIES"];
    PLLeftMenuItem *account = [[PLLeftMenuItem alloc] initWithIconName:@"account" title:@"ACCOUNT MANAGER"];
    PLLeftMenuItem *note = [[PLLeftMenuItem alloc] initWithIconName:@"notes" title:@"NOTE MANAGER"];
    PLLeftMenuItem *browser = [[PLLeftMenuItem alloc] initWithIconName:@"browser-icon" title:@"PRIVATE BROWSER"];
    PLLeftMenuItem *setting = [[PLLeftMenuItem alloc] initWithIconName:@"setting" title:@"SETTINGS"];
    
    [self.data addObjectsFromArray:@[categories, account, note, browser, setting]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PLLeftMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReusedCell"];
    PLLeftMenuItem *model = [self.data objectAtIndex:indexPath.row];
    [cell displayWithModel:model];
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 38)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, self.tableView.bounds.size.width - 25, 38)];
    label.text = @"DRAWERS";
    [view addSubview:label];
    label.textColor = MakeColor(255, 26, 85, 1);
    view.backgroundColor = MakeColor(241, 242, 242, 1);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(PLLeftMenuViewController:didSelectMenuType:)]) {
        [self.delegate PLLeftMenuViewController:self didSelectMenuType:indexPath.row];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
