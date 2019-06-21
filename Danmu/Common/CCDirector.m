//
//  CCDirector.m
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import "CCDirector.h"
#import "CCWeakWraper.h"

#define DISPLAYLINK_MODE 0 //这个模式与定时器模式的差别在于系统做动画的时候timer模式会暂停，而displaylink不会。
#define kLXDefaultFPS 60

@interface CCDirector (){
    NSMutableArray *_needToAdd;
    NSMutableArray *_needToRemove;
    NSMutableArray *_observers;
    NSTimer *_timer;
    NSTimeInterval _deltaTime;
    NSDate* _lastUpdateTime;
    NSTimeInterval  _fps;
#if DISPLAYLINK_MODE
    CADisplayLink * _displayLink;
#endif
}

@end

@implementation CCDirector

@synthesize fps =_fps;

- (instancetype)init{
    self = [super init];
    if(self){
        _needToAdd = [NSMutableArray arrayWithCapacity:10];
        _needToRemove = [NSMutableArray arrayWithCapacity:10];
        _observers = [NSMutableArray arrayWithCapacity:10];
        _deltaTime = 0;
        _lastUpdateTime = [NSDate date];
        _fps = kLXDefaultFPS;
        
#if DISPLAYLINK_MODE
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
#endif
    }
    return self;
}

+ (instancetype)defaultDirector{
    @synchronized(self) {
        static CCDirector *defaultInstance = nil;
        static dispatch_once_t oneToken;
        dispatch_once(&oneToken, ^{
            defaultInstance = [[self alloc] init];
        });
        return defaultInstance;
    }
}


- (void)start:(NSTimeInterval)fps{
    if(![[NSThread currentThread] isMainThread]){
        NSLog(@"!!! LXDirector must be start in main thread!!!");
        return;
    }
    if(fps <=0){
        fps = kLXDefaultFPS;
    }
    _fps = fps;
    
#if DISPLAYLINK_MODE
    _displayLink.paused = NO;
#else
    if(_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1/self.fps target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    [_timer fire];
#endif
    
}

- (void)stop{
#if DISPLAYLINK_MODE
    _displayLink.paused = YES;
#else
    if(_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
#endif
}

- (void)addObserver:(id<LXUpdateDelegate>)observer{
    if(observer == nil) return;
    @synchronized(self) {
        for (CCWeakWraper * obs in _needToAdd){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            if([observer isEqual:obReged]){
                return;
            }
        }
        [_needToAdd addObject:__CCWW(observer)];
    }
}

- (void)removeObserver:(id<LXUpdateDelegate>)observer{
    if(observer == nil) return;
    @synchronized(self) {
        for (CCWeakWraper * obs in _needToRemove){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            if([observer isEqual:obReged]){
                return;
            }
        }
        [_needToRemove addObject:__CCWW(observer)];
    }
}

- (void)cc_addObserver:(id<LXUpdateDelegate>)observer{
    if(observer == nil) return;
    @synchronized(self) {
        for (CCWeakWraper * obs in _observers){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            if([observer isEqual:obReged]){
                return;
            }
        }
        [_observers addObject:__CCWW(observer)];
    }
}

- (void)cc_removeObserver:(id<LXUpdateDelegate>)observer{
    @synchronized(self) {
        for (CCWeakWraper * obs in _observers){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            if([observer isEqual:obReged]){
                [_observers removeObject:obs];
                return;
            }
        }
    }
}

- (void)processNeedToAddOrRemove{
    @synchronized(self) {
        for (CCWeakWraper * obs in _needToAdd){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            [self cc_addObserver:obReged];
        }
        for (CCWeakWraper * obs in _needToRemove){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            [self cc_removeObserver:obReged];
        }
    }
}


//计算变化时间
- (void)calculateDeltaTime{
    NSDate * now = [NSDate date];
    _deltaTime= [now timeIntervalSinceDate:_lastUpdateTime];
    _deltaTime = MAX(0, _deltaTime);
    
#ifdef DEBUG
    // If we are debugging our code, prevent big delta time
    if(_deltaTime > 0.2f){
        _deltaTime = 1 / self.fps;
    }
#endif
    
    if(_deltaTime < 1 / self.fps){
        return;
    }
    
    _lastUpdateTime = now;
}


//清除已经释放的观察者
- (void)cleanNilObserver{
    @synchronized(_observers) {
        for (long idx = _observers.count-1; idx>=0; idx--){
            CCWeakWraper * obs = [_observers objectAtIndex:idx];
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            if(obReged == nil){
                [_observers removeObjectAtIndex:idx];
            }
        }
    }
}


//定时器回调
- (void)updateTimer:(NSTimer *)timer{
    [self render];
}

- (void)render{
    [self calculateDeltaTime];
    
    [self processNeedToAddOrRemove];
    
    [self cleanNilObserver];
    
    if(_deltaTime < 1/self.fps){
        return;
    }
    
    @synchronized(_observers) {
        for (CCWeakWraper * obs in _observers){
            __weak id<LXUpdateDelegate> obReged = __CCWWO(obs);
            if([obReged respondsToSelector:@selector(update:)]){
                [obReged update:_deltaTime];
            }
        }
    }
}


@end
