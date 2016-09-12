//
//  tab4ViewController.m
//  ManagementCenter
//
//  Created by lihui on 16/9/12.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "tab4ViewController.h"
#import "NormalEventTest.h"




@interface tab4ViewController ()<LHEventConsumerProtocol>
@property (weak, nonatomic) IBOutlet UILabel *labelA;
@property (weak, nonatomic) IBOutlet UILabel *labelB;
@property (weak, nonatomic) IBOutlet UILabel *labelC;

@end

@implementation tab4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LHManagementCenter defaultCenter] registerConsumer:self withIdentifier:[NormalEventA defaultEventIdentifier]];
    [[LHManagementCenter defaultCenter] registerConsumer:self withIdentifier:[NormalEventB defaultEventIdentifier]];
    [[LHManagementCenter defaultCenter] registerConsumer:self withIdentifier:[NormalEventC defaultEventIdentifier]];
    // Do any additional setup after loading the view.
}


//模仿某一操作产生，针对这次操作的产生，需要向特定对象传递对应事件（发送通知）。这个操作可以由存在于内存中的任何对象执行
- (IBAction)eventHappen:(id)sender {
    NormalEventA *eventA = [[NormalEventA alloc] init];
    eventA.name = @"normalEventA";
    [eventA addIntoManagementCenter:[LHManagementCenter defaultCenter]];//类似通知中心发出通知
}


-(void)consumeEvent:(NormalEvent *)event
{
    if ([event.name isEqualToString:@"normalEventA"]) {
        self.labelA.text = @"事件A发生！";
    }
    if ([event.name isEqualToString:@"normalEventB"]) {
        self.labelB.text = @"事件B发生！";
    }
    if ([event.name isEqualToString:@"normalEventB"]) {
        self.labelC.text = @"事件C发生！";
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
