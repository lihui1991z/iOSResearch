//
//  tab2ViewController.m
//  ManagementCenter
//
//  Created by lihui on 16/9/11.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "tab2ViewController.h"
#import "LHAutoUpdateSystem.h"

@interface tab2ViewController ()<LHAutoUpdateProtocol>
{
    int count;
}
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (nonatomic, assign) NSTimeInterval displayLabelUpdateTimeInterval;
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, strong) NSDate *nextUpdateTime;

@end

@implementation tab2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    self.displayLabelUpdateTimeInterval = 3.0;
    [self autoUpdate];
    [[LHAutoUpdateSystem defaultSystem] addAutoUpdateObject:self];
    // Do any additional setup after loading the view.
}

-(BOOL)canUpdate
{
    
    if ([self.nextUpdateTime timeIntervalSinceDate:[NSDate date]] < 0.01) {
        return YES;
    }else{
        return NO;
    }
}

-(void)autoUpdate
{
    if ([self canUpdate]) {
        self.lastUpdateTime = [NSDate date];
        self.nextUpdateTime = [self.lastUpdateTime dateByAddingTimeInterval:self.displayLabelUpdateTimeInterval];
        self.displayLabel.text = [NSString stringWithFormat:@"%d",count];
        count++;
    }
    
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
