//
//  NormalEventTest.m
//  ManagementCenter
//
//  Created by lihui on 16/9/12.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "NormalEventTest.h"

@implementation NormalEvent
@end

@implementation NormalEventA

-(dispatch_queue_t)consumeQueue
{
    return dispatch_get_main_queue();
}
@end


@implementation NormalEventB

-(dispatch_queue_t)consumeQueue
{
    return dispatch_get_main_queue();
}
@end


@implementation NormalEventC

-(dispatch_queue_t)consumeQueue
{
    return dispatch_get_main_queue();
}
@end