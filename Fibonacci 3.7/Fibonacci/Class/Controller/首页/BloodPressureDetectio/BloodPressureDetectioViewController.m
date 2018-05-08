//
//  BloodPressureDetectioViewController.m
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/31.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "BloodPressureDetectioViewController.h"
#import "HeartLive.h"
#import "HeartBackgroundView.h"
#import "BloodDetectioResultViewController.h"
#import "HelpViewController.h"

@interface BloodPressureDetectioViewController ()

@end

@implementation BloodPressureDetectioViewController

- (void)dealloc
{
    [self bloodPressureTimerClose];
    bloodPressureLiveView = nil;
    coreCameraDetection.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"血压测量";
    [self initHelpButton:@selector(goHelpVC)];
    coreCameraDetection = [CoreCameraDetection sharedCoreCameraDetection];
    coreCameraDetection.delegate = self;
    [self getFirstOpenValue];
    [self initRefresMoniterPoint];
    [self initControllerView];
    [KMTools getMediaAuthStatus:self];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getNetBloodPressureRecord];
    if (!onceBPHelpPage) {
        [self goHelpVC];
        [self setFisrtOpenValue];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [SVProgressHUD dismiss];
    [coreCameraDetection detectionStopRunning];
    [self bloodPressureTimerClose];
}

- (void)initControllerView
{
    UIView *bloodPressuerHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, 300)];
    bloodPressuerHeader.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bloodPressuerHeader];
    
    CGFloat circularWidth = 140;
    CGFloat valueLabelWidth = 80;
    CGFloat circularX = (MainScreenWidth-circularWidth*2)/3;
    for (int i = 0; i < 2; i ++)
    {
        circularX = circularX + i*(circularX+circularWidth);
        HeartBackgroundView *circularView =[[HeartBackgroundView alloc] initWithFrame:CGRectMake(circularX, 100, circularWidth, circularWidth)];
        [circularView setLineWidth:5.f];
        [circularView setLineColr:[UIColor redColor]];
        [bloodPressuerHeader addSubview: circularView];
        
        CGFloat valueLabelX = (CGRectGetMaxX(circularView.frame)-circularX-valueLabelWidth)/2+circularX;
        UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueLabelX, CGRectGetMinY(circularView.frame)+(circularWidth-40)/3, valueLabelWidth, 35)];
        valueLabel.text = @"0 0 0";
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.font = [UIFont systemFontOfSize:30];
        valueLabel.textColor = RGB(96, 104, 140);
//        valueLabel.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:valueLabel];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(valueLabelX, CGRectGetMaxY(valueLabel.frame)-5, valueLabelWidth, 30)];
        label.text = i>0?@"低压/mmHg":@"高压/mmHg";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor grayColor];
        [self.view addSubview:label];
        
        if (i == 0) {
            heightPressureView = circularView;
            heightLabel = valueLabel;
        }
        else
        {
            lowPressureView = circularView;
            lowLabel = valueLabel;
        }
    }
    
    CGFloat heightOffset = 150;
    CGFloat yOffset = CGRectGetMaxY(bloodPressuerHeader.frame)+(MainScreenHeight - CGRectGetMaxY(bloodPressuerHeader.frame)-heightOffset)/2;
    bloodPressureLiveView = [[HeartLive alloc] initWithFrame:CGRectMake(0, yOffset, MainScreenWidth, heightOffset)];
    bloodPressureLiveView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: bloodPressureLiveView];
    
     hudLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bloodPressuerHeader.frame)+40, MainScreenWidth, 40)];
     hudLabel.text = @"用手指将摄像头完全覆盖";
     hudLabel.textAlignment = NSTextAlignmentCenter;
     hudLabel.textColor = RGB(96, 104, 140);
     [self.view addSubview:hudLabel];
     
     CGFloat staetButtonH = 50;
     startButton = [UIButton buttonWithType:UIButtonTypeCustom];
     startButton.backgroundColor = AppColor;
     startButton.frame = CGRectMake(50, CGRectGetMidY(bloodPressureLiveView.frame)-staetButtonH/2, MainScreenWidth - 100, staetButtonH);
     [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [startButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
     [startButton setTitle: @"开始测量" forState:UIControlStateNormal];
     [startButton addTarget:self action:@selector(startTestBtn:) forControlEvents:UIControlEventTouchUpInside];
     startButton.layer.cornerRadius = staetButtonH/2;
     [self.view addSubview:startButton];
}

- (void)getNetBloodPressureRecord
{
    NSDictionary *dic = GET_PHYSICALRECOID;
    NSDictionary *resultDic = [dic objectForKey:@"result"];
    NSArray *DPArray = [resultDic objectForKey:@"舒张压"];
    NSArray *SPArray = [resultDic objectForKey:@"收缩压"];
    netDPValue = [[DPArray lastObject] integerValue];
    netSPValue = [[SPArray lastObject] integerValue];
    if ((netSPValue-netDPValue)<10) {
        souceDataError = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)startTestBtn:(id)sender
{
    if (![coreCameraDetection cameraRunningStatus]&&[KMTools getMediaAuthStatus:self])
    {
        [TalkingData trackEvent:@"210000301" label:@"血压测量>开始测量"];
        startButton.hidden = YES;
        hudLabel.hidden = YES;
        circularTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(bloodPressureAnimate) userInfo:nil repeats:YES];
        circularLiveTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(bloodPressureTimerRefresnFun) userInfo:nil repeats:YES];
        coreCameraDetection.timerCount = 15;
        [coreCameraDetection detectionStartRunning];
    }
}
-(void)stopBloodPressureTest
{
    if ([coreCameraDetection cameraRunningStatus])
    {
        [self bloodPressureOtherClose];
        [coreCameraDetection detectionStopRunning];
    }
}

