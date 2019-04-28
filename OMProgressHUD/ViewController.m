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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [OMProgressConfig sharedInstance].loadingContentSize = CGSizeMake(120, 120);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [OMProgressHUD showImageLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [OMProgressHUD dismiss];
    });
    
}



@end
