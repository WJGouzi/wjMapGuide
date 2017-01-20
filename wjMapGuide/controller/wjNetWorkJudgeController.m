//
//  wjNetWorkJudgeController.m
//  wjMapGuide
//
//  Created by gouzi on 2017/1/19.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import "wjNetWorkJudgeController.h"
#import "RealReachability.h"

static BOOL isFirstIn = NO;

@interface wjNetWorkJudgeController ()

@end

@implementation wjNetWorkJudgeController


// 监视网络的变化
- (void)netWorkMonitory {
    // 通知中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kRealReachabilityChangedNotification object:nil];
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    NSLog(@"Initial reachability status:%@",@(status));
    
    if (status == RealStatusNotReachable) {
        if (isFirstIn) {
            [self alertViewShowOnTheScreenWithTiltle:@"您未连接网络，请核查后稍后再次尝试！" andAcitonTitle:@"确定"];
            isFirstIn = !isFirstIn;
        }
    }
    
    if (status == RealStatusViaWiFi) {
        
    }
    if (status == RealStatusViaWWAN) {
        [self alertViewShowOnTheScreenWithTiltle:@"您正在使用移动蜂窝网络加载数据！" andAcitonTitle:@"确定"];
    }
    [GLobalRealReachability startNotifier];
}

// 销毁通知中心
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRealReachabilityChangedNotification object:nil];
    isFirstIn = NO;
}

// 网络状态发生变化
-(void)reachabilityChanged:(NSNotification*) notification {
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
    NSLog(@"networkChanged, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    
    if (status == RealStatusNotReachable) {
        [self alertViewShowOnTheScreenWithTiltle:@"您的网络出现错误，请核查后稍后再次尝试！" andAcitonTitle:@"确定"];
    }
    if (status == RealStatusViaWiFi) {

    }
    WWANAccessType accessType = [GLobalRealReachability currentWWANtype];
    
    if (status == RealStatusViaWWAN) {
        if (accessType == WWANType2G) {
            [self alertViewShowOnTheScreenWithTiltle:@"您现在的移动蜂窝网络较差，可能会影响使用体验！" andAcitonTitle:@"确定"];
        }
        else if (accessType == WWANType3G) {
            [self alertViewShowOnTheScreenWithTiltle:@"您现在正在使用3G网络！" andAcitonTitle:@"确定"];
        } else if (accessType == WWANType4G) {
            [self alertViewShowOnTheScreenWithTiltle:@"您现在正在使用4G网络！" andAcitonTitle:@"确定"];
        } else {
            [self alertViewShowOnTheScreenWithTiltle:@"您的网络发生未知错误！" andAcitonTitle:@"确定"];
        }
    }
}

/*
 * 这里判断网络状态:
 * 当在使用WiFi的情况下,正常使用无线网络；
 * 挡在使用wlan的情况下,方案一 : 需要用户来选择是不是要使用wlan网络加载数据
 *                   方案二 : 只是给用户一个提醒,说现在正在使用wlan网络
 */
// 判断是WiFi或Wlan的弹框提醒
- (void)wifiOrWlanJudgeWithReachaStatus:(RealReachability *)reachability {
    

}


- (void)alertViewShowOnTheScreenWithTiltle:(NSString *)title andAcitonTitle:(NSString *)actionTitle {
    UIAlertController *useWlanVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    // action是有值
    if (actionTitle.length) {
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 提醒用户开启了wlan
            
        }];
        [useWlanVC addAction:sureAction];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController showDetailViewController:useWlanVC sender:nil];
}



// 创建单例
+ (wjNetWorkJudgeController *)sharedNetWorkJudgeManager {
    static wjNetWorkJudgeController *sharedNetWorkController = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedNetWorkController = [[self alloc] init];
    });
    return sharedNetWorkController;
}






@end
