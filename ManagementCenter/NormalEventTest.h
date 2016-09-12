//
//  NormalEventTest.h
//  ManagementCenter
//
//  Created by lihui on 16/9/12.
//  Copyright © 2016年 lihui. All rights reserved.
//


#import "LHManagementCenter.h"

@interface NormalEvent : LHBaseEvent
@property(nonatomic, copy) NSString *name;
@end


@interface NormalEventA : NormalEvent
@end

@interface NormalEventB : NormalEvent
@end


@interface NormalEventC : NormalEvent
@end