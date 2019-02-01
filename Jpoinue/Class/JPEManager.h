//
//  JPEManager.h
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPEConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface JPEManager : NSObject

@property (nonatomic, strong) JPEConfig *config;
+ (JPEManager *)manager;

- (void)withLaunchOptions:(NSDictionary * _Nullable)launchOptions;
- (void)howOldAreYou;

@end

NS_ASSUME_NONNULL_END
