//
//  wjSearchResultController.h
//  wjMapGuide
//
//  Created by gouzi on 2017/1/9.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol wjSearchResultControllerDelegate <NSObject>

- (void)selectLocationWithName:(NSString *)name andCoordinate:(AMapGeoPoint *)coordinate;

@end


@interface wjSearchResultController : UIViewController

/* 输入地址的位置*/
// 属性传值 只能传入简单的数据结构，不能传入对象
@property (nonatomic, assign) CGFloat inputLocationLatitude;
@property (nonatomic, assign) CGFloat inputLocationLongitude;
@property (nonatomic, copy) NSString *localCityName;

// 设置代理反向传值 // 将目的地的名字和经纬度传给上个控制器
@property (nonatomic, weak) id <wjSearchResultControllerDelegate> targetLocationDelegate;
@end
