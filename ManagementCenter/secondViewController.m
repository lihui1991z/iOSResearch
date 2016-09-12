//
//  secondViewController.m
//  ManagementCenter
//
//  Created by lihui on 16/9/10.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "secondViewController.h"
#import "LHAutoUpdateSystem.h"



@interface secondViewController () <LHAutoUpdateProtocol>
{
    int count;
}
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@end

@implementation secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    [[LHAutoUpdateSystem defaultSystem] addAutoUpdateObject:self];
}

-(void)autoUpdate
{
    
    self.displayLabel.text = [NSString stringWithFormat:@"%d",count];
    count++;
}

//当controller pop的时候，该controller可以成功被销毁，不会引起循环引用的问题
-(void)dealloc
{
    NSLog(@"%s",__func__);
}


@end
