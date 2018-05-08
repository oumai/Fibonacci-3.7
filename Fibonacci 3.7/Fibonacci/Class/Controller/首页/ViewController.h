//
//  ViewController.h
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/19.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HealthKit;
@class HeartBackgroundView;
@class WXWaveView;
@interface ViewController : KMUIViewController<UIViewControllerPreviewingDelegate,UIScrollViewDelegate>
{
    HKHealthStore *healthStore;
    UIScrollView *myScrollView;
    UIView *headerView;             //头
    WXWaveView *waveView;           //水波纹
    NSTimer *animationTimer;
    UILabel *runCountLabel;         //计步器
    NSMutableArray *storageArray;   //
    CGPoint waterCenter;            //圆形波纹的中心
    UILabel *hudLabel;
    UIImageView *homeImageView;
    UIScrollView *contentView;
    UIView *stepView;
    UIImageView *animationImageView;
    UIImageView *heartImageView;
    CGFloat WaterViewWidth; //圆圈大小
    BOOL cameraStatus;//摄像头权限
    CGFloat offsetX;
}

@end

