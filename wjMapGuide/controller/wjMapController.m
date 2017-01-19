//
//  ViewController.m
//  wjMapGuide
//
//  Created by gouzi on 2017/1/9.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import "wjMapController.h"
#import "wjSearchResultController.h"
#import "CityListViewController.h"
#import "wjSaveFile.h"

/* 手机定位或者选择的城市名*/
static NSString *localCityName = nil;


@interface wjMapController () <UISearchControllerDelegate, MAMapViewDelegate, AMapLocationManagerDelegate, UISearchBarDelegate, wjSearchResultControllerDelegate, AMapGeoFenceManagerDelegate, CityListViewDelegate, AMapSearchDelegate>
/* 地图视图*/
@property (nonatomic, strong) MAMapView *mapView;

/* 定位的按钮*/
@property (nonatomic, strong) UIImageView *locationImage;

/* 停止通知*/
@property (nonatomic, strong) UIButton *stopNotification;

/* 搜索条*/
@property (nonatomic, strong) UISearchController *searchBar;

/* manager*/
// 地图的manager
@property (nonatomic, strong) AMapLocationManager *locationManager;
// 地理围栏的manager
@property (nonatomic, strong) AMapGeoFenceManager *fenceManager;

/* 地址*/
@property (nonatomic, strong) CLLocation *location;

/* 显示实时的交通路况*/
@property (nonatomic, strong) UIButton *showRealTraffic;

/* 显示目的地的锚点*/
@property (nonatomic, strong) MAPointAnnotation *targetPoint;

/* 两点之间的多段线*/
@property (nonatomic, strong) MAPolyline *commonPolyline;

/* 搜索对象*/
@property (nonatomic, strong) AMapSearchAPI *searchLocation;

/* 历史记录的城市名*/
@property (nonatomic, strong) NSMutableArray *recordCity;

/* 本地的文件的路径*/
@property (nonatomic, copy) NSString *plistFilePath;

@end

@implementation wjMapController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 基本的配置
    [self someFunctionSettings];
    // 显示地图
    [self showMap];
    // 定位按钮的显示
    [self locationBtnSettings];
    // 搜索条的显示
    [self searchLocationSettings];
    // 显示实时路况
    [self showTrafficInRealTime];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    wjLocalNotificaitonController *localNotificationVC = [[wjLocalNotificaitonController alloc] init];
    NSLog(@"disappeared");
    [localNotificationVC closeLocalNotification];
    [self.fenceManager removeGeoFenceRegionsWithCustomID:@"targetLocationCircle"];
    // 移除锚点和连线
    [self removeAnnotationAndPolyLine];
}

#pragma mark - 懒加载
// 定位相关的manager
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.desiredAccuracy = 5.0f;
        _locationManager.distanceFilter = 10.0f;
    }
    return _locationManager;
}

- (AMapGeoFenceManager *)fenceManager {
    if (!_fenceManager) {
        _fenceManager = [[AMapGeoFenceManager alloc] init];
        _fenceManager.activeAction = AMapGeoFenceActiveActionInside | AMapGeoFenceActiveActionOutside | AMapGeoFenceActiveActionStayed; //设置希望侦测的围栏触发行为，默认是侦测用户进入围栏的行为，即AMapGeoFenceActiveActionInside，这边设置为进入，离开，停留（在围栏内10分钟以上），都触发回调
        _fenceManager.allowsBackgroundLocationUpdates = YES;  //允许后台定位
    }
    return _fenceManager;
}

- (NSMutableArray *)recordCity {
    if (!_recordCity) {
        _recordCity = [NSMutableArray arrayWithCapacity:0];
    }
    return _recordCity;
}

