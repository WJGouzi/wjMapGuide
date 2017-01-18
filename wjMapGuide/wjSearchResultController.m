//
//  wjSearchResultController.m
//  wjMapGuide
//
//  Created by gouzi on 2017/1/9.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import "wjSearchResultController.h"
#import "wjMapController.h"

@interface wjSearchResultController () <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AMapSearchDelegate>

@property (nonatomic, strong) UISearchController *searchVC;

/* 创建数据源数组*/
@property (nonatomic, strong) NSMutableArray *dataArray;

/* 存放搜索的数据源*/
@property (nonatomic, strong) NSMutableArray *searchArray;

/* 搜索页面*/
@property (nonatomic, strong) UITableView *tableView;

/* 搜索对象*/
@property (nonatomic, strong) AMapSearchAPI *searchLocation;

@end

@implementation wjSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.searchArray = [NSMutableArray arrayWithCapacity:0];
    self.searchLocation.delegate = self;
    [self tableViewSettings];
    [AMapServices sharedServices].apiKey = appKey;
    [self navigationSettings];
    [self searchBarSettings];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.searchVC resignFirstResponder];
    [self.searchArray removeAllObjects];
    [self.tableView removeFromSuperview];
    
}

- (void)dealloc {
    [self.searchVC resignFirstResponder];
    [self.searchArray removeAllObjects];
    [self.tableView removeFromSuperview];
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

//- (NSMutableArray *)searchArray {
//    if (!_searchArray) {
//        _searchArray = [NSMutableArray arrayWithCapacity:0];
//    }
//    return _searchArray;
//}

//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    }
//    return _tableView;
//}


- (AMapSearchAPI *)searchLocation {
    if (!_searchLocation) {
        _searchLocation = [[AMapSearchAPI alloc] init];
    }
    return _searchLocation;
}

#pragma mark - ===========城市定位的设置===========

#pragma mark - ===========搜索界面的设置===========
#pragma mark - 搜索栏的界面的设置
- (void)searchBarSettings {
    self.searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchVC.searchBar.placeholder = @"请输入需要到达的位置";
    // 修改placeholder文字的颜色
    UITextField *searchField = [self.searchVC.searchBar valueForKey:@"_searchField"];
    [searchField setValue:mainColor forKeyPath:@"_placeholderLabel.textColor"];
    // 光标的颜色也改为一致的颜色
    [self.searchVC.searchBar setTintColor:mainColor];
    self.searchVC.searchBar.barStyle = UIStatusBarStyleDefault;
    self.searchVC.searchBar.frame = CGRectMake(0, 0, screenW, 44);
    self.searchVC.dimsBackgroundDuringPresentation = NO;
    self.searchVC.hidesNavigationBarDuringPresentation = NO;
    self.navigationItem.titleView = self.searchVC.searchBar;
    self.searchVC.delegate = self;
    self.searchVC.searchResultsUpdater = self;
    self.searchVC.searchBar.delegate = self;
    // 取消按钮的自定义
    self.searchVC.searchBar.showsCancelButton = YES; // 一直显示取消按钮
    UIButton *cancelBtn = [self.searchVC.searchBar valueForKey:@"cancelButton"];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:0.965 green:0.290 blue:0.608 alpha:1.00] forState:UIControlStateNormal];
}

#pragma mark - 导航栏的设置
- (void)navigationSettings {
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToLastView:)];
    backBarButton.tintColor = mainColor;
    self.navigationItem.leftBarButtonItem = backBarButton;
    
}

- (void)backToLastView:(UIBarButtonItem *)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 搜索的页面的展示
- (void)tableViewSettings {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


#pragma mark - ===========代理设置===========
#pragma mark - 搜索框的代理
// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
// 搜索框的内容有变化的时候的代理
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // 只要搜索框的内容有更新，就要删掉之前的数据源以及对tableView进行刷新操作
    [self.searchArray removeAllObjects];
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}


// 点击搜索按钮的代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { // 这里的键盘上的`确定`按钮被置换成了`搜索`
    NSLog(@"我被点击了");
    // 搜索周围
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    if (searchBar.text.length == 0) {
        return;
    } else {
        request.keywords = searchBar.text;//@"白果林";
    }
    if (self.localCityName == nil) {
//        return;
    }
    request.city = self.localCityName;
    request.types = @"交通服务相关";
    request.requireExtension = YES;
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit = YES;
    request.requireSubPOIs = YES;
    [self.searchLocation AMapPOIKeywordsSearch:request];
    
    // 搜索公交站台
    AMapBusStopSearchRequest *stop = [[AMapBusStopSearchRequest alloc] init];
    if (searchBar.text.length == 0) {
        return;
    } else {
        stop.keywords = searchBar.text;//@"白果林";
    }
    stop.city = self.localCityName;//@"成都";
    
    [self.searchLocation AMapBusStopSearch:stop];
    
    
    [self.tableView reloadData];
}



