//
//  VitalCapacityViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/18.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "VitalCapacityViewController.h"
#import "VitalCapacityResultViewController.h"
#import "HeartLive.h"

@interface VitalCapacityViewController ()

@end

@implementation VitalCapacityViewController


- (void)dealloc
{
    liveHeart = nil;
    [audioTimer invalidate];
    audioTimer = nil;
    [listener stop];
    [listener destorySingletion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"肺活量测量";
    self.view.backgroundColor = [UIColor whiteColor];
    listener = [SCListener sharedListener];
    [self initControllerViewAndData];
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
    isGoResult = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [audioTimer invalidate];
    audioTimer = nil;
    [listener pause];
    [self clearLive];
    [self stopAllAnimating];
}

- (void)initControllerViewAndData
{
    [self initRefresMoniterPoint];
    CGFloat staetButtonH = 50;
    liveHeart = [[HeartLive alloc] initWithFrame:CGRectMake(0, MainScreenHeight-200, MainScreenWidth, 50)];
    liveHeart.backgroundColor = [UIColor whiteColor];
    liveHeart.hidden = YES;
    [self.view addSubview: liveHeart];
    
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.backgroundColor = AppColor;
    startButton.frame = CGRectMake(50, CGRectGetMidY(liveHeart.frame)-staetButtonH/2, MainScreenWidth - 100, staetButtonH);
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [startButton setTitle: @"开始测量" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startVitalCapacityTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    startButton.layer.cornerRadius = staetButtonH/2;
    [self.view addSubview:startButton];
    [self initAnimatedData];
}

- (void)initAnimatedData
{
    CGFloat bgWidth = 150;
    CGFloat arrowHeight = 31;
    arrowBG = [[UIImageView alloc] initWithFrame:CGRectMake(MainScreenWidth/5, MainScreenHeight-kStatusAndNavHeight-arrowHeight-10, 25, arrowHeight)];
    arrowBG.image = [UIImage imageNamed:@"vitalcapacity_down_bg"];
    [self.view addSubview:arrowBG];
    
    NSMutableArray * skirtArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 2; i < 8;i++)
    {
        NSString *imageName = @"";
        if (i< 10) {
            imageName = [NSString stringWithFormat:@"vitalcapacity0%d",i];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [skirtArray addObject:image];
        }
    }
    skirtBG = [[UIImageView alloc] initWithFrame:CGRectMake((MainScreenWidth-bgWidth)/2, bgWidth/2, bgWidth, bgWidth)];
    skirtBG.image = [UIImage imageNamed:@"vitalcapacity01"];
    skirtBG.animationImages = skirtArray;
    skirtBG.animationDuration = 1.5;
    skirtBG.animationRepeatCount = 0;
    [self.view addSubview:skirtBG];

    
    NSMutableArray * stopArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 7; i < 10;i++)
    {
        NSString *imageName = @"";
        if (i== 10) {
            imageName = [NSString stringWithFormat:@"vitalcapacity%d",i];
        }
        else
        {
            imageName = [NSString stringWithFormat:@"vitalcapacity0%d",i];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [stopArray addObject:image];
        }
    }
    stopBG = [[UIImageView alloc] initWithFrame:skirtBG.frame];
    stopBG.animationImages = stopArray;
    stopBG.animationDuration = 0.5;
    stopBG.animationRepeatCount = 1;
    [self.view addSubview:stopBG];
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(skirtBG.frame)+(iPhone5?50:100), MainScreenWidth-60, 100)];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.text = @"深吸一口气后,对准手机下端麦克风吹气";
    valueLabel.font = [UIFont fontWithName:@"Avenir-Light" size:15];
    [self.view addSubview:valueLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -动画
- (void)stopAllAnimating
{
    if (isGoResult) {
        return;
    }
    [skirtBG stopAnimating];
    skirtBG.animationImages = nil;
    [stopBG stopAnimating];
    stopBG.animationImages = nil;
}

- (void)judgeVitalCapacity:(CGFloat)average
{
    if (average>0.25) {
        if (![skirtBG isAnimating])
        {
            valueLabel.text = @"深吸一口气后,对准手机下端麦克风吹气";
            [stopBG stopAnimating];
            [skirtBG startAnimating];
            markValue = 0;
        }
    }
    else if (average < 0.25 && lastValue<0.15)
    {
        if ([skirtBG isAnimating])
        {
            [skirtBG stopAnimating];
            if (markValue>=800)
            {
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                VitalCapacityResultViewController *vitalCapacityResultViewController = [sboard instantiateViewControllerWithIdentifier:@"VitalCapacityResultViewController"];
                vitalCapacityResultViewController.markValue = markValue;
//                NSLog(@"%li",(long)vitalCapacityResultViewController.markValue);
                [self.navigationController pushViewController:vitalCapacityResultViewController animated:YES];
                markValue = 0;
                lastValue = 0;
                [self startVitalCapacityTestBtn:nil];
                isGoResult = YES;
                return;
            }
            else
            {
                [stopBG startAnimating];
                valueLabel.text = @"不要停，继续吹 (๑•ㅂ•)و✧";
            }
        }
    }
    markValue +=average*35;
    lastValue = average;
}

#pragma mark - 
-(void)startVitalCapacityTestBtn:(UIButton *)button
{
    if (![listener isListening]) {
         [listener listen];
        audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(valueTimer:) userInfo:nil repeats:YES];
        [audioTimer fire];
        liveHeart.hidden = NO;
        startButton.hidden = YES;
        [TalkingData trackEvent:@"210000601" label:@"肺活量测量>开始测量"];
    }
    else
    {
        [listener pause];
        [audioTimer invalidate];
        audioTimer = nil;
        [self clearLive];
        liveHeart.hidden = YES;
        startButton.hidden = NO;
    }
}

