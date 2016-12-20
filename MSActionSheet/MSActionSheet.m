//
//  MSActionSheet.m
//  MSActionSheet
//
//  Created by MrSong on 2016/12/11.
//  Copyright © 2016年 MrSong. All rights reserved.
//

#import "MSActionSheet.h"

#define MS_SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define MS_SCREEN_WIDTH MS_SCREEN_BOUNDS.size.width
#define MS_SCREEN_HEIGHT MS_SCREEN_BOUNDS.size.height

#pragma mark - MSActionSheetButtonCell
#pragma mark -

@interface MSActionSheetButtonCell : UITableViewCell

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *highlightedColor;

@property (nonatomic, strong) UILabel *titleLB;

@property (nonatomic, strong) UIView *lineV;

@end

@implementation MSActionSheetButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
#if MSActionSheet_BG_IsBlurEffectStyle
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0f) {
            self.normalColor = [UIColor colorWithWhite:1.f alpha:0.7f];
            self.highlightedColor = [UIColor colorWithWhite:1.f alpha:0.3f];
        }
#endif
        if (self.normalColor == nil) {
            self.normalColor = [UIColor clearColor];
        }
        if (self.highlightedColor == nil) {
            self.highlightedColor = MSActionSheet_Button_SelectedColor;
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLB];
        [self.contentView addSubview:self.lineV];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    self.backgroundColor = highlighted ? self.highlightedColor: self.normalColor;
}

#pragma mark - Getter

- (UILabel *)titleLB
{
    if (_titleLB == nil) {
        _titleLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MS_SCREEN_WIDTH, MSActionSheetButtonCell_Height)];
        _titleLB.font = MSActionSheet_ButtonTitle_Font_Size;
        _titleLB.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLB;
}

- (UIView *)lineV
{
    if (_lineV == nil) {
        CGFloat lineHeight = 1.f/[UIScreen mainScreen].scale;
        _lineV = [[UIView alloc] initWithFrame:CGRectMake(0, MSActionSheetButtonCell_Height-lineHeight, MS_SCREEN_WIDTH, lineHeight)];
        _lineV.backgroundColor = MSActionSheet_Line_Color;
    }
    return _lineV;
}

@end

#pragma mark - MSActionSheet
#pragma mark -

@interface MSActionSheet ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, strong) NSAttributedString *titleAttStr;
@property (nonatomic, copy) NSString *messageStr;
@property (nonatomic, strong) NSAttributedString *messageAttStr;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, assign, readwrite) NSInteger destructiveButtonIndex;
@property (nonatomic, copy) void (^clickButtonHandle)(MSActionSheet *, NSUInteger);
@property (nonatomic, copy) NSArray<NSString *> *otherButtonTitles;

/// 半透明黑色背景
@property (nonatomic, strong) UIControl *tapBGControl;
/// title 部分，没有就不显示
@property (nonatomic, strong) UIView *headerTitleV;

@property (nonatomic, strong) UITableView *tableV;
/// tableView 的 backgroundView，iOS 8 以上有毛玻璃效果
@property (nonatomic, strong) UIView *tableBGV;

@end

@implementation MSActionSheet

#pragma mark - Life Cycle

+ (instancetype)actionSheetWithCancelButtonTitle:(NSString *)cancelButtonTitle
                    otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
                    clickButtonHandle:(void (^)(MSActionSheet *, NSUInteger))clickButtonHandle
{
    return [[self alloc] initWithTitle:nil message:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles destructiveButtonIndex:-1 clickButtonHandle:clickButtonHandle];
}

+ (instancetype)actionSheetWithCancelButtonTitle:(NSString *)cancelButtonTitle
                    otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
               destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                    clickButtonHandle:(void (^)(MSActionSheet *, NSUInteger))clickButtonHandle
{
    return [[self alloc] initWithTitle:nil message:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles destructiveButtonIndex:destructiveButtonIndex clickButtonHandle:clickButtonHandle];
}

