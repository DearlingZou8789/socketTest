//
//  GlobalInfo.m
//  K8
//
//  Created by imac on 15/4/10.
//  Copyright (c) 2015年 imac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalInfo.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworkReachabilityManager.h"
#import "backAVSpeechSynthesizer.h"

@interface GlobalInfo()

@end
@implementation GlobalInfo

#pragma mark - 类方法
/** 单例对象 */
+ (instancetype)sharedInstance
{
    static GlobalInfo *global = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        global = [[GlobalInfo alloc] init];
    });
    [[NSNotificationCenter defaultCenter] addObserver:global selector:@selector(releaseGlobal:) name:@"quit" object:nil];
    return global;
}

#pragma mark - 底部视图
//- (BottonView *)bottonView
//{
//    if (!_bottonView)
//    {
//        _bottonView = [[BottonView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - kBottomHeight, SCREENWIDTH, kBottomHeight)];
//    }
//    return _bottonView;
//}

#pragma mark - 顶部视图
//- (TopView *)topView
//{
//    if (_topView == nil)
//    {
//        _topView = [[TopView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, kTopHeight)];
//    }
//    return _topView;
//}

#pragma mark - 选择视图
//- (PIckView *)pickView
//{
//    if (_pickView == nil)
//    {
//        _pickView = [[PIckView alloc] initWithFrame:kOriginRect];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenPickView:) name:kPickerHiddenNoti object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPickView:) name:kPickerShowNoti object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePickView:) name:kPickerRemoveNoti object:nil];
//    }
//    return _pickView;
//}

//- (void)hiddenPickView:(NSNotification *)not
//{
//    [UIView animateWithDuration:kPickerShowTimer animations:^{
//        _pickView.frame = kOriginRect;
//    } completion:^(BOOL finished) {
//        if (finished)
//        {
//            self.pickView.dataArray = nil;
//        }
//    }];
//}
//
//- (void)showPickView:(NSNotification *)not
//{
//    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
//    [UIView animateWithDuration:kPickerShowTimer animations:^{
//        self.pickView.frame = kPickerShowRect;
//    }];
//}

//- (void)removePickView:(NSNotification *)not
//{
//    if (_pickView.superview)
//    {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [_pickView removeFromSuperview];
//        _pickView = nil;
//    }
//}

#pragma mark - 加载视图
//- (LoadView *)loadView
//{
//    if (_loadView == nil)
//    {
//        _loadView = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
//        _loadView.hidden = YES;
//    }
//    return _loadView;
//}

//- (void)loadView:(NSNotification *)not
//{
//    NSNumber *number = not.object;
//    if (number.boolValue)
//    {
//        self.loadView.hidden = NO;
//    }
//    else
//    {
//        self.loadView.hidden = YES;
//    }
//}

#pragma mark -
#pragma mark - 其他类方法
// 获取设备的版本号
+ (CGFloat)getDeviceVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGSize)getTextRect:(NSString *)text width:(float)width font:(float)fontSize
{
    CGSize size;
    CGSize constraint = CGSizeMake(width, 20000.0f);
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    size = [text boundingRectWithSize:constraint options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    return size;
}

+ (CGFloat)getWidthByText:(NSString *)text height:(CGFloat)height andFont:(UIFont *)font
{
    CGSize size;
    CGSize constraint = CGSizeMake(1000, height);
    size = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
    return size.width;
}

+ (CGSize)getTextRect:(NSString *)text width:(float)width andFont:(UIFont *)font
{
    CGSize size;
    CGSize constraint = CGSizeMake(width, 20000.0f);
    NSDictionary *dic = @{NSFontAttributeName: font};
    size = [text boundingRectWithSize:constraint options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    return size;
}

// 判断设备
//+ (DeviceInfoType)getDeviceInfo
//{
//    if ([NSStringFromCGRect([UIScreen mainScreen].bounds) isEqualToString:NSStringFromCGRect(iPone4Frame)]) {
//        return iPone4;
//    } else if ([NSStringFromCGRect([UIScreen mainScreen].bounds) isEqualToString:NSStringFromCGRect(iPone5Frame)]) {
//        return iPone5;
//        
//    } else if ([NSStringFromCGRect([UIScreen mainScreen].bounds) isEqualToString:NSStringFromCGRect(iPone6Frame)]) {
//        return iPone6;
//        
//    } else if ([NSStringFromCGRect([UIScreen mainScreen].bounds) isEqualToString:NSStringFromCGRect(iPone6pFrame)]) {
//        
//        return iPone6p;
//    }
//    
//    return UNKnow;
//}

+ (void)alertViewShow:(NSString *)str delegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:str delegate:delegate cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alerView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alerView dismissWithClickedButtonIndex:0 animated:YES];
    });
}

