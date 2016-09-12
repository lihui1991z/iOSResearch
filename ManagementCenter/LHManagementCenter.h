//
//  LHManagementCenter.h
//  控制中心
//
//  Created by lihui on 16/8/5.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LHManagementCenter;

//一个baseEvent在被消费者消费后，会自动从消费者队列里删除
@interface LHBaseEvent : NSObject
@property (nonatomic, copy) NSString *eventIdentifier;
@property (nonatomic, strong) dispatch_queue_t consumeQueue;

+ (NSString *)defaultEventIdentifier;
- (void)addIntoManagementCenter:(LHManagementCenter *)manager;
@end

//一个autoEvent是不会被自动删除的，所以需要手动删除
@interface LHAutoEvent : LHBaseEvent
@property (nonatomic, assign) NSTimeInterval timerInterval;
- (void)removeFromManagementCenter:(LHManagementCenter *)manager;
@end


@protocol LHEventConsumerProtocol <NSObject>
- (void)consumeEvent:(LHBaseEvent *)event;
@end


@interface LHManagementCenter : NSObject

+ (instancetype)defaultCenter;
- (void)registerConsumer:(id<LHEventConsumerProtocol>)consumer withIdentifier:(NSString *)eventIdentifier;

@end