- (void)bloodPressureOtherClose
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [heightPressureView closeStroke];
        [lowPressureView closeStroke];
        [self clearLive];
        startButton.hidden = NO;
        hudLabel.hidden = NO;
    });
    [self bloodPressureTimerClose];
}

- (void)bloodPressureTimerClose
{
    [circularLiveTimer invalidate];
    circularLiveTimer = nil;
    [circularTimer invalidate];
    circularTimer = nil;
}

-(void)bloodPressureAnimate
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
    heightPressureView.value += value;
    lowPressureView.value += value;
}

#pragma mark -
- (void)initRefresMoniterPoint
{
    xCoordinateInMoniter = 0;
}

- (void)clearLive
{
    [self initRefresMoniterPoint];
    [bloodPressureLiveView stopDrawing];
    [bloodPressureArray removeAllObjects];
}

//刷新方式绘制
- (void)bloodPressureTimerRefresnFun
{
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    [bloodPressureLiveView fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];    
}

//把心跳数值转换为坐标
- (CGPoint)bubbleRefreshPoint
{
    CGFloat liveHeight = CGRectGetHeight(bloodPressureLiveView.frame);
    NSInteger pixelPerPoint = 2;
    if (![bloodPressureArray count]) {
        return (CGPoint){xCoordinateInMoniter, liveHeight/2};
    }
    CGFloat pointY= [bloodPressureArray[0]floatValue];
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
    xCoordinateInMoniter %= (int)(CGRectGetWidth(bloodPressureLiveView.frame));
    return targetPointToAdd;
}

#pragma mark - CoreCameraDetectionDelagate
-(void)cameraDetection:(CoreCameraDetection *)cameraDetection didOutputSampleErrorCount:(NSUInteger)errorCount
{
    if (errorCount ==1) {
        [SVProgressHUD showErrorWithStatus: @"请将手指覆盖摄像头"];
    }
    else if(errorCount == 2)
    {
        [SVProgressHUD dismiss];
        [self bloodPressureOtherClose];
        startButton.hidden = NO;
        hudLabel.hidden = NO;
    }
}

-(void)cameraDetection:(CoreCameraDetection* )cameraDetection didOutputSamplePassValue:(float)passValue
{
    if(!bloodPressureArray)
        bloodPressureArray = [NSMutableArray new];
    NSNumber * number = @(passValue*500);
    [bloodPressureArray insertObject:number atIndex:0];
    while(bloodPressureArray.count > 10)
        [bloodPressureArray removeLastObject];
}

-(void)cameraDetection:(CoreCameraDetection* )cameraDetection didOutputSampleHeartCount:(NSUInteger)heartCount andTimerCount:(NSUInteger)timerCount
{
    if (netDPValue>5)
    {
        if (souceDataError) {
            heightLabel.text = [NSString stringWithFormat:@"%li",[KMTools getRandomFrome:netSPValue to:netSPValue+5]];
            lowLabel.text = [NSString stringWithFormat:@"%li",[KMTools getRandomFrome:netDPValue-5 to:netDPValue]];
        }
        else
        {
            heightLabel.text = [NSString stringWithFormat:@"%li",[KMTools getRandomFrome:netSPValue-5 to:netSPValue+5]];
            lowLabel.text = [NSString stringWithFormat:@"%li",[KMTools getRandomFrome:netDPValue-5 to:netDPValue+5]];
        }
    }
    else
    {
        heightLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[KMTools getSystolicPressure:heartCount]];
        lowLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[KMTools getDiatolicPressure:heartCount]];
    }
    currntTimer = timerCount;
    if (timerCount >= cameraDetection.timerCount) {
        [cameraDetection closeDetectionTimer];
        [self bloodPressureOtherClose];
        [self goBloodResultVC];
    }
}

- (void)goBloodResultVC
{
    if (coreCameraDetection.delegate == nil) {
        return;
    }
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    BloodDetectioResultViewController *bloodDetectioResultViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodDetectioResultViewController"];
    bloodDetectioResultViewController.systolicPressure = [heightLabel.text integerValue];
    bloodDetectioResultViewController.diatolicPressure = [lowLabel.text integerValue];
    [self.navigationController pushViewController:bloodDetectioResultViewController animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 帮助页面
-(void)goHelpVC
{
    [self stopBloodPressureTest];
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    HelpViewController *helpViewController = [sboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    helpViewController.helpType = EPageHelpTypeNone;
    helpViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:helpViewController animated:YES];
    
}

- (void)getFirstOpenValue
{
    NSString *firstEyeValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"FirstGoBloodPressure"];
    if ([firstEyeValue isEqualToString:@""])
    {
        onceBPHelpPage = YES;
    }
}

- (void)setFisrtOpenValue
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"FirstGoBloodPressure"];
    onceBPHelpPage = YES;
}
@end
