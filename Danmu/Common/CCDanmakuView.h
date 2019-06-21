//
//  CCDanmakuView.h
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCDanmakuView : UIView

@property (nonatomic, assign) NSUInteger maxCount; //同屏最大数量，默认30
@property (nonatomic, assign) NSTimeInterval duration; //滚出屏幕时间，默认12秒
@property (nonatomic, assign) CGFloat lineSpace; //行间隔 默认10
@property (nonatomic, assign) BOOL pause; //是否暂停，默认为NO
@property (nonatomic, assign) NSTimeInterval span; //两条弹幕出现的时间间隔，默认1秒

//追加一条弹幕
- (void)addDanmakuView:(UIView *)danmakuView;

//某条view是否在屏幕内
- (BOOL)isDanmakuViewInScreen:(UIView *)danmakuView;

//设置自动循环播放的视图组
- (void)setAutoLoopDanmakuViews:(NSArray <UIView *>*)views;

@end

NS_ASSUME_NONNULL_END
