//
//  CCDanmakuView.m
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import "CCDanmakuView.h"
#import "UIView+CCExtension.h"
#import "CCDirector.h"

#define DV_SPEED 30
#define DV_COLUMN_SPACE 40

@interface CCDanmakuView()<LXUpdateDelegate>

@property (nonatomic, strong) NSMutableArray *viewsInScreen;//当前屏幕内view
@property (nonatomic, strong) NSMutableArray *viewsWaiting;//当前等待队列
@property (nonatomic, strong) UIView *nextView;//下一个添加进屏幕的view
@property (nonatomic, strong) NSMutableArray *viewsLoop;//自动循环view数组

@end

@implementation CCDanmakuView{
    double _updateTime; //记录时间间隔
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxCount = 30;
        _duration = 15.0;
        _lineSpace = 10;
        _span = 1;
        _viewsInScreen = [NSMutableArray array];
        _viewsWaiting = [NSMutableArray array];
        
        self.clipsToBounds = YES;
        //注册到director
        [[CCDirector defaultDirector] addObserver:self];
    }
    return self;
}

- (void)setAutoLoopDanmakuViews:(NSArray<UIView *> *)views{
    @synchronized (self) {
        _viewsLoop = [NSMutableArray arrayWithArray:views];
    }
}

- (void)addDanmakuView:(UIView *)danmakuView{
    @synchronized(self) {
        [_viewsWaiting addObject:danmakuView];
    }
}

- (BOOL)isDanmakuViewInScreen:(UIView *)danmakuView{
    @synchronized (self) {
        for(UIView *v in _viewsInScreen){
            if(v == danmakuView){
                return YES;
            }
        }
        return NO;
    }
}

#pragma mark - 私有方法

//从等待队列里选中下一条数据
- (void)loadNextDanmaku{
    if(_viewsWaiting.count <= 0){
        if(_viewsLoop.count > 0){
            //如果有循环数据 随机选一个
            NSInteger count = _viewsLoop.count;
            NSMutableArray *indexs = [NSMutableArray array];
            for(NSInteger i = 0; i < count; i ++){
                [indexs addObject:@(i)];
            }
            
            while(indexs.count > 0){
                NSInteger index = [[indexs objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)indexs.count)] integerValue];
                UIView *loopV = [_viewsLoop objectAtIndex:index];
                if(![self isDanmakuViewInScreen:loopV]){
                    //不在屏幕内，则选中
                    _nextView = loopV;
                    return;
                }
                [indexs removeObject:@(index)];
            }
            //没选中，说明当前都在屏幕
        }
        return;
    }
    for(UIView *view in _viewsWaiting){
        if(![self isDanmakuViewInScreen:view]){
            //选中它,同时从等待队列删除
            _nextView = view;
            [_viewsWaiting removeObject:view];
            return;
        }
    }
    return;
}

//找到最靠下的view
- (UIView *)findBottomView{
    UIView *retView = nil;
    for(UIView *view in _viewsInScreen){
        if(retView == nil){
            retView = view;
        }
        else{
            if(retView.bottom < view.bottom){
                retView = view;
            }
        }
    }
    
    return retView;
}

//从屏幕移除
- (void)removeViewFromScreen:(UIView *)view{
    @synchronized (self) {
        [view removeFromSuperview];
        [_viewsInScreen removeObject:view];
    }
}

- (BOOL) hasCollision:(CGRect)rect{
    for(UIView *v in _viewsInScreen){
        CGRect vRect = [[v.layer presentationLayer] frame];
        if(CGRectIntersectsRect(vRect, rect)){
            return YES;
        }
    }
    return NO;
}

//加入到屏幕
- (void)addViewToScreen:(UIView *)view{
    CGFloat x = 0;
    CGFloat y = 0;
    
    NSInteger count = self.height/(view.height+_lineSpace);
    //找到最靠下的view
    UIView *bottomView = [self findBottomView];
    if(bottomView == nil){
        //屏幕上没数据 随机出现
        x = self.width;
        y = _lineSpace + arc4random_uniform((u_int32_t)count)*(_lineSpace+view.height);
    }
    else{
        //默认出现在下一行
        y = bottomView.bottom + _lineSpace;
        x = self.width;
        
        if(y + view.height > self.height || arc4random_uniform(5) % 2 == 0){
            //放不下，或者有2/3概率随机找
            BOOL find = NO;
            NSInteger count = self.height/(view.height+_lineSpace);
            
            NSMutableArray *lines = [NSMutableArray array];
            for(NSInteger i = 0; i < count; i ++){
                [lines addObject:@(i)];
            }
            
            while(lines.count > 0){
                NSInteger line = [[lines objectAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)lines.count)] integerValue];
                y = _lineSpace + line*(_lineSpace+view.height);
                CGRect rect = CGRectMake(x, y, view.width, view.height);
                //检测碰撞
                if(![self hasCollision:rect]){
                    //没有碰撞
                    find = YES;
                    break;
                }
                [lines removeObject:@(line)];
            }
            if(!find){
                //放回去。下个周期再检查
                [_viewsWaiting insertObject:view atIndex:0];
                return;
            }
        }
    }
    
    
    view.x = x;
    view.y = y;
    
    [self addSubview:view];
    [_viewsInScreen addObject:view];
    
    __weak CCDanmakuView * weakSelf = self;
    //让周期有个+-10%的随机
    CGFloat durationRate = 0.9 + ((double)arc4random_uniform(20))/100.0;
    NSTimeInterval duration = _duration * durationRate;
    [UIView animateWithDuration:duration animations:^{
        //从右侧飘到屏幕外
        view.x = -view.width;
    } completion:^(BOOL finished) {
        [weakSelf removeViewFromScreen:view];
    }];
}

#pragma mark - LXUpdateDelegate
//director定时器回调
- (void)update:(NSTimeInterval)dt{
    if(_pause){
        return;
    }
    
    _updateTime += dt;
    if(_updateTime < _span){
        return;
    }
    _updateTime = 0;
    
    @synchronized (self) {
        if(_viewsInScreen.count >= _maxCount){
            return;
        }
        
        [self loadNextDanmaku];
        if(_nextView == nil){
            return;
        }
        
        [self addViewToScreen:_nextView];
        _nextView = nil;
    }
}

@end
