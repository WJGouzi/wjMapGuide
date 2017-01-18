//
//  AppDelegate.m
//  wjMapGuide
//
//  Created by gouzi on 2017/1/9.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import"AppDelegate.h"
#import "wjMapController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 根控制器的设置
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    wjMapController *vc = [[wjMapController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // 本地通知的设置
    [self notificationSettingsWithApplication:application];
    
    return YES;
}

// 本地通知的设置
- (void)notificationSettingsWithApplication:(UIApplication *)application {
    // 这是iOS8~iOS9的适配
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        
//        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
//    }
    // 这是iOS10的适配
    if ([application respondsToSelector:@selector(requestAuthorizationWithOptions:completionHandler:)]) {
        // 第二步
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 申请权限
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"权限？%d", granted);
        }];
    }
    application.applicationIconBadgeNumber = 0;
    
}

/* 收到本地通知*/
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"这已经是前台了");
        [self showAlertView:@"您已经快要到指定的地点，请注意周围的环境！"];
    }
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"这是后台跳转到前台的");
        [self showAlertView:@"您已经快要到指定的地点，请注意周围的环境！"];
    }
}

/* 程序即将进入到活动的状态*/
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

// 提示框
- (void)showAlertView:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.window.rootViewController showDetailViewController:alert sender:nil];
}

#pragma mark - iOS10的代理
// APP处于前台的时候接受到通知事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"调用了方法%s", __func__);
    [self showAlertView:@"您已经快要到指定的地点，请注意周围的环境！"];
    
}

// 按钮点击事件会调用的方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // 根据ID来判断各种的点击事件
    if ([response.actionIdentifier isEqualToString:@"action.input"]) {
        [self showAlertView:((UNTextInputNotificationResponse *)response).userText];
    }
    
    // 在这里处理各种事件
    NSLog(@"调用了这个方法:%s", __func__);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
