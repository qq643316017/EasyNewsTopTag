//
//  EasyNewsViewController.m
//  EasyNewsTopTag
//
//  Created by 陈微 on 16/6/17.
//  Copyright © 2016年 九指天下. All rights reserved.
//

#import "EasyNewsViewController.h"

#define ColorWithRGB(r, g, b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define ColorRandom ColorWithRGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256),1.0)

#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height

@interface EasyNewsViewController () <UIScrollViewDelegate>

@property (nonatomic,weak) IBOutlet UIScrollView *titleScroll;
@property (nonatomic,weak) IBOutlet UIScrollView *contentScroll;

@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSMutableArray *titleLabelArr;
@property (nonatomic,assign) int lastSelectIndex;

@end

@implementation EasyNewsViewController

static int const labelWidth = 80;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"网易新闻";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _titleArr = @[@"头条",@"影视",@"社会",@"综艺",@"财经",@"体育",@"演唱会",@"娱乐"];
    _lastSelectIndex = -1;
    [self creatChildViewController];
    [self creatTitleTagView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)titleLabelArr
{
    if(!_titleLabelArr){
        _titleLabelArr = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _titleLabelArr;
}

- (void)creatChildViewController
{
    for(int i=0; i<_titleArr.count; i++){
        UIViewController *subVC = [[UIViewController alloc] init];
        subVC.view.backgroundColor = ColorRandom;
        [self addChildViewController:subVC];
    }
    
    _contentScroll.contentSize = CGSizeMake(SCREEN_WIDTH*_titleArr.count, _contentScroll.frame.size.height);
    _contentScroll.showsHorizontalScrollIndicator = NO;
    _contentScroll.pagingEnabled = YES;
    _contentScroll.bounces = NO;
}

//创建顶部标签
- (void)creatTitleTagView
{
    _titleScroll.contentSize = CGSizeMake(_titleArr.count*labelWidth, _titleScroll.frame.size.height);
    _titleScroll.showsHorizontalScrollIndicator = NO;
    
    for(int i=0; i<_titleArr.count; i++){
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = _titleArr[i];
        titleLabel.tag = 100+i;
        titleLabel.userInteractionEnabled = YES;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.highlightedTextColor = [UIColor redColor];
        titleLabel.frame = CGRectMake(i*labelWidth, 0, labelWidth,_titleScroll.frame.size.height);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleScroll addSubview:titleLabel];
        [self.titleLabelArr addObject:titleLabel];
        titleLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabelClick:)];
        [titleLabel addGestureRecognizer:tapGesture];
        
        if(i == 0){
            [self tapLabelClick:tapGesture];
        }
    }
}

- (void)tapLabelClick:(UITapGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    int index = (int)label.tag - 100;
    
    [self setSelectLabelWithIndex:index];
    [self setRightContentViewWithIndex:index];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/SCREEN_WIDTH;
    [self setSelectLabelWithIndex:index];
    [self setRightContentViewWithIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int lastIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
    int nextIndex = lastIndex + 1;
    
    UILabel *lastLabel = (UILabel *)[_titleScroll viewWithTag:100+lastIndex];
    UILabel *nextLabel = (UILabel *)[_titleScroll viewWithTag:100+nextIndex];
    
    float rateOne = scrollView.contentOffset.x/SCREEN_WIDTH - lastIndex;
    float rate = 0.9 + 0.2 * (scrollView.contentOffset.x/SCREEN_WIDTH - lastIndex);
    
    lastLabel.transform = CGAffineTransformMakeScale(2-rate, 2-rate);
    nextLabel.transform = CGAffineTransformMakeScale(rate, rate);
    
    lastLabel.textColor = ColorWithRGB(255*(1-rateOne), 0, 0, 1);
    nextLabel.textColor = ColorWithRGB(255*rateOne, 0, 0, 1);
    
    NSLog(@"%f",rate);
}

- (void)setSelectLabelWithIndex:(int)index
{
    UILabel *lastLabel = (UILabel *)[_titleScroll viewWithTag:100+_lastSelectIndex];
    lastLabel.textColor = ColorWithRGB(0, 0, 0, 1);
    UILabel *nowLabel = (UILabel *)[_titleScroll viewWithTag:100+index];
    nowLabel.textColor = ColorWithRGB(255, 0, 0, 1);
    _lastSelectIndex = index;
    
    lastLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
    nowLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    CGFloat offsetX = nowLabel.frame.origin.x+nowLabel.frame.size.width/2-SCREEN_WIDTH/2;
    if(offsetX < 0){
        [_titleScroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    if(offsetX > 0 && offsetX < (_titleScroll.contentSize.width - SCREEN_WIDTH)){
        [_titleScroll setContentOffset:CGPointMake(nowLabel.frame.origin.x+nowLabel.frame.size.width/2-SCREEN_WIDTH/2, 0) animated:YES];
    }
    
    if(offsetX > (_titleScroll.contentSize.width - SCREEN_WIDTH)){
        [_titleScroll setContentOffset:CGPointMake(_titleScroll.contentSize.width - SCREEN_WIDTH, 0) animated:YES];
    }
}

- (void)setRightContentViewWithIndex:(int)index
{
    UIViewController *vc = (UIViewController *)[self.childViewControllers objectAtIndex:index];
    if(![_contentScroll.subviews containsObject:vc.view]){
        vc.view.frame = CGRectMake(index*SCREEN_WIDTH, 0, SCREEN_WIDTH, _contentScroll.frame.size.height);
        [_contentScroll addSubview:vc.view];
    }
    
    _contentScroll.contentOffset = CGPointMake(index*SCREEN_WIDTH, 0);
}

@end
