//
//  JPEFailViewController.m
//  Jpoinue
//
//  Created by JackLove on 2019/1/21.
//  Copyright © 2019 JoyceLove. All rights reserved.
//

#import "JPEFailViewController.h"
#import "JPEManager.h"

@interface JPEFailViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *actiView;
@property (strong, nonatomic) UIButton *refreshBtn;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIImageView *errorView;

@end

@implementation JPEFailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.errorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.errorView.center = CGPointMake(UIScreen.mainScreen.bounds.size.width/2.0, UIScreen.mainScreen.bounds.size.height/2.0-50);
    self.errorView.image = [UIImage imageNamed:@"Jpoinue.bundle/network_fail.png"];
    [self.view addSubview:self.errorView];
    
    self.refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refreshBtn.frame = CGRectMake(0, 0, 100, 44);
    self.refreshBtn.center = CGPointMake(self.errorView.center.x, self.errorView.frame.origin.y+self.errorView.frame.size.height+25+22);
    self.refreshBtn.layer.cornerRadius = 5;
    [self.refreshBtn setAttributedTitle:[[NSMutableAttributedString alloc] initWithString:@"重新加载" attributes:@{NSForegroundColorAttributeName:UIColor.darkGrayColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}] forState:UIControlStateNormal];
    self.refreshBtn.backgroundColor = [UIColor colorWithRed:234/255.0 green:240/255.0 blue:247/255.0 alpha:1];
    [self.view addSubview:self.refreshBtn];
    [self.refreshBtn addTarget:self action:@selector(jp_refresh:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    self.tipLabel.center = CGPointMake(self.errorView.center.x, self.errorView.frame.origin.y-15-15);
    self.tipLabel.numberOfLines = 2;
    self.tipLabel.text = @"网络连接错误\n点击前往设置";
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.textColor = UIColor.darkGrayColor;
    self.tipLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jp_tapToSetting:)];
    [self.tipLabel addGestureRecognizer:tap];
    [self.view addSubview:self.tipLabel];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(jp_hideActiView) name:@"kJPLaunchViewRemoveSupviewNoti" object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"kJPLaunchViewRemoveSupviewNoti" object:nil];
}

- (void)jp_hideActiView{
    [self.actiView stopAnimating];
    self.refreshBtn.enabled = YES;
}

- (void)jp_again{
    self.refreshBtn.enabled = NO;
    [self.actiView startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JPEManager.manager howOldAreYou];
    });
}

- (void)jp_refresh:(id)sender {
    [self jp_again];
}

- (void)jp_tapToSetting:(id)sender {
    NSURL *setting = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([UIApplication.sharedApplication canOpenURL:setting]) {
        if (@available(iOS 10.0, *)) {
            [UIApplication.sharedApplication openURL:setting options:@{} completionHandler:nil];
        } else {
            [UIApplication.sharedApplication openURL:setting];
        }
    }
}

- (UIActivityIndicatorView *)actiView{
    if (!_actiView) {
        _actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _actiView.frame = CGRectMake(0, 0, 100, 100);
        _actiView.center = self.view.center;
        _actiView.color = UIColor.redColor;
        [self.view addSubview:_actiView];
    }
    
    return _actiView;
}

@end
