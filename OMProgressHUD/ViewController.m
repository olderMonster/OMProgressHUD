//
//  ViewController.m
//  OMProgressHUD
//
//  Created by 印聪 on 2018/10/2.
//  Copyright © 2018年 tima. All rights reserved.
//

#import "ViewController.h"

#import "OMProgressHUD/OMProgressConfig.h"
#import "OMProgressHUD.h"

@interface ViewController ()<UITableViewDataSource , UITableViewDelegate>

@property (nonatomic , strong)UITableView *tableView;

@property (nonatomic , strong)NSArray <NSString *>*array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    
    [OMProgressConfig sharedInstance].loadingContentSize = CGSizeMake(120, 120);
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
    
}


#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.array[indexPath.row];
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [OMProgressHUD show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [OMProgressHUD dismiss];
        });
    }
    
    if (indexPath.row == 1) {
        [OMProgressConfig sharedInstance].loadImage = [UIImage imageNamed:@"loading"];
        [OMProgressHUD showImageLoading];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [OMProgressHUD dismiss];
        });
    }
    
    if (indexPath.row == 2) {
        [OMProgressConfig sharedInstance].toastPosition = OMToastVerticalPositionCenter;
        [OMProgressHUD show:@"单行文本"];
    }
    
    if (indexPath.row == 3) {
        [OMProgressConfig sharedInstance].toastPosition = OMToastVerticalPositionTop;
        [OMProgressHUD show:@"单行文本"];
    }
    
    if (indexPath.row == 4) {
        [OMProgressConfig sharedInstance].toastPosition = OMToastVerticalPositionBottom;
        [OMProgressHUD show:@"单行文本"];
    }
    
    if (indexPath.row == 5) {
        [OMProgressConfig sharedInstance].toastPosition = OMToastVerticalPositionCenter;
        [OMProgressHUD show:@"多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本"];
    }
    
    if (indexPath.row == 6) {
        [OMProgressConfig sharedInstance].toastPosition = OMToastVerticalPositionTop;
        [OMProgressHUD show:@"多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本"];
    }
    
    if (indexPath.row == 7) {
        [OMProgressConfig sharedInstance].toastPosition = OMToastVerticalPositionBottom;
        [OMProgressHUD show:@"多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本|多行文本"];
    }
    
    if (indexPath.row == 8) {
        [OMProgressHUD show:@"请求成功请求" image:[UIImage imageNamed:@"icon_success1"] imageSize:CGSizeMake(46, 46)];
    }
    
}


#pragma mark -- getters and setters
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSArray <NSString *>*)array{
    if (_array == nil) {
        _array = @[@"环形进度条加载样式",
                   @"显示加载样式(自定义图片),底部文本默认为“加载中...”",
                   @"toast(单行文本居中)",
                   @"toast(单行文本居上)",
                   @"toast(单行文本居下)",
                   @"toast(多行文本居中)",
                   @"toast(多行文本居上)",
                   @"toast(多行文本居下)",
                   @"显示图片和文本"];
    }
    return _array;
}


@end
