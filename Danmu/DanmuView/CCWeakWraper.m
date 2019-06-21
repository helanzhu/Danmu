//
//  CCWeakWraper.m
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import "CCWeakWraper.h"

@implementation CCWeakWraper

+ (instancetype)weakWraperForObject:(id)obj{
    if(obj == nil) return nil;
    
    CCWeakWraper *ws = [[CCWeakWraper alloc] init];
    ws.object = obj;
    return ws;
}

@end
