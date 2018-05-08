//
//  BloodDetectioResultViewController.m
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/31.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "BloodDetectioResultViewController.h"
#import "HeartBackgroundView.h"
#import "HelpViewController.h"
#import "ManuallyEnteredViewController.h"
#import "ShareCustom.h"
#import "AppDelegate+BATShare.h"
#import "HTMLViewController.h"
#import "BATNewDrKangViewController.h"

@interface BloodDetectioResultViewController ()

@end

static CGFloat strokeEndFloat = 0.85;
static CGFloat heightFloat = 139;
static CGFloat lowFloat = 90;


@implementation BloodDetectioResultViewController
@synthesize systolicPressure = _systolicPressure;
@synthesize diatolicPressure = _diatolicPressure;

-(void)dealloc
{
    [crazyView removeFromSuperview];
    crazyView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试结果";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KMDataManager sharedDatabaseInstance] insertBloodPressureDataModelFromSPNumber: [NSNumber numberWithInteger: _systolicPressure] andDPNumber:[NSNumber numberWithInteger: _diatolicPressure]];
    });
    [self setControllerView];
    [self calculationAverageAndSumValue];
//    animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(resultAnimate) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [animateTimer invalidate];
    animateTimer = nil;
    [crazyView stopAnimating];
    crazyView.animationImages = nil;
}

