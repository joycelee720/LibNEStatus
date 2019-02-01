//
//  NSData+EPAES.h
//  librenmen
//
//  Created by Joyce on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (EPAES)

- (NSData *)AES128DecryptWithKey:(NSString *)key;
- (NSData *)decryptOrigin;

@end

NS_ASSUME_NONNULL_END
