//
//  Base64.h
//  socketTest
//
//  Created by Damon on 15/11/17.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64 : NSObject
+(int)char2Int:(char)c;
+(NSData *)decode:(NSString *)data;
+(NSString *)encode:(NSData *)data;
@end