//// 点击搜索按钮的代理
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { // 这里的键盘上的`确定`按钮被置换成了`搜索`
//    NSLog(@"我被点击了");
//    // 搜索周围
//    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
//    request.keywords            = @"天府三街";
//    request.city                = @"成都";
//    request.types               = @"交通服务相关";
//    request.requireExtension    = YES;
//    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
//    request.cityLimit           = YES;
//    request.requireSubPOIs      = YES;
//    [self.searchLocation AMapPOIKeywordsSearch:request];
//    [self.tableView reloadData];
//}



// 点击搜索按钮的代理
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { // 这里的键盘上的`确定`按钮被置换成了`搜索`
//    NSLog(@"我被点击了");
//    // 搜索周围
//    AMapPOIAroundSearchRequest *aroundRequest = [[AMapPOIAroundSearchRequest alloc] init];
//    NSLog(@"coordinate is %f", self.inputLocationLatitude);
//    aroundRequest.location = [AMapGeoPoint locationWithLatitude:self.inputLocationLatitude longitude:self.inputLocationLongitude];
//    aroundRequest.keywords = @"交通服务相关";
//    aroundRequest.radius = 1000; // 搜索的范围
//    /* 按照距离排序. */
//    aroundRequest.sortrule = 0;
//    aroundRequest.requireExtension = YES;
//    [self.searchLocation AMapPOIAroundSearch:aroundRequest];
//    [self.tableView reloadData];
//}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchVC.searchBar setShowsCancelButton:NO];
}


#pragma mark - 处理搜索位置的回调
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if (response.pois.count == 0) {
        [ProgressHUD  showError:@"没有搜索到相关的地理位置!"];
        return;
    }
    // 移除之前的数据源
    [self.searchArray removeAllObjects];
    [self.tableView reloadData];
    // 添加数据源
    [self.searchArray addObjectsFromArray:response.pois];
    // 刷新列表
    [self.tableView reloadData];
}

#pragma mark - 处理公交站台的回调
/* 公交站点回调*/
- (void)onBusStopSearchDone:(AMapBusStopSearchRequest *)request response:(AMapBusStopSearchResponse *)response {
    if (response.busstops.count == 0) {
        [ProgressHUD showError:@"没有搜索到相关的公交站点！"];
        return;
    }
    NSString *name = [response.busstops valueForKey:@"name"][0];
    AMapGeoPoint *locations = [response.busstops valueForKey:@"location"][0];
//    NSLog(@"stop name is %@", name);
//    NSLog(@"lat is %.8f, lon is %.8f", locations.latitude, locations.longitude);
    [self.dataArray addObjectsFromArray:response.busstops];
    [self.tableView reloadData];
}

#pragma mark - tableView的代理
// 标题头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchArray.count || self.dataArray.count) {
        return 44;
    }
    return 0;
}

// 标题头的名称
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // 设置文字
    if (section == 0) {
        return self.searchArray.count | self.dataArray.count ? @"附近街道" : nil;
    } else if (section == 1){
        return self.dataArray.count | self.searchArray.count ? @"附近公交站点" : nil;
    }
    return nil;
}

// 段数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchVC.searchBar.text.length != 0) {
        if (section == 0) {
            if (self.searchArray.count) {
                return self.searchArray.count;
            } else {
                return 1;
            }
        }
        if (section == 1) {
            if (self.dataArray.count) {
                return self.dataArray.count;
            } else {
                return 1;
            }
        }
    }
    return 0;
}

// cell的复用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"indexPathIdentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    NSLog(@"self.searchArray is %@", self.searchArray);
    if (indexPath.section == 0) {
        if (self.searchArray.count) {
            NSString *province = [self.searchArray valueForKey:@"province"][indexPath.row];
            NSString *city = [self.searchArray valueForKey:@"city"][indexPath.row];
            NSString *address = [self.searchArray valueForKey:@"address"][indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", province, city, address];
        } else {
            cell.textLabel.text = self.searchVC.searchBar.text.length ? @"没有找到相关的街道或道路，请核对您输入的地址!" : nil;
        }
    }
    if (indexPath.section == 1) {
        if (self.dataArray.count) {
            NSString *name = [self.dataArray valueForKey:@"name"][indexPath.row];
            AMapGeoPoint *locations = [self.dataArray valueForKey:@"location"][indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"lat:%.8f, lon:%.8f", locations.latitude, locations.longitude];
        } else {
            cell.textLabel.text = self.searchVC.searchBar.text.length ? @"没有找到相关的站点，请核对您输入的地址!" : nil;
            cell.detailTextLabel.text = nil;
        }
    }
    return cell;
}

// cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"index is %ld, %ld", indexPath.section, indexPath.row);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"text is %@, sub is %@", cell.textLabel.text, [self.dataArray valueForKey:@"location"][indexPath.row]);
    wjMapController *vc = [[wjMapController alloc] init];
    vc.targetLocationName = cell.textLabel.text;
    AMapGeoPoint *locations = [indexPath.section == 0 ? self.searchArray : self.dataArray valueForKey:@"location"][indexPath.row];
    if (self.searchVC.searchBar.text.length == 0) {
        return;
    } else {
        [self.targetLocationDelegate selectLocationWithName:cell.textLabel.text andCoordinate:locations];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
