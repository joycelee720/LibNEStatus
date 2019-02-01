//
//  JPEConfig.m
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import "JPEConfig.h"
#import "NSData+EPAES.h"

@implementation JPEConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *bundlePath = [NSBundle.mainBundle pathForResource:@"Jpoinue" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *path = [bundle pathForResource:@"Jpoinue" ofType:@"txt"];
        NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *originData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *enOriginData = [originData decryptOrigin];
        NSString *originString = [[NSString alloc] initWithData:enOriginData encoding:NSUTF8StringEncoding];
        NSArray *array = [originString componentsSeparatedByString:@"&$@^00&!@"];
        NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:array.firstObject options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSData *enData = [base64Data AES128DecryptWithKey:array.lastObject];
        NSDictionary *statusDic = [NSJSONSerialization JSONObjectWithData:enData options:NSJSONReadingMutableContainers error:nil];
        _urlApi = statusDic[@"1"];
        _bundleID = statusDic[@"2"];
        _coverTDame = statusDic[@"3"];
        _coverName = statusDic[@"4"];
        _coverID = statusDic[@"5"];
    }
    
    return self;
}

@end