+ (instancetype)actionSheetWithTitle:(id)title
                             message:(id)message
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
              destructiveButtonIndex:(NSInteger)destructiveButtonIndex
                   clickButtonHandle:(void (^)(MSActionSheet *, NSUInteger))clickButtonHandle
{
    return [[self alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles destructiveButtonIndex:destructiveButtonIndex clickButtonHandle:clickButtonHandle];
}

- (instancetype)initWithTitle:(id)title
                      message:(id)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles
       destructiveButtonIndex:(NSInteger)destructiveButtonIndex
            clickButtonHandle:(void (^)(MSActionSheet *, NSUInteger))clickButtonHandle
{
    self = [super init];
    if (self) {
        // 数据部分
        if ([title isKindOfClass:[NSString class]]) {
            self.titleStr = title;
        } else if ([title isKindOfClass:[NSAttributedString class]]) {
            self.titleAttStr = title;
        }
        if ([message isKindOfClass:[NSString class]]) {
            self.messageStr = message;
        } else if ([message isKindOfClass:[NSAttributedString class]]) {
            self.messageAttStr = message;
        }
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitles = otherButtonTitles;
        self.destructiveButtonIndex = destructiveButtonIndex;
        self.clickButtonHandle = clickButtonHandle;
        // UI部分
        self.frame = MS_SCREEN_BOUNDS;
        [self addSubview:self.tapBGControl];
        [self addSubview:self.tableV];
        
        [self.tableV reloadData];
    }
    return self;
}

#pragma mark - Publick Methods

- (void)showInWindow
{
    // 动画前
    CGFloat tableVHeight =  self.tableV.contentSize.height;
    CGRect tableVFrame = CGRectMake(0, MS_SCREEN_HEIGHT, MS_SCREEN_WIDTH, tableVHeight);
    self.tableV.frame = tableVFrame;
    CGRect tapBGControlFrame = self.bounds;
    self.tapBGControl.frame = tapBGControlFrame;
    self.tapBGControl.alpha = 0.f;
    // 动画后
    tableVFrame.origin.y = MS_SCREEN_HEIGHT - tableVHeight;
    tapBGControlFrame.size.height = MS_SCREEN_HEIGHT - tableVHeight;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.tapBGControl.alpha = 1.f;
        self.tapBGControl.frame = tapBGControlFrame;
        self.tableV.frame = tableVFrame;
    }];
}

#pragma mark - Private Methods

