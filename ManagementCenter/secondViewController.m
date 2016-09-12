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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
