//
//  NSAttributed.h
//  王钧
//
//  Created by 王钧 on 16/6/20.
//  Copyright © 2016年 wangjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJNSAttributed : NSObject


#pragma mark - 图文混排
// 设置图片和文字和文字
+ (NSAttributedString *)mixImage:(UIImage *)image text:(NSString *)text;

// 设置图片和文字和文字大小及颜色
+ (NSAttributedString *)mixImage:(UIImage *)image text:(NSString *)text textFont:(int)font textColor:(UIColor *)color;


@end
