//
//  wjLocalNotificaitonController.m
//  wjMapGuide
//
//  Created by gouzi on 2017/1/13.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import "wjLocalNotificaitonController.h"
#import <UserNotifications/UserNotifications.h>
#import "AppDelegate.h"

@interface wjLocalNotificaitonController ()

@end

@implementation wjLocalNotificaitonController
/* 开始本地通知*/
- (void)startLocalNotification {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5.0f];
    //    localNotification.repeatInterval = NSCalendarUnitMinute;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"已经到达目的地附近！";
    localNotification.alertTitle = @"我来了提醒您";
    localNotification.alertLaunchImage = @"distance20";
    localNotification.hasAction = YES;
    localNotification.alertAction = @"点击请查看具体的详情！";
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{@"app" : @"我来了", @"author" : @"请输入账号名"};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


/* 关闭本地通知*/
- (void)closeLocalNotification {
    NSArray *localNotification = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *localNoti in localNotification) {
        if ([localNoti.alertTitle isEqualToString:@"我来了提醒您"]) {
            // 取消所有的订单
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    }
}



- (void)localNotificationsInIOS10 {
    // 第一步: 引入框架 <UserNotifications/UserNotifications.h>
    // 第三步:发送通知
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    // 检验权限
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSUInteger status = [settings authorizationStatus];
        NSLog(@"status is %lu", status);
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 消息的主题
        content.body = [NSString localizedUserNotificationStringForKey:@"已经到达目的地附近！" arguments:nil];
        // 消息的标题
        content.title = [NSString localizedUserNotificationStringForKey:@"我来了提醒您" arguments:nil];
        // 消息的副标题
        content.subtitle = [NSString localizedUserNotificationStringForKey:@"请您注意周围环境！" arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.badge = @1;
        // 必写代码
        content.categoryIdentifier = @"notificationID";
        content.launchImageName = @"distance20";
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3.0f repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:trigger];
        // 在通知中心中添加
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
        
        // 第四步:添加用户的交互
        UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action.open" title:@"打开" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action.close" title:@"关闭" options:UNNotificationActionOptionDestructive];
        UNNotificationCategory *catagory = [UNNotificationCategory categoryWithIdentifier:@"notificationID" actions:@[action1, action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        [center setNotificationCategories:[NSSet setWithObject:catagory]];
        
    }];
}



@end
