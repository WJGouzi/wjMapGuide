//
//  wjSaveFile.h
//  wjMapGuide
//
//  Created by gouzi on 2017/1/16.
//  Copyright © 2017年 wangjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface wjSaveFile : NSObject

/* 文件管理*/
- (void)fileManagerSettingsWithPath:(NSString *)plistPath;

/* 将数据写入到本地的plist文件中*/
- (void)saveLocalCityNameInPlistFileWithCityName:(NSString *)cityName andPath:(NSString *)filePath;

/* 将数据从plist文件中读取*/
- (NSArray *)readCityNameFromPlistFileReturnLocalCityWithPath:(NSString *)path;
- (NSMutableArray *)readCityNameFromPlistFileReturnHistoryCityWithPath:(NSString *)path;

@end
