//
//  NSString+RandomString.h
//  socketTest
//
//  Created by Damon on 15/11/16.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RandomString)
/**
 *  指定字符串的长度,生成指定表格中的随机字符串
 *
 *  @param length 字符串长度
 *
 *  @return 字符串
 */
+ (NSString *)randomStringWithLength:(NSUInteger)length;
@end

@interface NSString (DESEncode)
- (NSString *)DESEnCodeCrptionWithKey:(NSString *)key;
- (NSString *)DESDeCodeCrptionWithKey:(NSString *)key;
@end

