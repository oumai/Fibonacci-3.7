//
//  HeartRateDetectioViewController.m
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/24.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "HeartRateDetectioViewController.h"
#import "HeartLive.h"
#import "HeartView.h"
#import "HeartBackgroundView.h"
#import "DetectioResultViewController.h"
#import "CoreCameraDetection.h"
#import "HelpViewController.h"

@interface HeartRateDetectioViewController ()
@property (nonatomic,strong) NSTimer *heartTimer;       //心率图定时器
@property (nonatomic,strong) NSTimer *heartValueTimer;  // 圆圈定时器
@property (nonatomic,strong) HeartLive *refreshMoniterView; //心率图
@property (nonatomic,strong) HeartBackgroundView *heartBackgroundView;  //圆形
//@property (nonatomic,strong) HeartView *heartView;  //心形
@end

@implementation HeartRateDetectioViewController

- (void)dealloc
{
    [self timerClose];
    coreCameraDetection.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心率测量";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initHelpButton:@selector(goHelpVC)];
    coreCameraDetection = [CoreCameraDetection sharedCoreCameraDetection];
    coreCameraDetection.delegate = self;
    [self getFirstOpenValue];
    [self initViewData];
    [KMTools getMediaAuthStatus:self];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!onceHeartRateHelp) {
        [self goHelpVC];
        [self setFisrtOpenValue];
    }
    [self getNetHeartRateRecord];
    isGoHelp = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [coreCameraDetection detectionStopRunning];
    if (!isGoHelp)
    {
        [self otherClose];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!isGoHelp)
    {
        [self stopAllImageAnimating];
    }
}

- (void)initViewData
{
    CGFloat headerViewWidth = 250;
    headerView = [[UIView alloc] initWithFrame:CGRectMake((MainScreenWidth-headerViewWidth)/2, 50, headerViewWidth, headerViewWidth)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    
    _heartBackgroundView = [[HeartBackgroundView alloc] initWithFrame:CGRectMake(0, 0, headerViewWidth, headerViewWidth) ];
    [_heartBackgroundView setLineWidth:6.f];
    [_heartBackgroundView setLineColr:[UIColor redColor]];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopTest:)];
    [headerView addGestureRecognizer:tapGesture];
    
    [headerView addSubview:_heartBackgroundView];

    CGFloat sumLabelY = CGRectGetMidY(_heartBackgroundView.frame)-30;
    sumLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(_heartBackgroundView.frame) -90, sumLabelY, 120, 50)];
//    sumLabel.textColor = [KMTools colorWithHexString:@"52A448"];
    sumLabel.textColor = RGB(96, 104, 140);
    sumLabel.font = [UIFont systemFontOfSize: 65];
    sumLabel.text = @"000";
    sumLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:sumLabel];
    
    UILabel* bmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sumLabel.frame), CGRectGetMinY(sumLabel.frame), 60, 50)];
    bmpLabel.textColor = [UIColor grayColor];
    bmpLabel.font = [UIFont systemFontOfSize: 20];
    bmpLabel.text = @"BPM";
    bmpLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:bmpLabel];
    
    CGFloat imageWidth = 100;
    NSMutableArray * suspendArray = [[NSMutableArray alloc] initWithCapacity:0];
    BOOL arrayOther = NO;
    for (int i = 1; i < 10;i++)
    {
        NSString *imageName = @"";
        imageName = [NSString stringWithFormat:@"home0%d",i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [suspendArray addObject:image];
        }
        if (!arrayOther&& i == 9) {
            i = 4;
            arrayOther = YES;
        }
    }
    suspendView = [[UIImageView alloc] initWithFrame:CGRectMake((headerViewWidth-imageWidth)/2, CGRectGetMaxY(sumLabel.frame), imageWidth, imageWidth)];
    suspendView.animationImages = suspendArray;//
    suspendView.animationDuration = 2.0;//
    suspendView.animationRepeatCount = 0;//
    [suspendView startAnimating];
    [headerView addSubview:suspendView];
    
    //
    NSMutableArray * jumpArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 6;i++)
    {
        NSString *imageName = @"";
        imageName = [NSString stringWithFormat:@"jump0%d",i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [jumpArray addObject:image];
        }
    }
    jumpView = [[UIImageView alloc] initWithFrame:suspendView.frame];
    //    suspendImageView.contentMode = UIViewContentModeScaleToFill;
    jumpView.animationImages = jumpArray;//
    jumpView.animationDuration = 0.7;//
    jumpView.animationRepeatCount = 0;//
    jumpView.hidden = YES;
    [headerView addSubview:jumpView];
    
    [self.view addSubview: self.refreshMoniterView];
    
    hudLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame)+40, MainScreenWidth, 40)];
    hudLabel.text = @"用手指将摄像头完全覆盖";
    hudLabel.textAlignment = NSTextAlignmentCenter;
    hudLabel.textColor = RGB(96, 104, 140);
    [self.view addSubview:hudLabel];
    
    CGFloat staetButtonH = 50;
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.backgroundColor = AppColor;
    startButton.frame = CGRectMake(50, CGRectGetMidY(_refreshMoniterView.frame)-staetButtonH/2, MainScreenWidth - 100, staetButtonH);
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [startButton setTitle: @"开始测量" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    startButton.layer.cornerRadius = staetButtonH/2;
    [self.view addSubview:startButton];
}

