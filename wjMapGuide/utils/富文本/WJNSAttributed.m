//
//  NSAttributed.m
//  王钧
//
//  Created by 王钧 on 16/6/20.
//  Copyright © 2016年 wangjun. All rights reserved.
//

#import "WJNSAttributed.h"

@implementation WJNSAttributed


#pragma mark - 图文混排
// 设置图片和文字
+ (NSAttributedString *)mixImage:(UIImage *)image text:(NSString *)text{
    
    //1.将图片转换成文本附件
    NSTextAttachment * imageMent = [[NSTextAttachment alloc] init];
    imageMent.image = image;
    imageMent.bounds = CGRectMake(0, 0, 12, 10);
    //2.将文本附件转换成富文本
    NSAttributedString * imageAttri = [NSAttributedString attributedStringWithAttachment:imageMent];
    
    //3.将文字转换成富文本
    NSAttributedString * textAttri = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    //4.将文字富文本和图片富文本拼接起来
    NSMutableAttributedString * mixAttri = [NSMutableAttributedString new];
    
    [mixAttri appendAttributedString:imageAttri];
    [mixAttri appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [mixAttri appendAttributedString:textAttri];
    // 5.返回
    return mixAttri;
    
}



// 设置图片和文字和文字大小及颜色
+ (NSAttributedString *)mixImage:(UIImage *)image text:(NSString *)text textFont:(int)font textColor:(UIColor *)color {
    
    //1.将图片转换成文本附件
    NSTextAttachment * imageMent = [[NSTextAttachment alloc] init];
    imageMent.image = image;
    
    //2.将文本附件转换成富文本
    NSAttributedString * imageAttri = [NSAttributedString attributedStringWithAttachment:imageMent];
    
    //3.将文字转换成富文本
    NSAttributedString * textAttri = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font],NSForegroundColorAttributeName:color}];
    
    //4.将文字富文本和图片富文本拼接起来
    NSMutableAttributedString * mixAttri = [NSMutableAttributedString new];
    
    
    
    [mixAttri appendAttributedString:imageAttri];
    [mixAttri appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [mixAttri appendAttributedString:textAttri];
    
    
    // 5.返回
    return mixAttri;
    
}


@end