#pragma mark - 定时器
- (void)valueTimer:(NSTimer *)timer
{
    if (![listener isListening]) // If listener has paused or stopped…
    {
        [listener listen];
    }
    AudioQueueLevelMeterState *levels = [listener levels];
    Float32 average = levels[0].mAveragePower;
    [self timerTranslationFun];
    if(!vitalCapacityArray)
        vitalCapacityArray = [NSMutableArray new];
    NSNumber * number = @(average*35);
    [vitalCapacityArray insertObject:number atIndex:0];
    while(vitalCapacityArray.count >2)
        [vitalCapacityArray removeLastObject];
    [self judgeVitalCapacity:average];
}

#pragma mark -
- (void)clearLive
{
    [self initRefresMoniterPoint];
    [liveHeart stopDrawing];
    [vitalCapacityArray removeAllObjects];
}

- (void)initRefresMoniterPoint
{
    xCoordinateInMoniter = 0;
}

- (void)timerTranslationFun
{
    [[PointContainer sharedContainer] addPointAsTranslationChangeform:[self bubbleRefreshPoint:YES]];
    [[PointContainer sharedContainer] addPointAsTranslationChangeform:[self bubbleRefreshPoint:NO]];
    [liveHeart fireDrawingWithPoints:[PointContainer sharedContainer].translationPointContainer pointsCount:[PointContainer sharedContainer].numberOfTranslationElements];
}

- (CGPoint)bubbleRefreshPoint:(BOOL)yesOrNo
{
    if ([vitalCapacityArray count] == 0) {
        return  (CGPoint){xCoordinateInMoniter,50};
    }
    NSInteger pixelPerPoint = 1;
    NSInteger yCoordinateInMoniter = 50-[vitalCapacityArray[0] integerValue];
    yCoordinateInMoniter = yCoordinateInMoniter>50?20:yCoordinateInMoniter;
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,yesOrNo?yCoordinateInMoniter:50};
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(CGRectGetWidth(liveHeart.frame));
    return targetPointToAdd;
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
