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
@property (nonatomic, strong) dispatch_queue_t consumeQueue;//在什么线程中消费

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




//依据消费者、生产者概念设计的一套自动管理系统
//将通知消息抽象成事件对象，在事件对象中，可以自己扩充你需要的属性，相较于系统自带的通知中心，使用更加方便
//生产者生产事件，管理中心负责传递事件，消费者消费事件

//通过这种方式，增加一个中间人，可以减少因使用代理而带来的代码耦合性
@interface LHManagementCenter : NSObject
+ (instancetype)defaultCenter;
- (void)registerConsumer:(id<LHEventConsumerProtocol>)consumer withIdentifier:(NSString *)eventIdentifier;

@end