#pragma mark - ===========地图展示界面的设置===========
// 一些基本的配置
- (void)someFunctionSettings {
    // 配置APPKey
    [AMapServices sharedServices].apiKey = appKey;
    // 允许https的访问
    [AMapServices sharedServices].enableHTTPS = YES;
    // 显示城市的名字
    wjSaveFile *saveFile = [[wjSaveFile alloc] init];
//    saveFile.plistFilePath = self.plistFilePath;
    if (TARGET_OS_IPHONE) {
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [documentPaths lastObject];
        self.plistFilePath = [filePath stringByAppendingPathComponent:@"/saveCityName.plist"];
    }
    if (TARGET_IPHONE_SIMULATOR) {
        self.plistFilePath = [[NSBundle mainBundle] pathForResource:@"saveCityName" ofType:@"plist"];
    }
    // 创建plist文件
    [saveFile fileManagerSettingsWithPath:self.plistFilePath];
    NSArray *city = [saveFile readCityNameFromPlistFileReturnLocalCityWithPath:self.plistFilePath];
    if (city.count & ![city isEqual:@[@""]]) {
        [self navigationSettingsWithName:city[0]];
    } else if ((city.count == 0) | [city isEqual:@[@""]]){
        [self navigationSettingsWithName:@"定位"];
    }
    
    // 代理
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // 逆地理编码
    self.searchLocation = [[AMapSearchAPI alloc] init];
    self.searchLocation.delegate = self;
    
}
#pragma mark - 地图的一些基本设置
- (void)showMap {
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    // 进入地图就显示定位
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    // 指南针的显示
    self.mapView.showsCompass = NO;
    // 隐藏比例尺
    self.mapView.showsScale = NO;
    // 能够被缩放
    self.mapView.zoomEnabled = YES;
    // 缩放的比例
    self.mapView.zoomLevel = 14.5;
    self.mapView.maxZoomLevel = 19;
    self.mapView.minZoomLevel = 2;
    // 代理
    self.mapView.delegate = self;
}


#pragma mark - 地图页面上一些设置
// 定位按钮
- (void)locationBtnSettings {
    self.locationImage = [[UIImageView alloc] init];
    self.locationImage.bounds = CGRectMake(0, 0, 30, 30);
    self.locationImage.center = CGPointMake(screenW - 30 * screenRate, screenH - 30 * screenRate);
    self.locationImage.image = [[UIImage imageNamed:@"location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.mapView addSubview:self.locationImage];
    self.locationImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationClick:)];
    [self.locationImage addGestureRecognizer:tap];
}

// 点击定位的事件
- (void)locationClick:(UITapGestureRecognizer *)tap {
    [UIView animateWithDuration:0.5 animations:^{
        // 显示定位的地方
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        // 显示缩放到原始的比例
        self.mapView.zoomLevel = 14.5;
    }];
}

// 显示实时的交通
- (void)showTrafficInRealTime {
    self.showRealTraffic = [UIButton buttonWithType:UIButtonTypeCustom];
    self.showRealTraffic.bounds = CGRectMake(0, 0, 30, 30);
    self.showRealTraffic.center = CGPointMake(screenW - (30 * screenRate), screenH - (80 * screenRate));
    [self.showRealTraffic setImage:self.showRealTraffic.selected ? [UIImage imageNamed:@"traffic_ht"] : [UIImage imageNamed:@"traffic_nor"] forState:UIControlStateNormal];
    [self.mapView addSubview:self.showRealTraffic];
    self.showRealTraffic.selected = YES;
    [self.showRealTraffic addTarget:self action:@selector(trafficAction:) forControlEvents:UIControlEventTouchDown];
    self.mapView.showTraffic = NO;
}

- (void)trafficAction:(UIButton *)switcher{
    NSLog(@"true or false: %d", switcher.selected);
    self.mapView.showTraffic = switcher.selected;
    [self.showRealTraffic setImage:switcher.selected ? [UIImage imageNamed:@"traffic_ht"] : [UIImage imageNamed:@"traffic_nor"] forState:UIControlStateNormal];
    switcher.selected = !switcher.selected;
}

#pragma mark - ===========导航栏的设置===========
#pragma mark - 替代搜索框
- (void)searchLocationSettings {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(70, 0, screenW-70, 30);
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:mainColor forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 10;
    btn.layer.borderWidth = 1.0f;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    NSAttributedString *attributedString = [WJNSAttributed mixImage:[UIImage imageNamed:@"Search"] text:@"请输入需要到达的位置" textFont:15.0f textColor:mainColor];
    [btn setAttributedTitle:attributedString forState:UIControlStateNormal];
    self.navigationItem.titleView = btn;
    // 添加事件
    [btn addTarget:self action:@selector(searchLocation:) forControlEvents:UIControlEventTouchUpInside];
}

