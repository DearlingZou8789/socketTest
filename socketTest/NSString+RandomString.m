//
//  NSString+RandomString.m
//  socketTest
//
//  Created by Damon on 15/11/16.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import "NSString+RandomString.h"
#import "CryptAligthom.h"

static const char randomTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/!@#$%^&*()-+=";

@implementation NSString (RandomString)

+ (NSString *)randomStringWithLength:(NSUInteger)length
{
    NSMutableString *str = [NSMutableString string];
    NSUInteger count = strlen(encodingTable);
    for (NSInteger i = 0; i < length; i++)
    {
        char c = randomTable[arc4random() % count];
        NSString *iStr = [NSString stringWithUTF8String:&c];
        [str appendString:iStr];
    }
    return str;
}

@end

@implementation NSString (DESEncode)
- (NSString *)DESDeCodeCrptionWithKey:(NSString *)key
{
    return [CryptAligthom textFromBase64String:self key:key];
}

- (NSString *)DESEnCodeCrptionWithKey:(NSString *)key
{
    return [CryptAligthom base64StringFromText:self key:key];
}
@end
