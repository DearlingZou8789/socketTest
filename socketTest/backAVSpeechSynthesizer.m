//
//  backAVSpeechSynthesizer.m
//  K8_iPAD
//
//  Created by Damon on 15/10/14.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import "backAVSpeechSynthesizer.h"

@implementation backAVSpeechSynthesizer
+ (instancetype)sharedSpeech
{
    static dispatch_once_t onceToken;
    static backAVSpeechSynthesizer *speech;
    dispatch_once(&onceToken, ^{
        speech = [[backAVSpeechSynthesizer alloc] init];
    });
    return speech;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interRuputed:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

- (void)interRuputed:(NSNotification *)not
{
    NSLog(@"not = %@", not);
}

- (void)dealloc
{
    NSLog(@"av --> dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
