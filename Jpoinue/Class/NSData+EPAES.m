//
//  NSData+EPAES.m
//  librenmen
//
//  Created by Joyce on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import "NSData+EPAES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (EPAES)

- (NSData *)AES128DecryptWithKey:(NSString *)key{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)decryptOrigin{
    NSString *key = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [self AES128DecryptWithKey:key];
}

@end
