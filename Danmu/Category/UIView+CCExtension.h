//
//  UIView+CCExtension.h
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (CCExtension)

// 分类不能添加成员属性
// @property如果在分类里面，只会自动生成get,set方法的声明，不会生成成员属性，和方法的实现
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
// 中点X坐标
@property (nonatomic, assign) CGFloat centerX;
// 中点Y坐标
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat bottom; //y+height
@property (nonatomic, assign) CGFloat right; //x+width;

@property (nonatomic, assign) CGSize size;


@end

NS_ASSUME_NONNULL_END
