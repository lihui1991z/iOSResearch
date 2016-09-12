//
//  LHManagementCenter.m
//  通知中心
//
//  Created by lihui on 16/8/5.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import "LHManagementCenter.h"
NSString *kRegisterConsumerDefaultIdentifier = @"com.managementcenter.consumer.default.identifier";

@interface LHBaseEvent ()
@property (nonatomic, strong) LHManagementCenter *manager;
@end


@interface LHAutoEvent ()
@property (nonatomic, strong) NSTimer *timer;
@end

@interface LHManagementCenter ()<NSCopying>
@property(nonatomic, strong) NSRecursiveLock *lock;
@property(nonatomic, strong) NSMutableDictionary *consumerInfo;
@property(nonatomic, strong) NSMutableArray *nomalEventQueue;
@property(nonatomic, strong) NSMutableArray *autoEventQueue;
@end



@implementation LHManagementCenter

#pragma mark - initialize function
-(instancetype)init
{
    if (self = [super init]) {
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(NSMutableArray *)nomalEventQueue
{
    if (_nomalEventQueue == nil) {
        _nomalEventQueue = [NSMutableArray array];
    }
    return _nomalEventQueue;
}

-(NSMutableArray *)autoEventQueue
{
    if (_autoEventQueue == nil) {
        _autoEventQueue = [NSMutableArray array];
    }
    return _autoEventQueue;
}

#pragma mark - a new thread never break
-(NSThread *)systemThread
{
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(systemThreadEntryPoint:) object:nil];
        [thread start];
    });
    return thread;
}

-(void)systemThreadEntryPoint:(id __unused)object
{
    [[NSThread currentThread] setName:@"com.LHManagementCenter.systemThread"];
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    [loop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    } while (YES);
}

#pragma mark - register consumer into the center
-(void)registerConsumer:(id<LHEventConsumerProtocol>)consumer withIdentifier:(NSString *)eventIdentifier
{
    [self.lock lock];
    if ( !(eventIdentifier && [eventIdentifier length]) )
        eventIdentifier = kRegisterConsumerDefaultIdentifier;
    
    if (self.consumerInfo == nil)
        self.consumerInfo = [NSMutableDictionary dictionary];
    
    NSHashTable *consumerForEvent = [self.consumerInfo objectForKey:eventIdentifier];
    if (consumerForEvent == nil) {
        consumerForEvent = [NSHashTable weakObjectsHashTable];
        [self.consumerInfo setObject:consumerForEvent forKey:eventIdentifier];
    }
    
    [consumerForEvent addObject:consumer];
    
    [self.lock unlock];
}



#pragma mark - add and consume event
- (void)addEvent:(LHBaseEvent *)event
{
    if (event == nil) return;
    else{
        [self performSelector:@selector(addEventIntoSystem:) onThread:self.systemThread withObject:event waitUntilDone:NO];
    }
}

//在systemThread里做事情(定时器操作等)
- (void)addEventIntoSystem:(LHBaseEvent *)event
{
    if ([event isKindOfClass:[LHAutoEvent class]]) {
        ((LHAutoEvent *)event).timer = [NSTimer scheduledTimerWithTimeInterval:((LHAutoEvent*)event).timerInterval target:self selector:@selector(triggerAutoEvent:) userInfo:@{@"event":event} repeats:YES];
        [self.autoEventQueue addObject:event]; //加入到一个数组，强引用着这个event，保持timer对象不被销毁
    }
    else{
        
        [self.nomalEventQueue addObject:event];//先加入到queue，在触发事件
        [self triggerNormalEvent];
    }
}

- (void)triggerAutoEvent:(NSTimer *)timer
{
    LHAutoEvent *event = [timer.userInfo objectForKey:@"event"];
    [self triggerEvent:event];
}

- (void)triggerNormalEvent
{
    LHBaseEvent *event = nil;
    if ([_nomalEventQueue count] <= 0) return;
    else{
        event= [_nomalEventQueue objectAtIndex:0];
        [_nomalEventQueue removeObjectAtIndex:0];
    }
    [self triggerEvent:event];
    
    [self performSelector:@selector(triggerNormalEvent) withObject:nil afterDelay:0];
    
}

- (void)triggerEvent:(LHBaseEvent *)event
{
    [self.lock lock];
    
    NSString *eventIdentifier = event.eventIdentifier;
    if ( !(eventIdentifier && [eventIdentifier length]) )
        eventIdentifier = kRegisterConsumerDefaultIdentifier;
    
    NSHashTable *consumerForEvent = [self.consumerInfo objectForKey:eventIdentifier];
    if (consumerForEvent)
    {
        for (id<LHEventConsumerProtocol> consumer in consumerForEvent)
        {
            __weak NSObject<LHEventConsumerProtocol> *weakConsumer = consumer;
            if ([weakConsumer respondsToSelector:@selector(consumeEvent:)])
            {
                __strong NSObject<LHEventConsumerProtocol> *strongConsumer = weakConsumer;
                if (event.consumeQueue)
                {
                    dispatch_async(event.consumeQueue, ^{
                        [strongConsumer consumeEvent:event];
                    });
                }
                else
                {
                    CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes, ^{
                        @autoreleasepool {
                            [strongConsumer consumeEvent:event];
                        }
                    });
                }
            }
        }
    }
    
    [self.lock unlock];
    
}


#pragma mark - remove auto event

-(void)removeEvent:(LHAutoEvent *)event
{
    if(event == nil) return;
    else{
      [self performSelector:@selector(removeFromCenter:) onThread:self.systemThread withObject:event waitUntilDone:NO];
    }
}

-(void)removeFromCenter:(LHAutoEvent *)event
{
    
    if ([event isKindOfClass:[LHAutoEvent class]]) {
       
        [event.timer invalidate];
        event.timer = nil;
        
        if ([_autoEventQueue count] <= 0) return;
        [_autoEventQueue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqual:event]) {
                [_autoEventQueue removeObjectAtIndex:idx];
            }
        }];
    }
   
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
+(instancetype)defaultCenter
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





@implementation LHBaseEvent

+ (NSString*)defaultEventIdentifier
{
    return NSStringFromClass(self.class);
}
- (NSString*)eventIdentifier
{
    if( _eventIdentifier == nil )
        _eventIdentifier = [self.class defaultEventIdentifier];
    return _eventIdentifier;
}
- (void)addIntoManagementCenter:(LHManagementCenter *)manager
{
    self.manager = manager;
    [self.manager addEvent:self];
}

@end


@implementation LHAutoEvent

- (void)removeFromManagementCenter:(LHManagementCenter *)manager
{
    [self.manager removeEvent:self];
}

@end