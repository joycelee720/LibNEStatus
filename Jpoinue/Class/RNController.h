//
//  RNController.h
//  kokolu
//
//  Created by zenox on 2018/11/16.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNController : UIViewController
+ (BOOL)isValid;
+ (instancetype)vcWithLaunchOptions:(NSDictionary *)options jUrl:(NSString *)urlString apiServer:(NSString *)apiServer channel:(NSString *)channel jpushAppKey:(NSString *)jpushAppKey umengAppKey:(NSString *)umengAppKey;

@end