// 点击跳转到下个界面
- (void)searchLocation:(UIButton *)location {
    //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    wjSearchResultController *searchVC = [[wjSearchResultController alloc] init];
    // 属性传值
    searchVC.inputLocationLatitude = self.location.coordinate.latitude;
    searchVC.inputLocationLongitude = self.location.coordinate.longitude;
    // 这里可以进行传值，将城市的名字传入到搜索类中
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"定位"]) {
        [ProgressHUD showError:@"请您选择当前所在的城市!" Interaction:YES];
        return;
    }
    searchVC.localCityName = self.navigationItem.leftBarButtonItem.title;
    // 设置代理
    searchVC.targetLocationDelegate = self;
    // 移除之前的锚点
    [self removeAnnotationAndPolyLine];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - 导航栏左边按钮的设置
- (void)navigationSettingsWithName:(NSString *)cityName {
    // 导航栏的左键
    UIBarButtonItem *chooseCity = [[UIBarButtonItem alloc] initWithTitle:cityName style:UIBarButtonItemStylePlain target:self action:@selector(chooseCity:)];
    chooseCity.tintColor = mainColor;
    self.navigationItem.leftBarButtonItem = chooseCity;
}

#pragma mark - 定位城市的选择和推荐
- (void)chooseCity:(UIBarButtonItem *)chooseCity {
    NSLog(@"选择城市");
    CityListViewController *cityListView = [[CityListViewController alloc]init];
    cityListView.delegate = self;
    //热门城市列表
    cityListView.arrayHotCity = [NSMutableArray arrayWithObjects:@"北京",@"上海",@"广州",@"深圳",@"成都",@"重庆",@"南京",@"天津",@"厦门",@"武汉",@"杭州",@"长沙", nil];
    //历史选择城市列表
    wjSaveFile *saveFile = [[wjSaveFile alloc] init];
    // 获取本地的路径
    self.recordCity = [saveFile readCityNameFromPlistFileReturnHistoryCityWithPath:self.plistFilePath];
    if (self.recordCity.count != 0) {
        NSArray *recordCitys = [self.recordCity copy];
        cityListView.arrayHistoricalCity = [NSMutableArray arrayWithArray:recordCitys];
    } else {
        cityListView.arrayHistoricalCity = [NSMutableArray arrayWithObjects:@"无", nil];
    }
    //定位城市列表
    cityListView.arrayLocatingCity = [NSMutableArray arrayWithObjects:localCityName, nil]; // [NSMutableArray arrayWithObjects:@"成都", nil];
    
    // 避免再次modal的时候失败
    [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:cityListView animated:YES completion:nil];
    
}

// 点击城市的按钮的代理
- (void)didClickedWithCityName:(NSString*)cityName {
    if ([cityName isEqualToString:@"无"]) {
        return;
    }
    if ([cityName isEqualToString:@""]) {
        [ProgressHUD show:@"正在定位，请稍后!" Interaction:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ProgressHUD dismiss];
        });
        return;
    }
    [self navigationSettingsWithName:cityName];
    wjSaveFile *file = [[wjSaveFile alloc] init];
    [file saveLocalCityNameInPlistFileWithCityName:cityName andPath:self.plistFilePath];
}


#pragma mark - 锚点的设置
- (void)annotationsSettingsWithName:(NSString *)name andCoordinate:(CLLocationCoordinate2D)coordinate  {
    self.targetPoint = [[MAPointAnnotation alloc] init];
    self.targetPoint.coordinate = coordinate;
    self.targetPoint.title = name;
    // 计算两个点的距离
    [self caculateTwoPointDistanceWithPointOne:self.targetPoint.coordinate andPointTwo:self.location.coordinate];
    [self.mapView addAnnotation:self.targetPoint];
    [self.mapView showAnnotations:@[self.targetPoint] edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
    // 创建自定义圆形的地理围栏
    self.fenceManager.delegate = self;
    [self.fenceManager addCircleRegionForMonitoringWithCenter:self.targetPoint.coordinate radius:500 customID:@"targetLocationCircle"];
}


#pragma mark - 计算两点之间的距离
- (void)caculateTwoPointDistanceWithPointOne:(CLLocationCoordinate2D)pointOne andPointTwo:(CLLocationCoordinate2D)pointTwo {
    MAMapPoint point1 = MAMapPointForCoordinate(pointOne);
    MAMapPoint point2 = MAMapPointForCoordinate(pointTwo);
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1, point2);
    if (distance < 1000) {
        self.targetPoint.subtitle = [NSString stringWithFormat:@"两地相距:%.2lfm", distance];
    } else if (distance >= 1000) {
        self.targetPoint.subtitle = [NSString stringWithFormat:@"两地相距:%.2lfkm", distance / 1000];
    }
}

