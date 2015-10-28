//
//  backAVSpeechSynthesizer.h
//  K8_iPAD
//
//  Created by Damon on 15/10/14.
//  Copyright © 2015年 zhangle.in.iMac. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface backAVSpeechSynthesizer : AVSpeechSynthesizer

+ (instancetype)sharedSpeech;

@end
