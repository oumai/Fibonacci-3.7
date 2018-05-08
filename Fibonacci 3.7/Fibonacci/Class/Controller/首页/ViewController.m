//
//  ViewController.m
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/19.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "ViewController.h"
#import "HeartBackgroundView.h"
#import "HeartRateDetectioViewController.h"
#import "BloodPressureDetectioViewController.h"
#import "GFWaterView.h"
#import "WXWaveView.h"
#import "HealthStepViewController.h"
#import "VitalCapacityViewController.h"
#import "BloodOxygenViewController.h"
#import "MedicallyExaminedViewController.h"
#import "EyeTestViewController.h"
#import "BloodSugarViewController.h"
#import "HealthKitManage.h"

#import "VitalCapacityResultViewController.h"

@import AVFoundation;
@interface ViewController ()
@property (nonatomic , strong) NSArray *dataSource;
@end


@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchGotoVc:) name:@"touchGotoVc" object:nil];
    if (IS_IOS9)
    {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }

    WaterViewWidth = MainScreenWidth/2.2;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        [self setContentView];
        [self imageAnimationController];
    });
    if (@available(iOS 11.0, *))
    {
        [myScrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [animationImageView startAnimating];
    [heartImageView startAnimating];
    if (AVAuthorizationStatusAuthorized == [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeVideo]) {
        cameraStatus = YES;
    }
#if TARGET_OS_IPHONE//真机
    if (IS_IOS8) {
        [[HealthKitManage shareInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
            if (success) {
                [self getHealthAuthorization];
            }
        }];
    }
#endif
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clickAnimation:) userInfo:nil repeats:YES];
    NSString *FirstGoHomeValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"FirstGoHome"];
    if (FirstGoHomeValue.length != 0)
    {
        [self fristOpenApp];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (@available(iOS 11.0, *))
//    {
//        [myScrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
//    }
//    else
//    {
//        self.automaticallyAdjustsScrollViewInsets = YES;
//    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeAnimationTimer];
    [animationImageView stopAnimating];
    [heartImageView stopAnimating];
}

#pragma mark - 界面元素
-(void)setContentView
{
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight-49)];
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = YES;
    myScrollView.bounces = NO;
    [self.view addSubview:myScrollView];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight*0.51)];
    headerView.backgroundColor = AppColor;
    [myScrollView addSubview:headerView];
    
    waveView = [WXWaveView addToView:headerView withFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-6, MainScreenWidth, 6)];
    [waveView wave];
    
    CGFloat waterViewY = (CGRectGetHeight(headerView.frame)-WaterViewWidth)/2;
    CGFloat waterViewX = (MainScreenWidth-WaterViewWidth)/2;
    
    GFWaterView *waterView = [[GFWaterView alloc]initWithFrame:CGRectMake(waterViewX, waterViewY, WaterViewWidth, WaterViewWidth)];
    waterView.backgroundColor = [UIColor clearColor];
    waterCenter = waterView.center;
    [headerView addSubview:waterView];
    
    hudLabel = [[UILabel alloc] initWithFrame:CGRectMake((MainScreenWidth-100)/2, waterViewY+20, 100, 35)];
    hudLabel.text = @"快速体检";
    hudLabel.textAlignment = NSTextAlignmentCenter;
    hudLabel.font = [UIFont systemFontOfSize:15];
    hudLabel.textColor = [UIColor whiteColor];
    hudLabel.alpha = 0;
    [myScrollView addSubview:hudLabel];
    
    contentView = [[UIScrollView alloc]init];
    contentView.showsHorizontalScrollIndicator = NO;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.delegate = self;
