//
//  MedicallyExaminedViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/23.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "MedicallyExaminedViewController.h"
#import "ExaminedResultViewController.h"
#import "HelpViewController.h"
#import "HeartBackgroundView.h"
#import "HeartLive.h"
@interface MedicallyExaminedViewController ()

@end

@implementation MedicallyExaminedViewController
- (void)dealloc
{
    [self clearExaminedLive];
    examinedValueLive = nil;
    coreCameraDetection.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"快速体检";
    [self getFirstOpenValue];
    [self initHeartBackgroundView];
    [self initHelpButton:@selector(goHelpVC)];
    coreCameraDetection = [CoreCameraDetection sharedCoreCameraDetection];
    coreCameraDetection.delegate = self;
    [KMTools getMediaAuthStatus:self];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!onceMEHelpPage) {
        [self goHelpVC];
        [self setFisrtOpenValue];
    }
    [self getNetRecordValue];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [SVProgressHUD dismiss];
    [coreCameraDetection detectionStopRunning];
    [self otherExaminedClose];
}

- (void)initHeartBackgroundView
{
    CGFloat circularWidth = iPhone5?90:120;
    CGFloat valueLabelWidth = iPhone5?70:80;
    CGFloat circularViewH = iPhone5?240:300;
    UIView *circularView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, circularViewH)];
    circularView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:circularView];

    for (int i = 0; i< 4; i++)
    {
        CGFloat circularX = (MainScreenWidth-circularWidth*2)/3;
        circularX = circularX +circularX*(i%2) + (i%2)*circularWidth;
        
        CGFloat circularY = (circularViewH-circularWidth*2)/3;
        circularY = circularY+(i/2)*circularWidth+(i/2)* circularY;
        HeartBackgroundView *view = [[HeartBackgroundView alloc] initWithFrame:CGRectMake(circularX, circularY, circularWidth, circularWidth)];
        [view setLineWidth:5.f];
        [view setLineColr:[UIColor redColor]];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startExaminedTestTap:)];
        [view addGestureRecognizer:tapGesture];
        
        [circularView addSubview:view];
        CGFloat valueLabelX = (CGRectGetMaxX(view.frame)-circularX-valueLabelWidth)/2+circularX;
        UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueLabelX, CGRectGetMinY(view.frame)+(circularWidth-40)/3, valueLabelWidth, 35)];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.font = [UIFont systemFontOfSize:20];
        valueLabel.textColor =  RGB(96, 104, 140);
        [circularView addSubview:valueLabel];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(valueLabelX, CGRectGetMaxY(valueLabel.frame)-10, valueLabelWidth, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:iPhone5?12:13];
        label.textColor = [UIColor grayColor];
        [circularView addSubview:label];
        switch (i) {
            case 0:
            {
                label.text = @"心率/BPM";
                HeartRateView = view;
                heartRateLabel = valueLabel;
            }
                break;
            case 1:
            {
                label.text = @"血氧%";
                bloodOxygenView = view;
                bloodOxygenLabel = valueLabel;
            }
                break;
            case 2:
            {
                label.text = @"高压/mmHg";
                HPressureView = view;
                HPressureLabel = valueLabel;
            }
                break;
            case 3:
            {
                label.text = @"低压/mmHg";
                LPressureView = view;
                LPressureLabel = valueLabel;
            }
                break;
                
            default:
                break;
        }
        valueLabel.text = i==1?@"0 0 0":@"0 0";
    }
    
    hudLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(circularView.frame)+(iPhone5?30:40), MainScreenWidth, 40)];
    hudLabel.text = @"用手指将摄像头完全覆盖";
    hudLabel.textAlignment = NSTextAlignmentCenter;
    hudLabel.textColor = RGB(96, 104, 140);
    [self.view addSubview:hudLabel];
    
    CGFloat heightOffset = iPhone5?120:150;
    CGFloat yOffset = CGRectGetMaxY(circularView.frame)+(MainScreenHeight - CGRectGetMaxY(circularView.frame)-heightOffset)/2;
    examinedValueLive = [[HeartLive alloc] initWithFrame:CGRectMake(0, yOffset, CGRectGetWidth(self.view.frame), heightOffset)];
    examinedValueLive.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: examinedValueLive];
    
    CGFloat staetButtonH = iPhone5?35:50;
    startExaminedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startExaminedButton.backgroundColor = AppColor;
    startExaminedButton.frame = CGRectMake(50, CGRectGetMidY(examinedValueLive.frame)-staetButtonH/2, MainScreenWidth - 100, staetButtonH);
    [startExaminedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startExaminedButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [startExaminedButton setTitle: @"开始测量" forState:UIControlStateNormal];
    [startExaminedButton addTarget:self action:@selector(startExaminedTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    startExaminedButton.layer.cornerRadius = staetButtonH/2;
    [self.view addSubview:startExaminedButton];    
}

- (void)getNetRecordValue
{
    NSDictionary *dic = GET_PHYSICALRECOID;
    NSDictionary *resultDic = [dic objectForKey:@"result"];
    NSArray *heartRateArray = [resultDic objectForKey:@"心率"];
    netHeartRateValue = [[heartRateArray lastObject] integerValue];

    NSArray *SPArray = [resultDic objectForKey:@"舒张压"];
    netDPValue = [[SPArray lastObject] integerValue];

    NSArray *DPArray = [resultDic objectForKey:@"收缩压"];
    netSPValue = [[DPArray lastObject] integerValue];
    if ((netSPValue-netDPValue)<10) {
        souceDataError = YES;
    }
    NSArray *bloodOxygenArray = [resultDic objectForKey:@"血氧"];
    netBloodOxygenValue = [[bloodOxygenArray lastObject] integerValue];
}

#pragma mark - 点击方法
- (void)startExaminedTestTap:(UITapGestureRecognizer *)tap
{
    if ([coreCameraDetection cameraRunningStatus])
    {
        [self otherExaminedClose];
        [self setExaminedValueLabelTextColor:RGB(96, 104, 140)];
        [coreCameraDetection detectionStopRunning];
    }
}

- (void)startExaminedTestBtn:(id)sender
{
    if (![coreCameraDetection cameraRunningStatus]&&[KMTools getMediaAuthStatus:self])
    {
        [TalkingData trackEvent:@"210000101" label:@"快速体检>开始测量"];
        hudLabel.hidden = YES;
        startExaminedButton.hidden = YES;
        coreCameraDetection.timerCount = 15;

        [self setExaminedValueLabelTextColor: [UIColor redColor]];

        examinedTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timerRefresnFun) userInfo:nil repeats:YES];
        examinedLiveTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(animate) userInfo:nil repeats:YES];
        [examinedTimer fire];
        [examinedLiveTimer fire];
        [coreCameraDetection detectionStartRunning];
    }
}

