//
//  LHAutoUpdateSystem.m
//  ManagementCenter
//
//  Created by lihui on 16/9/9.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "LHAutoUpdateSystem.h"
#import "LHManagementCenter.h"


#define kTimeInterval 0.5

NSString* kRegisteredConsumerAutoUpdateSystemIdentifier = @"com.autoupdatesystem.consumer.identifier";

@interface LHAutoUpdateSystem ()<LHEventConsumerProtocol>
@property (nonatomic, strong) NSHashTable *needUpdateObjects;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) LHAutoEvent *updateEvent; //跟LHAutoUpdateSystem单例对象绑定的事件，不需要从managementCenter里移除
@end


@implementation LHAutoUpdateSystem

#pragma mark - initialize
- (instancetype)init
{
    if (self = [super init]) {
        self.needUpdateObjects = [NSHashTable weakObjectsHashTable];
        self.lock = [[NSRecursiveLock alloc] init];
        [[LHManagementCenter defaultCenter] registerConsumer:self withIdentifier:kRegisteredConsumerAutoUpdateSystemIdentifier];
    }
    return self;
}

- (void)setupEvent
{
    if(self.updateEvent) return;
    
    self.updateEvent = [[LHAutoEvent alloc] init];
    self.updateEvent.timerInterval = kTimeInterval;
    self.updateEvent.eventIdentifier = kRegisteredConsumerAutoUpdateSystemIdentifier;
//    self.updateEvent.consumeQueue = dispatch_get_main_queue(); 
    
    [self.updateEvent addIntoManagementCenter:[LHManagementCenter defaultCenter]];
}

- (void)stop
{
    [self.updateEvent removeFromManagementCenter:[LHManagementCenter defaultCenter]];
    self.updateEvent = nil;
}

#pragma mark - LHEventConsumerProtocol
-(void)consumeEvent:(LHBaseEvent *)event
{
    if( [UIApplication sharedApplication].applicationState != UIApplicationStateActive )return;
    
    [self.lock lock];
    
    if( [self.needUpdateObjects anyObject] == nil )
    {
        [self stop];
        [self.lock unlock];
        return;
    }
    
    for (id<LHAutoUpdateProtocol> obj in self.needUpdateObjects) {
        __weak NSObject<LHAutoUpdateProtocol>* weakObj = obj;
        if ([obj respondsToSelector:@selector(autoUpdate)]) {
            __strong typeof(obj) strongObj = weakObj;
            dispatch_async(dispatch_get_main_queue(), ^{ //在主队列中更新label显示，作测试使用
                [strongObj autoUpdate];
            });
            
        }
    }
    
    [self.lock unlock];
    
}



#pragma mark - add auto update object
- (void)addAutoUpdateObject:(id<LHAutoUpdateProtocol>)autoUpdateObject
{
    if(autoUpdateObject == nil) return;
    
    [self.lock lock];
    [self setupEvent];
    if (!([self.needUpdateObjects containsObject:autoUpdateObject])) {
        [self.needUpdateObjects addObject:autoUpdateObject];
    }
    [self.lock unlock];
}



#pragma mark - singleton
static id __singleton__;
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singleton__ = [super allocWithZone:zone];
    });
    return __singleton__;
}
+(instancetype)defaultSystem
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singleton__ = [[self alloc] init];
    });
    return __singleton__;
}
-(id)copyWithZone:(NSZone *)zone
{
    return __singleton__;
}
@end
