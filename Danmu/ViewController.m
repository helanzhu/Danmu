//
//  ViewController.m
//  Danmu
//
//  Created by chenqg on 2019/6/21.
//  Copyright © 2019年 helanzhu. All rights reserved.
//

#import "ViewController.h"
#import "CCDanmakuView.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) CCDanmakuView *danmuView;
@property (nonatomic, strong) NSArray *danmuContentArr;
@property (nonatomic, strong) NSArray *danmuColorsArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *danmuArr = [NSMutableArray arrayWithCapacity:5];
    for(NSInteger index = 0; index < 5; index++){
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(10, 20, 50, 30);
        label.text = [NSString stringWithFormat:@"主演:%@",self.danmuContentArr[index]];
        [label sizeToFit];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = self.danmuColorsArr[index];
        [danmuArr addObject:label];
    }
    [self.view addSubview:self.danmuView];
    [self.danmuView setAutoLoopDanmakuViews:danmuArr];
    
}

- (CCDanmakuView*)danmuView{
    if (!_danmuView) {
        _danmuView = [[CCDanmakuView alloc]init];
        _danmuView.frame = CGRectMake(10, 110, WIDTH-20, 300);
        _danmuView.backgroundColor = [UIColor yellowColor];
    }
    return _danmuView;
}

- (NSArray *)danmuContentArr{
    if (!_danmuContentArr) {
        _danmuContentArr = @[@"苍井空",@"武藤兰",@"小泽玛利亚",@"泷泽萝拉",@"松岛枫"];
    }
    return _danmuContentArr;
}

- (NSArray *)danmuColorsArr{
    if (!_danmuColorsArr) {
        _danmuColorsArr = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor]];
    }
    return _danmuColorsArr;
}


@end