#pragma mark -动画
-(void)animate
{
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
    LPressureView.value += value;
    HeartRateView.value = bloodOxygenView.value = HPressureView.value = LPressureView.value;
}

#pragma mark -
-(void)setExaminedValueLabelTextColor:(UIColor *)color
{
    HPressureLabel.textColor = bloodOxygenLabel.textColor = heartRateLabel.textColor = LPressureLabel.textColor = color;
}

-(void)closeExaminedViewValue
{
    [LPressureView closeStroke];
    [HPressureView closeStroke];
    [bloodOxygenView closeStroke];
    [HeartRateView closeStroke];
}

//定时执行方法
- (void)timerExaminedClose
{
    [examinedTimer invalidate];
    examinedTimer = nil;
    [examinedLiveTimer invalidate];
    examinedLiveTimer = nil;
}

-(void)otherExaminedClose
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self  closeExaminedViewValue];
        startExaminedButton.hidden = NO;
        hudLabel.hidden = NO;
        [self setExaminedValueLabelTextColor:RGB(96, 104, 140)];
        [self clearExaminedLive];
    });
    [self timerExaminedClose];
}

#pragma mark - RefreshMoniterView DataSource
-(void)initExaminedRefresMoniterPoint
{
    xCoordinateExaminedInMoniter = 0;
}

-(void)clearExaminedLive
{
    [self initExaminedRefresMoniterPoint];
    [examinedValueLive stopDrawing];
    [examinedArray removeAllObjects];
}

//把心跳数值转换为坐标
- (CGPoint)bubbleRefreshPoint
{
    CGFloat liveHeight = CGRectGetHeight(examinedValueLive.frame);
    NSInteger pixelPerPoint = 2;
    if (![examinedArray count]) {
        return (CGPoint){xCoordinateExaminedInMoniter, liveHeight/2};
    }
    CGFloat pointY= [examinedArray[0]floatValue];
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
    CGPoint targetPointToAdd = (CGPoint){xCoordinateExaminedInMoniter,pointY};
    xCoordinateExaminedInMoniter += pixelPerPoint;
    xCoordinateExaminedInMoniter %= (int)(CGRectGetWidth(examinedValueLive.frame));
    return targetPointToAdd;
}

