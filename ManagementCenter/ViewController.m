//
//  ViewController.m
//  ManagementCenter
//
//  Created by lihui on 16/9/9.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "ViewController.h"
#import "LHAutoUpdateSystem.h"


@interface ViewController ()<LHAutoUpdateProtocol>
{
    int count;
}
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    [[LHAutoUpdateSystem defaultSystem] addAutoUpdateObject:self];
}


//现在这只是一个测试用例，自动更新label的数字显示
//但是这种自动更新机制可以用到模型类中，比如有多个数据模型需要定时更新，那么通过这种管理中心的机制，我们可以将多个数据模型同时加入到一个系统中进行自动更新的管理
-(void)autoUpdate
{
    self.displayLabel.text = [NSString stringWithFormat:@"%d",count];
    count++;
}

-(void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