#pragma mark - 绘制两点之前的连线
- (void)drawTwoPointsLineWithSelfLocation:(CLLocationCoordinate2D)selfCoordinate andTargetCoordinate:(CLLocationCoordinate2D)targetCoordinate {
    CLLocationCoordinate2D commonPolylineCoords[2];
    // 现在所在的定位
    commonPolylineCoords[0].latitude = selfCoordinate.latitude;
    commonPolylineCoords[0].longitude = selfCoordinate.longitude;
    // 目的地的定位
    commonPolylineCoords[1].latitude = targetCoordinate.latitude;
    commonPolylineCoords[1].longitude = targetCoordinate.longitude;
    //构造折线对象
    self.commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:2];
    //在地图上添加折线对象
    [self.mapView addOverlay: self.commonPolyline];
}


#pragma mark - 移除掉锚点和连线
- (void)removeAnnotationAndPolyLine {
    [self.mapView removeAnnotation:self.targetPoint];
    [self.mapView removeOverlay:self.commonPolyline];
    [self.locationManager stopUpdatingLocation];
    self.targetPoint = nil;
}

#pragma mark - 未到达指定的地点就停止本地的通知
- (void)stopNotificationWhileNotArriveDestination {
    self.stopNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopNotification.bounds = CGRectMake(0, 0, 90, 30);
    self.stopNotification.center = CGPointMake(screenW - (30 * screenRate), screenH * 0.5);
    [self.stopNotification setTitle:@"停止通知" forState:UIControlStateNormal];
    [self.stopNotification setTitleColor:mainColor forState:UIControlStateNormal];
    self.stopNotification.titleLabel.textAlignment = NSTextAlignmentRight;
    self.stopNotification.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.mapView addSubview:self.stopNotification];
    [self.stopNotification addTarget:self action:@selector(stopNotifi:) forControlEvents:UIControlEventTouchDown];
}

// 停止通知的手势
- (void)stopNotifi:(UIButton *)stopCancle {
    UIAlertController *cancleAlert = [UIAlertController alertControllerWithTitle:@"您真的要关闭到达提示？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 点击确定按钮后，需要退出后台的定位以及移除锚点以及相关的连线,还需要移除按钮本身
        [self.stopNotification removeFromSuperview];
        self.fenceManager.allowsBackgroundLocationUpdates = NO;
        [self removeAnnotationAndPolyLine];
        // 定位到当前位置
        [self locationClick:nil];
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    [cancleAlert addAction:cancle];
    [cancleAlert addAction:sure];
    [self showDetailViewController:cancleAlert sender:nil];
}


#pragma mark - ===========代理设置===========
#pragma mark - 地图定位的代理
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    // 先查询当前的CLLocation
    self.location = location;
    // 逆地理编码
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location  = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    regeo.requireExtension = YES;
    [self.searchLocation AMapReGoecodeSearch:regeo];
    // 停止定位
    [self.locationManager stopUpdatingLocation];
}

// 逆地理编码 -  默认选择是在当前定位的城市
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if (response.regeocode != nil) {
        //解析response获取地址描述，具体解析见 Demo
        localCityName = response.regeocode.addressComponent.city;
        NSLog(@"local city is %@", localCityName);
        if ([localCityName hasSuffix:@"\u5e02"]) { // 代表的是“成都市”的“市”的Unicode的编码
           localCityName = [localCityName stringByReplacingOccurrencesOfString:@"\u5e02" withString:@""]; // 如果有“市”就用“”代替
        }
    }
}