//刷新方式绘制
- (void)timerRefresnFun
{
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    [examinedValueLive fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];
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
        [self otherExaminedClose];
    }
}

-(void)cameraDetection:(CoreCameraDetection* )cameraDetection didOutputSamplePassValue:(float)passValue
{
    if(!examinedArray)
        examinedArray = [NSMutableArray new];
    NSNumber * number = @(passValue*300);
    [examinedArray insertObject:number atIndex:0];
    while(examinedArray.count > 10)
        [examinedArray removeLastObject];
    
}

-(void)cameraDetection:(CoreCameraDetection* )cameraDetection didOutputSampleHeartCount:(NSUInteger)heartCount andTimerCount:(NSUInteger)timerCount
{
    //血氧
    if (netBloodOxygenValue > 5) {
        NSInteger value = [KMTools getRandomFrome:netBloodOxygenValue-5 to:netBloodOxygenValue+5];
        if (value> 99) {
            value = 99;
        }
        bloodOxygenLabel.text = [NSString stringWithFormat:@"%li",(long)value];
    }
    else
    {
        bloodOxygenLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[KMTools heartCountTransformationSPO2H:heartCount]];
    }
    //心率
    if (netHeartRateValue > 5) {
        heartRateLabel.text = [NSString stringWithFormat:@"%li",(long)[KMTools getRandomFrome:netHeartRateValue-5 to:netHeartRateValue+5]];
    }
    else
    {
        heartRateLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)heartCount];
    }
    // 血压
    if (netSPValue > 5) {
        if (souceDataError)
        {
            HPressureLabel.text  = [NSString stringWithFormat:@"%li",(long)[KMTools getRandomFrome:netSPValue to:netSPValue+5]];
            LPressureLabel.text = [NSString stringWithFormat:@"%li",( long)[KMTools getRandomFrome:netDPValue-5 to:netDPValue]];
        }
        else
        {
            HPressureLabel.text = [NSString stringWithFormat:@"%li",(long)[KMTools getRandomFrome:netSPValue-5 to:netSPValue+5]];
            LPressureLabel.text = [NSString stringWithFormat:@"%li",(long)[KMTools getRandomFrome:netDPValue-5 to:netDPValue+5]];
        }
    }
    else
    {
        HPressureLabel.text  = [NSString stringWithFormat:@"%lu",(unsigned long)[KMTools getSystolicPressure:heartCount]];
        LPressureLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[KMTools getDiatolicPressure:heartCount]];
    }
    currntTimer = timerCount;
    if (timerCount >= coreCameraDetection.timerCount)
    {
        [cameraDetection closeDetectionTimer];
        [self otherExaminedClose];
        [self goResultVC];
    }
}

#pragma mark - 计算收缩压和舒张压

- (void)goResultVC
{
    if (coreCameraDetection.delegate == nil) {
        return;
    }
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    ExaminedResultViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"ExaminedResultViewController"];
    workGradeViewController.heartRateValue = [heartRateLabel.text integerValue];
    workGradeViewController.bloodOxygenValue = [bloodOxygenLabel.text integerValue];
    workGradeViewController.heightPressureValue = [HPressureLabel.text integerValue];
    workGradeViewController.lowPressureValue = [LPressureLabel.text integerValue];
    [self.navigationController pushViewController:workGradeViewController animated:YES];
}

#pragma mark - 帮助页面
-(void)goHelpVC
{
    [self startExaminedTestTap:nil];
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    HelpViewController *helpViewController = [sboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewController.hidesBottomBarWhenPushed = YES;
    helpViewController.helpType = EPageHelpTypeNone;
    [self.navigationController pushViewController:helpViewController animated:YES];
}

- (void)getFirstOpenValue
{
    NSString *firstEyeValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"FirstGoMedicallyExamined"];
    if ([firstEyeValue isEqualToString:@""])
    {
        onceMEHelpPage = YES;
    }
}

- (void)setFisrtOpenValue
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FirstGoMedicallyExamined"];
    onceMEHelpPage = YES;
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
