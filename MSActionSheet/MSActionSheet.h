//
//  MSActionSheet.h
//  MSActionSheet
//
//  Created by MrSong on 2016/12/11.
//  Copyright © 2016年 MrSong. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 自定义 UI 样式
#pragma mark -

/// 空白处的背景颜色
#define MSActionSheet_Blank_BackgroundColor [UIColor colorWithWhite:0 alpha:0.4]

/// 标题字体颜色
#define MSActionSheet_Title_Font_Color [UIColor colorWithRed:(120/255.f) green:(120/255.f) blue:(120/255.f) alpha:1.f]
/// 标题字体大小
#define MSActionSheet_Title_Font_Size [UIFont boldSystemFontOfSize:13.f]

/// 内容字体颜色
#define MSActionSheet_Message_Font_Color MSActionSheet_Title_Font_Color
/// 内容字体大小
#define MSActionSheet_Message_Font_Size [UIFont systemFontOfSize:13.f]

/// 按钮字体大小
#define MSActionSheet_ButtonTitle_Font_Size [UIFont systemFontOfSize:18.f]
/// 取消按钮字体颜色
#define MSActionSheet_CancelButtonTitle_Font_Color [UIColor blackColor]
/// 其他按钮字体颜色
#define MSActionSheet_OtherButtonTitle_Font_Color MSActionSheet_CancelButtonTitle_Font_Color
/// 特殊按钮字体颜色
#define MSActionSheet_DestructiveButtonTitle_Font_Color [UIColor redColor]
/// 按钮的高度
#define MSActionSheetButtonCell_Height (42.f*[UIScreen mainScreen].bounds.size.width/320.f)

/// 线的颜色
#define MSActionSheet_Line_Color [UIColor colorWithRed:(136/255.f) green:(136/255.f) blue:(136/255.f) alpha:1.f]

/// iOS 8 及以上版本支持
/// 背景是否有模糊效果，非 0 为有
#define MSActionSheet_BG_IsBlurEffectStyle 1

/// iOS 7 及以下版本 或者 没有模糊效果时修改下面的宏定义的值有效
/// 选中按钮时的背景颜色
#define MSActionSheet_Button_SelectedColor [UIColor colorWithRed:(192/255.f) green:(192/255.f) blue:(192/255.f) alpha:1.f]
/// 内容部分的背景颜色
#define MSActionSheet_Content_BackgroundColor [UIColor whiteColor]

#pragma mark -

@interface MSActionSheet : UIView

/// 取消按钮的位置
@property (nonatomic, assign, readonly) NSUInteger cancelButtonIndex;
/// 特殊按钮的位置
@property (nonatomic, assign, readonly) NSInteger destructiveButtonIndex;


/**
 初始化方法

 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitles 其他按钮标题数组
 @param clickButtonHandle 点击操作回调
 @return MSActionSheet 对象
 */
+ (instancetype)actionSheetWithCancelButtonTitle:(NSString *)cancelButtonTitle
                               otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
                               clickButtonHandle:(void (^)(MSActionSheet *ms_actionSheet, NSUInteger clickButtonAtIndex))clickButtonHandle;

/**
 初始化方法

 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitles 其他按钮标题数组
 @param destructiveButtonIndex 特殊按钮的位置，特殊按钮标题字体有特别的颜色
 @param clickButtonHandle 点击操作回调
 @return MSActionSheet 对象
 */
+ (instancetype)actionSheetWithCancelButtonTitle:(NSString *)cancelButtonTitle
                               otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
                          destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                               clickButtonHandle:(void (^)(MSActionSheet *ms_actionSheet, NSUInteger clickButtonAtIndex))clickButtonHandle;

/**
 初始化方法

 @param title 标题（可以是 NSString 类或者 NSAttributedString 类）
 @param message 内容（可以是 NSString 类或者 NSAttributedString 类）
 @param cancelButtonTitle 取消按钮标题
 @param otherButtonTitles 其他按钮标题数组
 @param destructiveButtonIndex 特殊按钮的位置，特殊按钮标题字体有特别的颜色
 @param clickButtonHandle 点击操作回调
 @return MSActionSheet 对象
 */
+ (instancetype)actionSheetWithTitle:(id)title
                             message:(id)message
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
              destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                   clickButtonHandle:(void (^)(MSActionSheet *ms_actionSheet, NSUInteger clickButtonAtIndex))clickButtonHandle;

/**
 显示 actionSheet
 */
- (void)showInWindow;

@end
