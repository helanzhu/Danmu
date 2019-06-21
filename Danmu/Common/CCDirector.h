//
//  CCDirector.h
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LXUpdateDelegate<NSObject>

- (void)update:(NSTimeInterval)dt;

@end


NS_ASSUME_NONNULL_BEGIN

/**
 *  定时触发器，用于某些异步操作，观察者实现 LXUpdateDelegate
 *  因为使用了weakWraper 机制，director会自动清除已经释放的观察者对象
 *  所有的update都会在主线程回调
 */


@interface CCDirector : NSObject

+ (instancetype)defaultDirector;

- (void)start:(NSTimeInterval)fps;
- (void)stop;

/**
 *  添加观察者
 *
 *  @param observer 必须是实现了LXUpdateDelegate代理方法的实例
 */
- (void)addObserver:(id<LXUpdateDelegate>)observer;

//因为使用了weakWraper 机制，不需要一定执行remove，director会自动清除已经释放的观察者对象
/**
 *  移除观察者
 *
 *  @param observer 观察者
 */
- (void)removeObserver:(id<LXUpdateDelegate>)observer;

//默认60
@property (readonly, assign) NSTimeInterval fps;

@end

NS_ASSUME_NONNULL_END
