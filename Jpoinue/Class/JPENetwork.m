//
//  JPENetwork.m
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import "JPENetwork.h"
#import <CommonCrypto/CommonCryptor.h>
#import "AFNetworking.h"
#import "JPEManager.h"

@interface JPENetwork ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) BOOL hasNetBack;

@end

@implementation JPENetwork

static JPENetwork *_manager = nil;

+ (JPENetwork *)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JPENetwork alloc] init];
        _manager.sessionManager = AFHTTPSessionManager.manager;
        _manager.hasNetBack = NO;
    });
    
    return _manager;
}

- (void)howOldAreYouNormal:(void (^)(void))normal success:(void (^)(void))success fail:(void (^)(void))fail{
    self.hasNetBack = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.hasNetBack) {
            [self.sessionManager.session getAllTasksWithCompletionHandler:^(NSArray<__kindof NSURLSessionTask *> * _Nonnull tasks) {
                if (tasks.count == 0) {
                    if (fail) {
                        fail();
                    }
                } else {
                    for (NSURLSessionTask *task in tasks) {
                        [task cancel];
                    }
                }
            }];
        }
    });
    
    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionary];
    [parameterDic setValue:JPEManager.manager.config.bundleID forKey:@"uniqueId"];
    [parameterDic setValue:@"1" forKey:@"platform"];
    [parameterDic setValue:@"2.2.0" forKey:@"sourceCodeVersion"];
    [parameterDic setValue:@"1" forKey:@"buildVersionCode"];
    
    AFHTTPSessionManager *manager = self.sessionManager;
    manager.requestSerializer = AFHTTPRequestSerializer.serializer;
    manager.responseSerializer = AFHTTPResponseSerializer.serializer;
    [manager POST:JPEManager.manager.config.urlApi parameters:parameterDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.hasNetBack = YES;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSInteger code = [responseDic[@"code"] integerValue];
        if (code == 200) {
            NSString *base64String = responseDic[@"data"];
            NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
            NSData *str32 = [@"e2a93cf0acdf470d617c088cbd11586b" dataUsingEncoding:NSUTF8StringEncoding];
            NSData *edec32 = [JPENetwork decryptData:base64Data withKey32:str32];
            NSDictionary *statusDic = [NSJSONSerialization JSONObjectWithData:edec32 options:NSJSONReadingMutableContainers error:nil];
            NSInteger reviewStatus = [statusDic[@"reviewStatus"] integerValue];
            if (statusDic.count == 0) {
                reviewStatus = 1;
            }
            if (reviewStatus == 2) {
                [NSUserDefaults.standardUserDefaults setObject:statusDic forKey:@"JPBenDiPeiZhi"];
                [NSUserDefaults.standardUserDefaults synchronize];
                if (success) {
                    success();
                }
            } else {
                if (normal) {
                    normal();
                }
            }
        } else {
            if (fail) {
                fail();
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.hasNetBack = YES;
        if (fail) {
            fail();
        }
    }];
}

+ (NSData *)decryptData:(NSData *)base64EncodedData withKey32:(NSData *)key32{
    NSData *retData = nil;
    NSUInteger dataLength = base64EncodedData.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    bzero(buffer, bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding|kCCOptionECBMode, key32.bytes, key32.length, NULL, base64EncodedData.bytes, base64EncodedData.length, buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        retData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return retData;
}

@end