- (void)setControllerView
{
    CGFloat resultCircularWidth = 200;
    CGFloat resultValueLabelWidth = 130;
    CGFloat resultCircularX = (MainScreenWidth - resultCircularWidth)/2;
    CGFloat resultCircularY = 100;
    if(iPhone5)
    {
        resultCircularY = 50;
    }
    bloodResultView=[[HeartBackgroundView alloc] initWithFrame:CGRectMake(resultCircularX, resultCircularY, resultCircularWidth, resultCircularWidth) strokeEnd: strokeEndFloat transformType: HeartBackgroundViewTransformStatusLeft];
    [bloodResultView setLineWidth:9.f];
    [bloodResultView setLineColr:RGB(132, 193, 71)];
    [self.view addSubview: bloodResultView];
    
    CGFloat resultValueLabelX = (MainScreenWidth-resultValueLabelWidth)/2;
    UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(resultValueLabelX, CGRectGetMinY(bloodResultView.frame)+(resultCircularWidth-35)/2-10, resultValueLabelWidth, 35)];
    valueLabel.text = [NSString stringWithFormat:@"%li/%li",(long)_systolicPressure, (long)_diatolicPressure];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.font = [UIFont systemFontOfSize:30];
    valueLabel.textColor = [UIColor redColor];
    [self.view addSubview:valueLabel];
    
    UILabel* mmHgHudLabel = [[UILabel alloc] initWithFrame:CGRectMake(resultCircularX, CGRectGetMaxY(valueLabel.frame), resultCircularWidth, 15)];
    mmHgHudLabel.text = @"mmHg";
    mmHgHudLabel.textAlignment = NSTextAlignmentCenter;
    mmHgHudLabel.font = [UIFont systemFontOfSize:14];
    mmHgHudLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:mmHgHudLabel];
    
    
    CGFloat imageWidth = 50;
    CGFloat imageX = (MainScreenWidth - imageWidth)/2;
    crazyView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, CGRectGetMaxY(mmHgHudLabel.frame)+5, imageWidth, imageWidth)];
    crazyView.animationDuration = 0.7;
    crazyView.animationRepeatCount = 0;
    [self.view addSubview:crazyView];
    
    bloodHudLabel = [[UILabel alloc] initWithFrame:CGRectMake(resultCircularX, CGRectGetMaxY(crazyView.frame), resultCircularWidth, 35)];
    bloodHudLabel.textAlignment = NSTextAlignmentCenter;
    bloodHudLabel.font = [UIFont systemFontOfSize:16];
    bloodHudLabel.textColor = [UIColor redColor];
    [self.view addSubview:bloodHudLabel];

    NSString *imageNameStr = @"";
    NSString *eval = @"";
    NSString *proposalStr = @"";
     if (_systolicPressure<90)
    {
        bloodHudLabel.text = @"血压值偏低";
        imageNameStr = @"fail0";
        eval = @"3";
        proposalStr = @"请复查血压，必要时请于心内科就诊";
    }
    else if (_systolicPressure < 120)
    {
        bloodHudLabel.text = @"血压值正常";
        imageNameStr = @"crazy0";
        eval = @"1";
        proposalStr = @"您的血压正常，请予保持。";
    }
    else if (_systolicPressure < 130)
    {
        bloodHudLabel.text = @"正常高值血压";
        imageNameStr = @"fail0";
        eval = @"2";
        proposalStr = @"请复查血压，保持血压在正常范围";
    }
    else if (_systolicPressure < 140)
    {
        bloodHudLabel.text = @"正常高值血压";
        imageNameStr = @"fail0";
        eval = @"2";
        proposalStr = @"请复查血压，保持血压在正常范围";
    }
    else if (_systolicPressure < 160)
    {
        bloodHudLabel.text = @"1级高血压";
        imageNameStr = @"fail0";
        eval = @"4";
        proposalStr = @"请复查血压，必要时请于心内科就诊";
    }
    else if (_systolicPressure < 180)
    {
        bloodHudLabel.text = @"2级高血压";
        imageNameStr = @"fail0";
        eval = @"5";
        proposalStr = @"请复查血压，必要时请于心内科就诊";
    }
    else if (_systolicPressure >= 180)
    {
        bloodHudLabel.text = @"3级高血压";
        imageNameStr = @"fail0";
        eval = @"6";
        proposalStr = @"请复查血压，必要时请于心内科就诊";
    }
    shareURL = [NSString stringWithFormat:@"%@//app/#/testShare?type=pressure&val=%li/%li&eval=%@",BAT_WECHAT_Web_URL,_systolicPressure,_diatolicPressure,eval];

    [[NSUserDefaults standardUserDefaults] setValue:proposalStr forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableArray * crazyArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 5;i++)
    {
        NSString *imageName = @"";
        imageName = [NSString stringWithFormat:@"%@%d", imageNameStr, i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [crazyArray addObject:image];
        }
    }
    crazyView.animationImages = crazyArray;
    [crazyView startAnimating];

    CGFloat buttonH = 40;
    CGFloat buttonW = (MainScreenWidth - 100)/2;
    UIButton *accuracyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accuracyButton.frame = CGRectMake(MainScreenWidth/2-20-buttonW, CGRectGetMaxY(bloodResultView.frame)+40, buttonW, buttonH);
    accuracyButton.backgroundColor = AppColor;
    [accuracyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accuracyButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [accuracyButton setTitle: @"手动校准" forState:UIControlStateNormal];
    accuracyButton.layer.cornerRadius = buttonH/2;
    [accuracyButton addTarget:self action:@selector(accuracyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accuracyButton];
    
    UIButton *kangButton = [UIButton buttonWithType:UIButtonTypeCustom];
    kangButton.frame = CGRectMake(MainScreenWidth/2+20, CGRectGetMaxY(bloodResultView.frame)+40, buttonW, buttonH);
    kangButton.backgroundColor = RGB(253, 155, 71);
    [kangButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [kangButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [kangButton setTitle: @"咨询康博士" forState:UIControlStateNormal];
    [kangButton addTarget:self action:@selector(kangButton:) forControlEvents:UIControlEventTouchUpInside];
    kangButton.layer.cornerRadius = buttonH/2;
    [self.view addSubview:kangButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    shareButton.frame = CGRectMake(MainScreenWidth/2-20-buttonW, CGRectGetMaxY(accuracyButton.frame)+10, buttonW, buttonH);
    [shareButton setTitle: @"分享结果" forState:UIControlStateNormal];
    [shareButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [shareButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    UIButton *trendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    trendButton.frame = CGRectMake(MainScreenWidth/2+20, CGRectGetMaxY(accuracyButton.frame)+10, buttonW, buttonH);
    [trendButton setTitle: @"查看历史趋势" forState:UIControlStateNormal];
    [trendButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [trendButton addTarget:self action:@selector(trendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:trendButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, MainScreenHeight-kStatusAndNavHeight-40, MainScreenWidth, 40)];
    label.font = [UIFont fontWithName:AppFontHelvetica size:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = RGB(151, 151, 151);
    label.numberOfLines = 2;
    label.text = @"数据可能会存在一定范围的误差,测量结果仅供参考";
    [self.view addSubview:label];
}

-(void)calculationAverageAndSumValue
{
    averageValue = strokeEndFloat/(heightFloat-lowFloat);
    if (_systolicPressure >lowFloat&&_systolicPressure <heightFloat)
    {
        sumValue = (_systolicPressure - lowFloat);
    }
    else if (_systolicPressure <lowFloat)
    {
        sumValue = 0;
    }
    else if (_systolicPressure>heightFloat)
    {
        sumValue = heightFloat-lowFloat;
    }
    sumValue = sumValue*averageValue;
}

-(void)resultAnimate
{
    CGFloat value = averageValue;
    bloodResultView.value += value;
    if (bloodResultView.value >=sumValue) {
        bloodResultView.value = sumValue;
        [animateTimer invalidate];
        animateTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ButtonAction
-(void)accuracyButton:(UIButton *)button
{
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    ManuallyEnteredViewController *helpViewController = [sboard instantiateViewControllerWithIdentifier:@"ManuallyEnteredViewController"];
    helpViewController.hidesBottomBarWhenPushed = YES;
    helpViewController.enteredType = EEnteredBloodPressureType;
    [self.navigationController pushViewController:helpViewController animated:YES];
}

-(void)shareButton:(UIButton*)button
{
    [TalkingData trackEvent:@"210000302" label:@"测量结果页>分享"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"share_icon"]];
    if (imageArray)
    {
        NSString *paramsText = [NSString stringWithFormat:@"%@!%@", bloodHudLabel.text, shareURL];
        [shareParams SSDKSetupShareParamsByText:paramsText
                                         images:imageArray
                                            url:[NSURL URLWithString:shareURL]
                                          title:@"康美小管家"
                                           type:SSDKContentTypeAuto];
    }
    [ShareCustom shareWithContent:shareParams];
}

-(void)trendButton:(UIButton *)button
{
    HTMLViewController *healthDataVC = [[HTMLViewController alloc]init];
    healthDataVC.hidesBottomBarWhenPushed = YES;
    healthDataVC.recordWebType = ERecordWebTypeBloodPressure;
    [self.navigationController pushViewController:healthDataVC animated:YES];
}

-(void)kangButton:(UIButton *)button
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    BOOL isContains = NO;
    for (UIViewController *elem in marr ) {
        if ([elem isKindOfClass:[BATNewDrKangViewController class]]) {
            [self.navigationController popToViewController:elem animated:YES];
            isContains = YES;
        }
    }
    if (!isContains) {
        BATNewDrKangViewController *kangViewController = [[BATNewDrKangViewController alloc] init];
        kangViewController.measureType = EKangMeasureTypeBlood;
        [self.navigationController pushViewController:kangViewController animated:YES];
    }
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
