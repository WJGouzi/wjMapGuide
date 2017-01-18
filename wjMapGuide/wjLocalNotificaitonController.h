//
//  wjLocalNotificaitonController.h
//  wjMapGuide
//
//  Created by gouzi on 2017/1/13.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wjLocalNotificaitonController : UIViewController
/* 开始本地通知*/
- (void)startLocalNotification;
- (void)closeLocalNotification;
// ios10的通知
- (void)iOS10LocalNotification;
@end