+ (void)alertViewShow:(NSString *)str delegate:(id)delegate speeck:(BOOL)flag
{
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:str delegate:delegate cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alerView show];
    if (flag)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            //文字转音频管理对象
            backAVSpeechSynthesizer *av = [backAVSpeechSynthesizer sharedSpeech];
            //声音播放对象
            AVSpeechUtterance *unv = [[AVSpeechUtterance alloc] initWithString:str];
            //设置为中文
            AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
            unv.voice = voice;
            unv.rate = AVSpeechUtteranceDefaultSpeechRate;
            //播放文字转后的音频。
            [av speakUtterance:unv];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alerView dismissWithClickedButtonIndex:0 animated:YES];
    });
}

+ (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *) md52:(char *)cStr
{
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );

    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (void)setUserDefaults:(id)value name:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeUserDefaultsForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getUserDefaults:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString *)getExchangedTime:(NSString *)time Type:(TimeType)type
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
    NSDate* inputDate = [inputFormatter dateFromString:time];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    if (type) {
        [outputFormatter setDateFormat:@"yyyyMMdd"];
        NSString *outputDate = [outputFormatter stringFromDate:inputDate];
        return outputDate;
    } else {
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *outputDate = [outputFormatter stringFromDate:inputDate];
        return outputDate;
    }
}

+ (BOOL)isString:(NSString *)string havestring:(NSString *)str
{
    NSRange range = [string rangeOfString:str];
    if (range.location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+ (NSAttributedString *)setTextStr:(NSString *)str
{
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}]];
    NSRange range = [str rangeOfString:@"."];
//    NSInteger start = isnumber([str characterAtIndex:0])?0:3;
    if (range.location!=NSNotFound)
    {
        [attributeStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:24]} range:NSMakeRange(range.location, str.length - range.location)];
    }
    return attributeStr;
}

+ (NSAttributedString *)setTextStr:(NSString *)str foreColor:(UIColor *)color
{
    NSInteger fontSize = 12;
    switch ([GlobalInfo getDeviceInfo])
    {
        case iPone4:
            fontSize = 10;
            break;
        case iPone5:
            fontSize = 11;
            break;
        default:
            break;
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attributeStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, str.length)];
    NSRange range = [str rangeOfString:@"."];
    if (range.location != NSNotFound)
    {
        [attributeStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:(int)(fontSize * 1.3)]} range:NSMakeRange(range.location, str.length - range.location)];
    }
    if (color != nil)
    {
        [attributeStr addAttributes:@{NSForegroundColorAttributeName: color} range:NSMakeRange(0, str.length)];
    }
    return attributeStr;
}

+ (BOOL)currentIsReachable
{
    NSInteger status = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    return status != AFNetworkReachabilityStatusNotReachable;
}

#pragma mark - 导航条左侧按钮的图片
+ (UIImage*)drawerButtonItemImage{
    
    static UIImage *drawerButtonImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        UIGraphicsBeginImageContextWithOptions( CGSizeMake(26, 26), NO, 0 );
        
        //// Color Declarations
        UIColor* fillColor = [UIColor colorWithRed:64/255.0 green:180/255.0 blue:211/255.0 alpha:1.0];
        
        //// Frames
        CGRect frame = CGRectMake(0, 0, 26, 26);
        
        //// Bottom Bar Drawing
        UIBezierPath* bottomBarPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 16) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 1) * 0.72000 + 0.5), 16, 1)];
        [fillColor setFill];
        [bottomBarPath fill];
        
        
        //// Middle Bar Drawing
        UIBezierPath* middleBarPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 16) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 1) * 0.48000 + 0.5), 16, 1)];
        [fillColor setFill];
        [middleBarPath fill];
        
        
        //// Top Bar Drawing
        UIBezierPath* topBarPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 16) * 0.50000 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 1) * 0.24000 + 0.5), 16, 1)];
        [fillColor setFill];
        [topBarPath fill];
        
        drawerButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    });
    
    return drawerButtonImage;
}

#pragma mark - 判断当前的止损距离是否可用
+ (BOOL)alterString:(NSString *)title text:(NSString *)text defaultText:(NSNumber *)defaultText
{
    if (fabs(text.doubleValue) < defaultText.doubleValue)
    {
        [GlobalInfo alertViewShow:[NSString stringWithFormat:@"%@不能小于%@", title, defaultText] delegate:nil];
        return NO;
    }
    return YES;
}

#pragma mark - dealloc
- (void)dealloc
{
    NSLog(@"Global清除");
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 收到退出视图通知
//- (void)releaseGlobal:(NSNotification *)not
//{
//    if (_topView.superview)
//    {
//        [_topView removeFromSuperview];
//    }
//    _topView = nil;
//    if (_bottonView.superview)
//    {
//        [_bottonView removeFromSuperview];
//    }
//    _bottonView = nil;
//    if (_pickView.superview)
//    {
//        [_pickView removeFromSuperview];
//    }
//    _pickView = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
@end
