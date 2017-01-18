//
//  wjSaveFile.m
//  wjMapGuide
//
//  Created by gouzi on 2017/1/16.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import "wjSaveFile.h"
#import "wjMapController.h"

//static NSMutableArray *historyCity ;

@interface wjSaveFile ()


@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, copy) NSString *plistPath;

@property (nonatomic, strong) NSMutableArray *historyCitysName;

@property (nonatomic, copy) NSString *plistFilePath;

@end

@implementation wjSaveFile
#pragma mark - 懒加载
- (NSMutableArray *)historyCitysName {
    if (!_historyCitysName) {
        _historyCitysName = [NSMutableArray arrayWithCapacity:6];
    }
    return _historyCitysName;
}

#pragma mark - 文件管理者的设置
- (void)fileManagerSettingsWithPath:(NSString *)plistPath {
    NSError *error = nil;
    // 创建路径
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"saveCityName" ofType:@"plist"];
    if (![self.fileManager fileExistsAtPath:plistPath]) {
        NSArray *history = [[self readCityNameFromPlistFileReturnHistoryCityWithPath:plistPath] copy];
        NSArray *local = [self readCityNameFromPlistFileReturnLocalCityWithPath:plistPath];
//        [ProgressHUD show:plistPath Interaction:YES];
        // 创建字典
        NSArray *recordCity = history.count ? history : @[];
        NSArray *localCity = local.count ? local : @[];
        NSDictionary * dict;
        if (dict == nil) {
            dict = @{@"localCity":localCity, @"historyCity":recordCity};
        }
        [self.fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:dict error:&error];
        [dict writeToFile:plistPath atomically:YES];
    }
}


#pragma mark - 文件的操作
// 存入地名
- (void)saveLocalCityNameInPlistFileWithCityName:(NSString *)cityName andPath:(NSString *)filePath {
    self.historyCitysName = [self readCityNameFromPlistFileReturnHistoryCityWithPath:filePath];
    // 如果输入的城市名字和历史中记录的名字有重复的时候，不需要修改历史记录，修改指定的的城市就可以了
    for (NSString *city in self.historyCitysName) {
        if ([cityName isEqualToString:city]) {
            NSArray *localCity = @[cityName];
            // 通过字面量创建字典，键值对，以逗号隔开
            NSDictionary * dict;
            if (dict == nil) {
                dict = @{@"localCity":localCity, @"historyCity":[self.historyCitysName copy]};
            }
            [dict writeToFile:filePath atomically:YES];
            return;
        }
    }
    // 输入的没有之前历史记录的城市名，就执行下面的代码
    if (self.historyCitysName.count < 6) {
        [self.historyCitysName insertObject:cityName atIndex:0];
    } else if (self.historyCitysName.count >= 6){
        [self.historyCitysName insertObject:cityName atIndex:0];
        [self.historyCitysName removeObjectAtIndex:6];
    }
    
    NSArray *recordCity = [self.historyCitysName copy];
    NSArray *localCity = @[cityName];
    NSDictionary * dict;
    if (dict == nil) {
        dict = @{@"localCity":localCity, @"historyCity":recordCity};
    }
    [dict writeToFile:filePath atomically:YES];
}


// 取出本地的地名
- (NSArray *)readCityNameFromPlistFileReturnLocalCityWithPath:(NSString *)path {
    // 从plist文件读取
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    // 从字典中读取本地城市
    NSArray *localCity = dict[@"localCity"];
    return localCity;
}

// 取出历史记录
- (NSMutableArray *)readCityNameFromPlistFileReturnHistoryCityWithPath:(NSString *)path {
    // 从plist文件读取
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    // 从字典中读取历史记录
    NSArray *historyCity = dict[@"historyCity"];
    NSMutableArray *recordCitys = [historyCity mutableCopy];
    return recordCitys;
}


@end
