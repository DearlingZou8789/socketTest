//
//  GlobalInfo.h
//  K8
//
//  Created by imac on 15/4/10.
//  Copyright (c) 2015年 imac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
//#import "BottonView.h"
//#import "TopView.h"
//#import "PIckView.h"
//#import "LoadView.h"

typedef enum
{
    TimeTypeYear,
    TimeTypeHour,
    
}TimeType;


typedef enum
{
    iPone4,
    iPone5,
    iPone6,
    iPone6p,
    UNKnow,
    
}DeviceInfoType;

@interface GlobalInfo : NSObject

/** 底部视图 */
//@property (nonatomic, strong) BottonView *bottonView;
///** 顶部视图 */
//@property (nonatomic, strong) TopView *topView;
///** pickView */
//@property (nonatomic, strong) PIckView *pickView;
///** 加载视图  */
//@property (nonatomic ,strong) LoadView *loadView;

// 获取设备的版本号
+ (CGFloat)getDeviceVersion;
// 根据字符串长度 获取它的宽度, 和高度
+ (CGSize)getTextRect:(NSString *)text width:(float)width font:(float)fontSize;
// 根据字符串长度，宽度和字体获取它的宽度和高度
+ (CGSize)getTextRect:(NSString *)text width:(float)width andFont:(UIFont *)font;
/**
 *  返回指定高度和字体的text的宽度
 *
 *  @param text   要设置的text文本
 *  @param height 文本的高度
 *  @param font   字体
 *
 *  @return 文本的最佳宽度
 */
+ (CGFloat)getWidthByText:(NSString *)text height:(CGFloat)height andFont:(UIFont *)font;
// 获取设备的类型, 判断是iPhone几
+ (DeviceInfoType)getDeviceInfo;
// 弹出框
+ (void)alertViewShow:(NSString *)str delegate:(id)delegate;
/** 弹出警示框，并且阅读出来 */
+ (void)alertViewShow:(NSString *)str delegate:(id)delegate speeck:(BOOL)flag;
// md5 加密
+ (NSString *) md5:(NSString *)str;
+ (NSString *) md52:(char *)cStr;
// 沙盒存储数据
+ (void)setUserDefaults:(id)value name:(NSString *)name;
// 获取沙盒存储的数据
+ (id)getUserDefaults:(NSString *)key;
/**
 *  删除NSUserDefults中的对应key的值
 *
 *  @param key 对应key的值
 */
+ (void)removeUserDefaultsForKey:(NSString *)key;
// 把一个时间字符串转换成另一种时间字符串
+ (NSString *)getExchangedTime:(NSString *)time Type:(TimeType)type;
// 判断一个字符串是否包含某个字符
+ (BOOL)isString:(NSString *)string havestring:(NSString *)str;
/**  买入卖出的富文本编辑 */
+ (NSAttributedString *)setTextStr:(NSString *)str;
/**  行情报价中的买入卖出的富文本编辑，包含颜色设置 */
+ (NSAttributedString *)setTextStr:(NSString *)str foreColor:(UIColor *)color;
#pragma mark - 判断当前的止损距离是否可用
/**
 *  判断text的绝对值是否大于defaultText的绝对值
 *
 *  @param title       不大于的时候,显示的标题文本
 *  @param text        第一个值
 *  @param defaultText 第二个至
 *
 *  @return 是否可用
 */
+ (BOOL)alterString:(NSString *)title text:(NSString *)text defaultText:(NSNumber *)defaultText;

// 判断网络是否连接
+ (BOOL)currentIsReachable;

//// 在指定视图上显示动画
//+ (void)showLoadViewAt:(UIView *)view withTitle:(NSString *)title;
//// 移除指定视图上的显示动画
//+ (void)removeLoadViewAt:(UIView *)view;

// 单例对象
+ (instancetype)sharedInstance;
/** 导航条上左侧的按钮 */
+ (UIImage*)drawerButtonItemImage;
@end
