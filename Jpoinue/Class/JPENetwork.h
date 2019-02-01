//
//  JPENetwork.h
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPENetwork : NSObject

+ (JPENetwork *)manager;

- (void)howOldAreYouNormal:(nullable void(^)(void))normal success:(nullable void(^)(void))success fail:(nullable void(^)(void))fail;

@end

NS_ASSUME_NONNULL_END
