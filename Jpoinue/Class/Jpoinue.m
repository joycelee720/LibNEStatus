//
//  Jpoinue.m
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import "Jpoinue.h"
#import "JPEManager.h"

@implementation Jpoinue

+ (void)registerWith:(NSDictionary *)launchOptions{
    [JPEManager.manager withLaunchOptions:launchOptions];
}

@end