//    NSArray *titleArray = @[@"心率测量",@"血压测量",@"心理测试", @"血糖录入", @"视力测量", @"肺活量测量", @"血氧测量", @"体脂率"];
    NSArray *titleArray = @[@"心率测量",@"血压测量", @"血糖录入", @"视力测量", @"肺活量测量", @"血氧测量"];
    NSArray *imageArray = @[@"home_heartrate_icon", @"home_bloodpressure_icon", @"home_bloodglucose_icon", @"home_vision_icon", @"home_vitalcapacity_icon", @"home_bloodsugar_icon"];
    CGFloat imageWidth = 55;
    CGFloat imageHeight = 55;
    CGFloat labelWidth = imageWidth +20;
    CGFloat labelHeight = 40;
    CGFloat width = (MainScreenWidth -3*labelWidth)/3;
    CGFloat viewHeight = imageHeight + labelHeight;
    CGFloat viewWidth = labelWidth;
    CGFloat btnMaxHeight = 1.0f;
    for (NSInteger i = 0;i< [titleArray count];i++)
    {
        UIView *btnView = [[UIView alloc] init];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goDetectioController:)];
        [btnView addGestureRecognizer:tapGesture];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(10, 1, imageWidth, imageHeight)];
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, imageHeight, labelWidth, labelHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"STHeitiTC-Light" size: 13];
        label.textColor = [UIColor blackColor];
        [btnView addSubview:imageView];
        [btnView addSubview:label];
        
        btnView.tag = i;
        btnView.frame = CGRectMake(width/2+(i%3)*width+((i%3)*labelWidth), 30+(i/3)*(viewWidth + 30), viewWidth, viewHeight);
        label.text = titleArray[i];
        imageView.image = [UIImage imageNamed: imageArray[i]];
        [contentView addSubview:btnView];
        btnMaxHeight = CGRectGetMaxY(btnView.frame);
    }
    contentView.frame = CGRectMake(0, CGRectGetMaxY(headerView.frame), MainScreenWidth, btnMaxHeight+10);
    contentView.tag = 100;
    contentView.pagingEnabled = YES;
    contentView.layer.masksToBounds = NO;
//    [contentView setContentSize:CGSizeMake(MainScreenWidth + width+viewWidth, 0)];
    [myScrollView addSubview:contentView];

    
    CGFloat imageW = 50;
    CGFloat imageX = 30;
    stepView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame)+10, MainScreenWidth, imageW)];
    stepView.tag = 1000;
    stepView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *stepTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goHealthStepTap:)];
    [stepView addGestureRecognizer:stepTapGesture];
    [myScrollView addSubview:stepView];
    
    //动画
    NSMutableArray * animationArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 8;i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"running0%d",i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [animationArray addObject:image];
        }
    }
    animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, 0, imageW, imageW)];
    animationImageView.animationImages = animationArray;
    animationImageView.animationDuration = 0.5;
    animationImageView.animationRepeatCount = 0;
    animationImageView.image = animationArray[0];
    [stepView addSubview:animationImageView];
    
    CGFloat runCountLabelW = CGRectGetWidth(self.view.frame)/2 - imageX-10;
    CGFloat runCountLabelX = CGRectGetMaxX(animationImageView.frame) + 5;
    runCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(runCountLabelX, 0, runCountLabelW, imageW)];
    runCountLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-UltraLight" size: 20];
    runCountLabel.textColor = RGB(102,102,102);
    runCountLabel.textAlignment = NSTextAlignmentCenter;
    [stepView addSubview:runCountLabel];
    
    NSMutableArray * heartAnimationArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 18;i++)
    {
        NSString *imageName = @"";
        if (i>= 10) {
            imageName = [NSString stringWithFormat:@"heart%d",i];
        }
        else
        {
            imageName = [NSString stringWithFormat:@"heart0%d",i];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [heartAnimationArray addObject:image];
        }
    }
    heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(runCountLabel.frame)+10, 10, 100, 40)];
    heartImageView.animationImages = heartAnimationArray;
    heartImageView.animationDuration = 2.5;
    heartImageView.animationRepeatCount = 0;
    //    heartImageView.image = heartAnimationArray[0];
    [stepView addSubview:heartImageView];
    
    [myScrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(stepView.frame)+5)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击方法