- (void)getNetHeartRateRecord
{
    NSDictionary *dic = GET_PHYSICALRECOID;
    NSDictionary *resultDic = [dic objectForKey:@"result"];
    NSArray *array = [resultDic objectForKey:@"心率"];
    netHeartRateValue = [[array lastObject] integerValue];
}

#pragma mark -开关按钮
-(void)stopTest:(UITapGestureRecognizer *)tap
{
    if ([coreCameraDetection cameraRunningStatus])
    {
        [self stopJumpImageAnimating];
        [self otherClose];
        [coreCameraDetection detectionStopRunning];
    }
}

- (void)startTestBtn:(id)sender
{
    if (![coreCameraDetection cameraRunningStatus]&&[KMTools getMediaAuthStatus:self])
    {
        [TalkingData trackEvent:@"210000201" label:@"心率测量>开始测量"];
        [self startJumpImageAnimating];
        hudLabel.hidden = YES;
        startButton.hidden = YES;
        coreCameraDetection.timerCount = 15;
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timerRefresnFun) userInfo:nil repeats:YES];
        self.heartValueTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(animate) userInfo:nil repeats:YES];
        [self.heartValueTimer fire];
        [self.heartTimer fire];
        [coreCameraDetection detectionStartRunning];
    }
}

#pragma mark -动画
-(void)animate
{
    //1/60/10
    CGFloat timerValue = coreCameraDetection.timerCount;
    CGFloat value = 1/timerValue/10;
    if (currntTimer < coreCameraDetection.timerCount/3)
    {
        value = value/2;
    }
    else if (currntTimer > coreCameraDetection.timerCount/3*2)
    {
        value = value*2;
    }
    _heartBackgroundView.value += value;
}

-(void)startJumpImageAnimating
{
    [suspendView stopAnimating];
    suspendView.hidden = YES;
    
    jumpView.hidden = NO;
    [jumpView startAnimating];
}

-(void)stopJumpImageAnimating
{
    suspendView.hidden = NO;
    [suspendView startAnimating];
    
    [jumpView stopAnimating];
    jumpView.hidden = YES;
}

-(void)stopAllImageAnimating
{
    [jumpView stopAnimating];
    jumpView.animationImages = nil;
    [suspendView stopAnimating];
    suspendView.animationImages = nil;
}

#pragma mark -
//定时执行方法
- (void)timerClose
{
    [self.heartTimer invalidate];
    self.heartTimer = nil;
    [self.heartValueTimer invalidate];
    self.heartValueTimer = nil;
}

-(void)otherClose
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        _heartView.strokeColor = [UIColor grayColor];
        [_heartBackgroundView closeStroke];
        hudLabel.hidden = NO;
        startButton.hidden = NO;
        [self clearLive];
    });
    [self timerClose];
}


#pragma mark - MemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化属性

