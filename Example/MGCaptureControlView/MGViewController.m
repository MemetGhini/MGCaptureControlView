//
//  MGViewController.m
//  MGCaptureControlView
//
//  Created by memetghini@qq.com on 06/13/2018.
//  Copyright (c) 2018 memetghini@qq.com. All rights reserved.
//

#import "MGViewController.h"
#import "MGCaptureDemoViewController.h"

@interface MGViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_dataArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    //data
    _dataArray = @[@"Wechat",@"QQ",@"Custom"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //Demo
    MGCaptureDemoViewController *demoVC = [[MGCaptureDemoViewController alloc] initWith:_dataArray[indexPath.row]];
    [self presentViewController:demoVC animated:YES completion:^{
        
    }];
}

@end