- (void)goDetectioController:(UITapGestureRecognizer *)tap{
    UITapGestureRecognizer *tempTap = (UITapGestureRecognizer *)tap;
    UIView *view = (UIView *)tempTap.view;
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    switch (view.tag) {
        case 0:
        {
            [TalkingData trackEvent:@"2100002" label:@"首页>心率测量"];
            HeartRateDetectioViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"HeartRateDetectioViewController"];
            workGradeViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:workGradeViewController animated:YES];
        }
            break;
        case 1:
        {
            [TalkingData trackEvent:@"2100003" label:@"首页>血压测量"];
            BloodPressureDetectioViewController *bloodPressureDetectioViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodPressureDetectioViewController"];
            bloodPressureDetectioViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:bloodPressureDetectioViewController animated:YES];
        }
            break;
        case 2:
        {
            [TalkingData trackEvent:@"2100009" label:@"首页>血糖录入"];
            BloodSugarViewController *bloodSugarViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodSugarViewController"];
            bloodSugarViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:bloodSugarViewController animated:YES];
        }
            break;
        case 3:
        {
            [TalkingData trackEvent:@"2100005" label:@"首页>视力测试"];
            EyeTestViewController *eyeTestViewController = [sboard instantiateViewControllerWithIdentifier:@"EyeTestViewController"];
            eyeTestViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:eyeTestViewController animated:YES];
        }
            break;
        case 4:
        {
            [TalkingData trackEvent:@"2100006" label:@"首页>肺活量测量"];
            VitalCapacityViewController *vitalCapacityViewController = [sboard instantiateViewControllerWithIdentifier:@"VitalCapacityViewController"];
            
//            VitalCapacityResultViewController *vitalCapacityViewController = [sboard instantiateViewControllerWithIdentifier:@"VitalCapacityResultViewController"];
//            vitalCapacityViewController.markValue = 3922;
            vitalCapacityViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vitalCapacityViewController animated:YES];
        }
            break;
        case 5:
        {
            [TalkingData trackEvent:@"2100007" label:@"首页>血氧测试"];
            BloodOxygenViewController *bloodOxygenView = [sboard instantiateViewControllerWithIdentifier:@"BloodOxygenViewController"];
            bloodOxygenView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:bloodOxygenView animated:YES];
        }
            break;
//            case 6:
//        {
//            [TalkingData trackEvent:@"2100010" label:@"首页>体脂测试"];
//            BodyDataViewController *bloodOxygenView = [sboard instantiateViewControllerWithIdentifier:@"BodyDataViewController"];
//            bloodOxygenView.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:bloodOxygenView animated:YES];
//        }
//            break;
        case 10:
        case 11:
        {
            [TalkingData trackEvent:@"2100001" label:@"首页>快速体检"];
            MedicallyExaminedViewController *bloodOxygenView = [sboard instantiateViewControllerWithIdentifier:@"MedicallyExaminedViewController"];
            bloodOxygenView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:bloodOxygenView animated:YES];
        }
            break;
        default:
            break;
    }
    
}

-(void)goHealthStepTap:(UITapGestureRecognizer *)tap{
    UITapGestureRecognizer *tempTap = (UITapGestureRecognizer *)tap;
    UIView *view = (UIView *)tempTap.view;
    if (view.tag == 1000) {
        [TalkingData trackEvent:@"2100008" label:@"首页>计步"];
        UIStoryboard *sboard = [KMTools getStoryboardInstance];
        HealthStepViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"HealthStepViewController"];
        workGradeViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:workGradeViewController animated:YES];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
}

#pragma mark - GIF动画
//第一次启动的出场动画
- (void)imageAnimationController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fisrtOpen];
    });
}

- (void)fisrtOpen
{
    NSMutableArray * suspendArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 18;i++)
    {
        NSString *imageName = @"";
        if (i<10) {
            imageName = [NSString stringWithFormat:@"open0%d",i];
        }else
        {
            imageName = [NSString stringWithFormat:@"open%d",i];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [suspendArray addObject:image];
        }
    }
    UIImageView *suspendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    suspendImageView.center = headerView.center;
    suspendImageView.animationImages = suspendArray;//
    suspendImageView.animationDuration = 3;//
    suspendImageView.animationRepeatCount = 1;//
    [suspendImageView startAnimating];
    [self homeAnimating];
    [self performSelector:@selector(clearAnimationImages) withObject:nil afterDelay:3];
    [myScrollView addSubview:suspendImageView];
}

-(void)clearAnimationImages
{
    homeImageView.hidden = NO;
    [UIView animateWithDuration:1.5
                     animations:^(void) {
                         hudLabel.alpha = 1.f;
                     } completion:^(BOOL completed) {
                     }];
}

//眨眼睛的
- (void)homeAnimating
{
    NSMutableArray * suspendArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 18;i++)
    {
        NSString *imageName = @"";
        if (i<10) {
            imageName = [NSString stringWithFormat:@"home0%d",i];
        }else
        {
            imageName = [NSString stringWithFormat:@"home%d",i];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [suspendArray addObject:image];
        }
    }
    homeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    homeImageView.center = waterCenter;
    homeImageView.animationImages = suspendArray;
    homeImageView.animationDuration = 2.8;
    homeImageView.animationRepeatCount = 0;
    homeImageView.image = suspendArray[0];
    [homeImageView startAnimating];
    homeImageView.hidden = YES;
    //    homeImageView.backgroundColor = [UIColor whiteColor];
    homeImageView.tag = 10;
    homeImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goDetectioController:)];
    [homeImageView addGestureRecognizer:tapGesture];
    [myScrollView addSubview:homeImageView];
}