- (HeartLive *)refreshMoniterView
{
    if (!_refreshMoniterView) {
        CGFloat heightOffset = 150;
        CGFloat yOffset = CGRectGetMaxY(headerView.frame)+(MainScreenHeight - CGRectGetMaxY(headerView.frame)-heightOffset)/2;
        _refreshMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(0, yOffset, CGRectGetWidth(self.view.frame), heightOffset)];
        _refreshMoniterView.backgroundColor = [UIColor whiteColor];
    }
    return _refreshMoniterView;
}

#pragma mark - _refreshMoniterView DataSource
- (void)initRefresMoniterPoint
{
    xCoordinateInMoniter = 0;
}

- (void)clearLive
{
    [self initRefresMoniterPoint];
    [_refreshMoniterView stopDrawing];
    [points removeAllObjects];
}
//把心跳数值转换为坐标
- (CGPoint)bubbleRefreshPoint
{
    CGFloat liveHeight = CGRectGetHeight(_refreshMoniterView.frame);
    NSInteger pixelPerPoint = 2;
    if (![points count]) {
        return (CGPoint){xCoordinateInMoniter, liveHeight/2};
    }
    CGFloat pointY= [points[0]floatValue];
    if (-10<pointY&&pointY<10) {
        pointY = 0;
    }
    pointY = (liveHeight/2 - pointY);
    if (pointY<0)
    {
        pointY = 1;
    }
    else if (pointY > liveHeight)
    {
        pointY = liveHeight-1;
    }
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,pointY};
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(CGRectGetWidth(_refreshMoniterView.frame));
    return targetPointToAdd;
}

//刷新方式绘制
- (void)timerRefresnFun
{
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    [_refreshMoniterView fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];
}

#pragma mark - CoreCameraDetection Delegate
-(void)cameraDetection:(CoreCameraDetection *)cameraDetection didOutputSampleErrorCount:(NSUInteger)errorCount
{
    if (errorCount ==1) {
       [SVProgressHUD showErrorWithStatus: @"请将手指覆盖摄像头"];
    }
    else if(errorCount == 2)
    {
        [SVProgressHUD dismiss];
        [self otherClose];
        [self stopJumpImageAnimating];
    }
}

-(void)cameraDetection:(CoreCameraDetection* )cameraDetection didOutputSamplePassValue:(float)passValue
{
    if(!points)
        points = [NSMutableArray new];
    NSNumber * number = @(passValue*300);
    [points insertObject:number atIndex:0];
    while(points.count > 10)
        [points removeLastObject];

}

-(void)cameraDetection:(CoreCameraDetection* )cameraDetection didOutputSampleHeartCount:(NSUInteger)heartCount andTimerCount:(NSUInteger)timerCount
{
    NSInteger displayValue;
    if (netHeartRateValue > 5) {
        displayValue = [KMTools getRandomFrome:netHeartRateValue-5 to:netHeartRateValue+5];
    }
    else
    {
        displayValue  = heartCount;
    }
    sumLabel.text = [NSString stringWithFormat:@"%li",(long)displayValue];
    currntTimer = timerCount;
    if (timerCount >= cameraDetection.timerCount) {
        [cameraDetection closeDetectionTimer];
        [self stopJumpImageAnimating];
        [self otherClose];
        [self goResultVC:displayValue];
    }
}

- (void)goResultVC:(NSInteger)count
{
    if (coreCameraDetection.delegate == nil) {
        return;
    }
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    DetectioResultViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"DetectioResultViewController"];
    workGradeViewController.sumCount = count;
    workGradeViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:workGradeViewController animated:YES];
    isGoHelp = YES;
}

#pragma mark - 帮助页面
-(void)goHelpVC
{
    [self stopTest:nil];
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    HelpViewController *helpViewController = [sboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewController.helpType = EPageHelpTypeNone;
    helpViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:helpViewController animated:YES];
    isGoHelp = YES;
}

- (void)getFirstOpenValue
{
    NSString *firstEyeValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"FirstGoHeartRate"];
    if ([firstEyeValue isEqualToString:@""])
    {
        onceHeartRateHelp = YES;
    }
}

- (void)setFisrtOpenValue
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FirstGoHeartRate"];
    onceHeartRateHelp = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
