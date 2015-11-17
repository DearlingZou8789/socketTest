//
//  NSString+RandomString.m
//  socketTest
//
//  Created by Damon on 15/11/16.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import "NSString+RandomString.h"
#import "CryptAligthom.h"

static const NSString *randomTable = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+";

@implementation NSString (RandomString)

+ (NSString *)randomStringWithLength:(NSUInteger)length
{
    NSMutableString *str = [NSMutableString string];
    for (NSInteger i = 0; i < length; i++)
    {
        unichar c = [randomTable characterAtIndex:(arc4random() % randomTable.length)];
        [str appendString:[[NSString alloc] initWithCharacters:&c length:1]];
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
