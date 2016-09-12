//
//  LHAutoUpdateSystem.h
//  ManagementCenter
//
//  Created by lihui on 16/9/9.
//  Copyright © 2016年 lihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol LHAutoUpdateProtocol <NSObject>
- (void)autoUpdate;
@end

@interface LHAutoUpdateSystem : NSObject
+(instancetype)defaultSystem;
- (void)addAutoUpdateObject:(id<LHAutoUpdateProtocol>)autoUpdateObject;

@end