- (void)dismiss
{
    // 动画后
    CGRect tableVFrame = self.tableV.frame;
    tableVFrame.origin.y = MS_SCREEN_HEIGHT;
    CGRect tapBGControlFrame = self.tapBGControl.frame;
    tapBGControlFrame.size.height = MS_SCREEN_HEIGHT;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.tapBGControl.alpha = 0.f;
        self.tapBGControl.frame = tapBGControlFrame;
        self.tableV.frame = tableVFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Actions

- (void)tapBG
{
    [self dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.otherButtonTitles.count;
    } else if (section == 1) {
        return 1;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor colorWithRed:(192/255.f) green:(192/255.f) blue:(192/255.f) alpha:1.f];
        return v;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSActionSheetButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MSActionSheetButtonCell"];
    cell.lineV.hidden = ((indexPath.section == 1) || (indexPath.row + 1 == self.otherButtonTitles.count));
    if (indexPath.section == 0) {
        cell.titleLB.text = self.otherButtonTitles[indexPath.row];
        if (self.destructiveButtonIndex != indexPath.row) {
            cell.titleLB.textColor = MSActionSheet_OtherButtonTitle_Font_Color;
        } else {
            cell.titleLB.textColor = MSActionSheet_DestructiveButtonTitle_Font_Color;
        }
    } else if (indexPath.section == 1) {
        cell.titleLB.text = self.cancelButtonTitle;
        cell.titleLB.textColor = MSActionSheet_CancelButtonTitle_Font_Color;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.clickButtonHandle) {
        NSUInteger clickButtonIndex = indexPath.section*self.otherButtonTitles.count+indexPath.row;
        self.clickButtonHandle(self, clickButtonIndex);
        self.clickButtonHandle = nil;
    }
    [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MSActionSheetButtonCell_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 6.f;
    }
    return 0.0001f;
}

#pragma mark - Getter

- (NSUInteger)cancelButtonIndex
{
    return self.otherButtonTitles.count;
}

- (UIControl *)tapBGControl
{
    if (_tapBGControl == nil) {
        _tapBGControl = [[UIControl alloc] init];
        _tapBGControl.backgroundColor = MSActionSheet_Blank_BackgroundColor;
        
        [_tapBGControl addTarget:self action:@selector(tapBG) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tapBGControl;
}

- (UIView *)headerTitleV
{
    if (_headerTitleV == nil) {
        _headerTitleV = [[UIView alloc] init];
        UIColor *backgroundColor;
#if MSActionSheet_BG_IsBlurEffectStyle
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0f) {
            backgroundColor = [UIColor colorWithWhite:1.f alpha:0.7f];
        }
#endif
        if (backgroundColor == nil) {
            backgroundColor = [UIColor clearColor];
        }
        _headerTitleV.backgroundColor = backgroundColor;
        
        CGFloat maxY;
        if (self.titleStr || self.titleAttStr) {
            UILabel *titleLB = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 20.f, MS_SCREEN_WIDTH - 30.f, 0)];
            titleLB.numberOfLines = 0;
            titleLB.font = MSActionSheet_Title_Font_Size;
            titleLB.textColor = MSActionSheet_Title_Font_Color;
            titleLB.textAlignment = NSTextAlignmentCenter;
            if (self.titleStr) {
                titleLB.text = self.titleStr;
            } else if (self.titleAttStr) {
                titleLB.attributedText = self.titleAttStr;
            }
            [_headerTitleV addSubview:titleLB];
            [titleLB sizeToFit];
            CGRect titleLBFrame = titleLB.frame;
            titleLBFrame.size.width = MS_SCREEN_WIDTH - 30.f;
            titleLB.frame = titleLBFrame;
            
            maxY = CGRectGetMaxY(titleLB.frame) + 10.f;
        } else {
            maxY = 20.f;
        }
        
        if (self.messageStr || self.messageAttStr) {
            UILabel *messageLB = [[UILabel alloc] initWithFrame:CGRectMake(15.f, maxY, MS_SCREEN_WIDTH - 30.f, 0)];
            messageLB.numberOfLines = 0;
            messageLB.font = MSActionSheet_Message_Font_Size;
            messageLB.textColor = MSActionSheet_Message_Font_Color;
            messageLB.textAlignment = NSTextAlignmentCenter;
            if (self.messageStr) {
                messageLB.text = self.messageStr;
            } else if (self.messageAttStr) {
                messageLB.attributedText = self.messageAttStr;
            }
            [_headerTitleV addSubview:messageLB];
            [messageLB sizeToFit];
            CGRect messageLBFrame = messageLB.frame;
            messageLBFrame.size.width = MS_SCREEN_WIDTH - 30.f;
            messageLB.frame = messageLBFrame;
            
            maxY = CGRectGetMaxY(messageLB.frame) + 20.f;
        } else {
            maxY += 10.f;
        }
        
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, maxY, MS_SCREEN_WIDTH, 1.f/[UIScreen mainScreen].scale)];
        lineV.backgroundColor = MSActionSheet_Line_Color;
        [_headerTitleV addSubview:lineV];
        
        _headerTitleV.frame = CGRectMake(0, 0, MS_SCREEN_WIDTH, CGRectGetMaxY(lineV.frame));
    }
    return _headerTitleV;
}

- (UITableView *)tableV
{
    if (_tableV == nil) {
        _tableV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableV.scrollEnabled = NO;
        _tableV.backgroundColor = [UIColor clearColor];
        _tableV.backgroundView = self.tableBGV;
        _tableV.dataSource = self;
        _tableV.delegate = self;
        if (self.titleStr || self.titleAttStr || self.messageStr || self.messageAttStr) {
            _tableV.tableHeaderView = self.headerTitleV;
            // 去掉 grouped 风格 tableFooterView 默认的高度，而且要注意需要写在设置代理的代码后面，原因不详
            _tableV.tableFooterView = [[UIView alloc] init];
        }

        [_tableV registerClass:[MSActionSheetButtonCell class] forCellReuseIdentifier:@"MSActionSheetButtonCell"];
    }
    return _tableV;
}

- (UIView *)tableBGV
{
    if (_tableBGV == nil) {
#if MSActionSheet_BG_IsBlurEffectStyle
        if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0f) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            _tableBGV = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        }
#endif
        if (_tableBGV == nil) {
            _tableBGV = [[UIView alloc] init];
            _tableBGV.backgroundColor = MSActionSheet_Content_BackgroundColor;
        }
    }
    return _tableBGV;
}

@end