#pragma mark - fristOpenVC
-(void)fristOpenApp
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *maskview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)];
    maskview.backgroundColor = RGBA(0, 0, 0, 0.5);
    maskview.tag = 3000;
    [window addSubview:maskview];
    
    CGFloat labelHeight = 40;
    CGFloat touxiangHeight = 95;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0, (MainScreenHeight-300)/2, MainScreenWidth, 300)];
    view.layer.cornerRadius = labelHeight/2;
    
    UIImageView *touxiangBG = [[UIImageView alloc] initWithFrame: CGRectMake(MainScreenWidth/2, 0, touxiangHeight, touxiangHeight)];
    touxiangBG.image = [UIImage imageNamed:@"guide_touxiang"];
//    touxiangBG.contentMode = UIViewContentModeScaleAspectFill;
    [view addSubview:touxiangBG];
    
    UIImageView *wenzBG = [[UIImageView alloc] initWithFrame: CGRectMake((MainScreenWidth-280)/2, touxiangHeight+5, 280, 140)];
    wenzBG.image = [UIImage imageNamed:@"guide_wenz"];
//    wenzBG.contentMode = UIViewContentModeCenter;
    [view addSubview:wenzBG];
    
    UIImageView *okBtn = [[UIImageView alloc] initWithFrame: CGRectMake((MainScreenWidth/2-77)/2 , CGRectGetMaxY(wenzBG.frame)+20, 77, 30)];
    okBtn.image = [UIImage imageNamed:@"guide_btn1"];
    okBtn.tag = 3001;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissMask:)];
    okBtn.userInteractionEnabled = YES;
    [okBtn addGestureRecognizer:tapGesture];
    [view addSubview:okBtn];
    
    UIImageView *noBtn = [[UIImageView alloc] initWithFrame: CGRectMake(MainScreenWidth/2, CGRectGetMaxY(wenzBG.frame)+20, 132, 30)];
    noBtn.image = [UIImage imageNamed:@"guide_btn2"];
    noBtn.tag = 3002;
    noBtn.userInteractionEnabled = YES;
    [view addSubview:noBtn];
    UITapGestureRecognizer *noTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissMask:)];
    [noBtn addGestureRecognizer:noTapGesture];
    
    [maskview addSubview:view];
    

}

- (void)dismissMask:(UITapGestureRecognizer *)tap
{
    UIView *view = (UIView *)tap.view;
    NSInteger tag = view.tag;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    for (UIView *elem in window.subviews) {
        if (elem.tag == 3000) {
            [UIView animateWithDuration:0.3
                             animations:^(void) {
                                 elem.alpha = 0.f;
                             } completion:^(BOOL completed) {
                                 while ([elem.subviews lastObject] != nil) {
                                     [(UIView*)[elem.subviews lastObject] removeFromSuperview];
                                 }
                                 [elem removeFromSuperview];
                                 if (tag!= 3002)
                                 {
                                     UITabBarController *vc =  (UITabBarController *)window.rootViewController;
                                     [vc setSelectedIndex:2];
                                 }
                             }];
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FirstGoHome"];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}

#pragma mark - 获取行走步数
- (void)getHealthAuthorization
{
    HealthKitManage *manage = [HealthKitManage shareInstance];
    [manage getStepCountFromDate:[NSDate date] completion:^(double value, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            runCountLabel.text = [NSString stringWithFormat:@"%li 步",(long)value];
        });
    }];
}

#pragma mark - 圆形波纹
- (void)closeAnimationTimer
{
    [animationTimer invalidate];
    animationTimer = nil;
}

- (void)clickAnimation:(id)sender {
    __block GFWaterView *circularWaterView = [[GFWaterView alloc]initWithFrame:CGRectMake((MainScreenWidth-WaterViewWidth)/2, (CGRectGetHeight(headerView.frame)-WaterViewWidth)/2, WaterViewWidth, WaterViewWidth)];
    circularWaterView.backgroundColor = [UIColor clearColor];
    circularWaterView.userInteractionEnabled = YES;
    circularWaterView.tag = 11;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goDetectioController:)];
    [circularWaterView addGestureRecognizer:tapGesture];
    [headerView addSubview:circularWaterView];
    
    [UIView animateWithDuration:2 animations:^{
        circularWaterView.transform = CGAffineTransformScale(circularWaterView.transform, 2, 2);
        circularWaterView.alpha = 0;
    } completion:^(BOOL finished) {
        [circularWaterView removeGestureRecognizer:tapGesture];
        [circularWaterView removeFromSuperview];
    }];
    
}