// 当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(updatingLocation) {
        //取出当前位置的坐标
        self.location = userLocation.location;
        if (self.targetPoint == nil) {
            return;
        } else {
            // 移除之前的连线
            [self.mapView removeOverlay:self.commonPolyline];
            // 绘制两点之间的连线 (保留----由于精度问题，造成绘制不准确，需要更新现在所处位置的经纬度)
            [self drawTwoPointsLineWithSelfLocation:self.location.coordinate andTargetCoordinate:self.targetPoint.coordinate];
            // 持续更新显示两点之间的距离
            [self caculateTwoPointDistanceWithPointOne:self.targetPoint.coordinate andPointTwo:self.location.coordinate];
            // 持续显示定位点的精度
            self.targetPoint.subtitle = [self.targetPoint.subtitle stringByAppendingString:[NSString stringWithFormat:@" 精度:%.2fm", userLocation.location.horizontalAccuracy]];
        }
    } else {
        return;
    }
}


#pragma mark - 锚点的代理设置
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.draggable = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
    
    return nil;
}


#pragma mark - 实现反向传入地址的代理
- (void)selectLocationWithName:(NSString *)name andCoordinate:(AMapGeoPoint *)coordinate {
    [self removeAnnotationAndPolyLine];
    // 添加新的锚点
    [self annotationsSettingsWithName:name andCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)];
    // 已进入的时候就要设置连线
    [self drawTwoPointsLineWithSelfLocation:self.location.coordinate andTargetCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)];
    // 显示暂停到达提醒的功能
    [self stopNotificationWhileNotArriveDestination];
}

#pragma mark - 设置两点连线的样式的代理
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth = 2.f;
        polylineRenderer.strokeColor = mainColor;
        return polylineRenderer;
    }
    return nil;
}

#pragma mark - 地理围栏的代理
// 创建的围栏是否成功，以及查看所创建围栏的具体内容
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didAddRegionForMonitoringFinished:(NSArray<AMapGeoFenceRegion *> *)regions customID:(NSString *)customID error:(NSError *)error {
    if (error) {
        [ProgressHUD showError:@"设置到达提醒失败！"];
    } else {
        NSLog(@"创建成功");
    }
}

// 知道围栏的状态是否发生改变，或者定位是否失败
- (void)amapGeoFenceManager:(AMapGeoFenceManager *)manager didGeoFencesStatusChangedForRegion:(AMapGeoFenceRegion *)region customID:(NSString *)customID error:(NSError *)error {
    NSLog(@"执行了地理围栏的代理");
    if (error) {
        [ProgressHUD showError:@"当前的GPS信号弱，请到开阔地方！"];
    }
    wjLocalNotificaitonController *localNotificationVC = [[wjLocalNotificaitonController alloc] init];
    // 每次进入的时候都需要开启后台的持续定位
    self.fenceManager.allowsBackgroundLocationUpdates = YES;
    [self.mapView addOverlay:self.commonPolyline];
    if (region.fenceStatus == AMapGeoFenceRegionStatusInside) {
        NSLog(@"在区域内！");
        // 这里需要开启本地通知的回调
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (iOS(10.0)) {
                [localNotificationVC localNotificationsInIOS10];
                
            } else {
                [localNotificationVC startLocalNotification];
            }
            // 到达指定的区域内后需要关闭后台的定位,移除`连线`和`锚点`以及`暂停通知`
            self.fenceManager.allowsBackgroundLocationUpdates = NO;
            [self removeAnnotationAndPolyLine];
            [self.stopNotification removeFromSuperview];
        });
    }
    if (region.fenceStatus == AMapGeoFenceRegionStatusOutside) {
        NSLog(@"在区域外！");
    }
    if (region.fenceStatus == AMapGeoFenceRegionStatusStayed) {
        // 长时间在区域内的时候，关闭通知以及移除地理围栏
        [localNotificationVC closeLocalNotification];
        [self.fenceManager removeGeoFenceRegionsWithCustomID:@"targetLocationCircle"];
        return;
    }
}

@end
