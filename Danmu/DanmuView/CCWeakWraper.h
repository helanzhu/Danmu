//
//  CCWeakWraper.h
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//一个轻量级的_weak指针引用的壳，相当于 [NSValue valueWithNonretainedObject:myObj]

#define __CCWW(obj) [CCWeakWraper weakWraperForObject:obj]
#define __CCWWO(ww) (((CCWeakWraper *)ww).object)



@interface CCWeakWraper : NSObject

@property (nonatomic, weak) id object;

+ (instancetype)weakWraperForObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
