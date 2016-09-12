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
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)autoUpdate
{
    self.displayLabel.text = [NSString stringWithFormat:@"%d",count];
    count++;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