#pragma mark - 3D Touch Peek, Pop 代理方法
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    CGPoint p = [contentView convertPoint:location fromView:myScrollView];
    for (UIView *elem in contentView.subviews)
    {
        if (CGRectContainsPoint(elem.frame, p)) {
            CGFloat rectY = elem.frame.origin.y+CGRectGetMinY(contentView.frame)-myScrollView.contentOffset.y;
            previewingContext.sourceRect =CGRectMake(elem.frame.origin.x-contentView.contentOffset.x, rectY, elem.frame.size.width, elem.frame.size.height);
            UIStoryboard *sboard = [KMTools getStoryboardInstance];
            switch (elem.tag) {
                case 0:
                {
                    if (!cameraStatus) {
                        return nil;
                    }
                    [TalkingData trackEvent:@"2100002" label:@"首页>心率测量"];
                    HeartRateDetectioViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"HeartRateDetectioViewController"];
                    return workGradeViewController;
                }
                    break;
                case 1:
                {
                    if (!cameraStatus) {
                        return nil;
                    }
                    [TalkingData trackEvent:@"2100003" label:@"首页>血压测量"];
                    BloodPressureDetectioViewController *bloodPressureDetectioViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodPressureDetectioViewController"];
                    return bloodPressureDetectioViewController;
                }
                    break;
                case 2:
                {
                    [TalkingData trackEvent:@"2100009" label:@"首页>血糖录入"];
                    BloodSugarViewController *bloodSugarViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodSugarViewController"];
                    return bloodSugarViewController;
                }
                    break;
                case 3:
                {
                    [TalkingData trackEvent:@"2100005" label:@"首页>视力测试"];
                    EyeTestViewController *eyeTestViewController = [sboard instantiateViewControllerWithIdentifier:@"EyeTestViewController"];
                    return eyeTestViewController;
                }
                    break;
                case 4:
                {
                    [TalkingData trackEvent:@"2100006" label:@"首页>肺活量测量"];
                    VitalCapacityViewController *vitalCapacityViewController = [sboard instantiateViewControllerWithIdentifier:@"VitalCapacityViewController"];
                    return vitalCapacityViewController;
                }
                    break;
                case 5:
                {
                    if (!cameraStatus) {
                        return nil;
                    }
                    [TalkingData trackEvent:@"2100007" label:@"首页>血氧测试"];
                    BloodOxygenViewController *bloodOxygenView = [sboard instantiateViewControllerWithIdentifier:@"BloodOxygenViewController"];
                    return bloodOxygenView;
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    CGPoint y = [stepView convertPoint:location fromView:myScrollView];
    for (UIView *elem in stepView.subviews)
    {
        if (CGRectContainsPoint(elem.frame, y)) {
            [TalkingData trackEvent:@"2100008" label:@"首页>计步"];
            previewingContext.sourceRect = CGRectMake(stepView.frame.origin.x, stepView.frame.origin.y-myScrollView.contentOffset.y, stepView.frame.size.width, stepView.frame.size.height);
            UIStoryboard *sboard = [KMTools getStoryboardInstance];
            HealthStepViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"HealthStepViewController"];
            return workGradeViewController;
        }
    }
    return NULL;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [self showViewController:viewControllerToCommit sender:self];
}

- (void)touchGotoVc:(NSNotification *)noti {
    NSString *type = noti.userInfo[@"type"];
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    KMUIViewController *VC;
    [self.navigationController popToRootViewControllerAnimated:NO];
    if ([type isEqualToString:@"1"]) {
        VC = [sboard instantiateViewControllerWithIdentifier:@"HeartRateDetectioViewController"];
        
    } else if ([type isEqualToString:@"2"]) {
        VC = [sboard instantiateViewControllerWithIdentifier:@"BloodPressureDetectioViewController"];
        
    }
    VC.hidesBottomBarWhenPushed = YES;
    [self showViewController:VC sender:self];
    
}
@end
