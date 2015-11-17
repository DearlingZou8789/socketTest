//
//  DESUtils.h
//  socketTest
//
//  Created by Damon on 15/11/17.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "Base64.h"

@interface DESUtils : NSObject
+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;

@end
