//
//  BloodOxygenResultViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/22.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "BloodOxygenResultViewController.h"
#import "HeartView.h"
#import "DetectioResultView.h"
#import "ManuallyEnteredViewController.h"
#import "ShareCustom.h"
#import "AppDelegate+BATShare.h"
#import "HTMLViewController.h"
#import "BATNewDrKangViewController.h"

#define DetectioHeartViewHeightAndWidth 35
#define HeightHeartRate 105 //设定显示的最大值
#define LowHeartRate 90 //设定显示的最小值
@interface BloodOxygenResultViewController ()

@end

static const NSTimeInterval TIDetectioResultViewControllerHeartMoveInterval = 1.0;


@implementation BloodOxygenResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试结果";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KMDataManager sharedDatabaseInstance] insertBloodOxygenDataModelFromNumber:[NSNumber numberWithInteger:_bloodOxygenValue]];
    });
    
    [self initBloodOxygenResultViewAndData];
    [self getBloodOxygenHeartMoveY];
    

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateForheartMove];
}

- (void)initBloodOxygenResultViewAndData
{
    CGFloat labelMinY = 50;
    if(iPhone5)
    {
        labelMinY = 20;
    }
    UILabel *bloodOxygenResultLabel = [[UILabel alloc] initWithFrame:CGRectMake((MainScreenWidth- 70)/2, labelMinY, 80, 50)];
    bloodOxygenResultLabel.textColor = [UIColor redColor];
    bloodOxygenResultLabel.font = [UIFont systemFontOfSize: 50];
    bloodOxygenResultLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_bloodOxygenValue];
    bloodOxygenResultLabel.textAlignment = NSTextAlignmentCenter;
//    bloodOxygenResultLabel.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:bloodOxygenResultLabel];
    
    UILabel *unitLabel  = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bloodOxygenResultLabel.frame), CGRectGetMaxY(bloodOxygenResultLabel.frame)-30, 50, 25)];
    unitLabel.textColor = [UIColor grayColor];
    unitLabel.font = [UIFont fontWithName:@"Avenir-Light" size:25];
    unitLabel.text = @"%";
    unitLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:unitLabel];
    
    CGFloat DetectioResultViewWidth = MainScreenWidth - 50; //色彩渐变条的宽度
    CGFloat detectioHeartViewStartX = (25-DetectioHeartViewHeightAndWidth/2); //心的起始Y
    
    bloodOxygenHeartView = [[HeartView alloc]initWithFrame:CGRectMake(detectioHeartViewStartX, CGRectGetMaxY(bloodOxygenResultLabel.frame)+(iPhone5?50:60), DetectioHeartViewHeightAndWidth, DetectioHeartViewHeightAndWidth)];
    bloodOxygenHeartView.lineWidth = 0.1;
    bloodOxygenHeartView.strokeColor = [UIColor redColor];
    bloodOxygenHeartView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bloodOxygenHeartView];
    
    DetectioResultView *bloodOxygenResultView = [[DetectioResultView alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(bloodOxygenHeartView.frame), DetectioResultViewWidth, 12)];
    bloodOxygenResultView.backgroundColor = [UIColor whiteColor];
    bloodOxygenResultView.layer.cornerRadius = 7.0;
    bloodOxygenResultView.layer.masksToBounds = YES;
    [self.view addSubview:bloodOxygenResultView];

    
    CGFloat labelW = DetectioResultViewWidth/4;
    NSArray *textArray = @[@"<90",@"90-95",@"95-100",@">100"];
    for (int i = 0; i <4; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelW*i+25, CGRectGetMaxY(bloodOxygenResultView.frame), labelW, 30)];
        label.text = textArray[i];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:14];;
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
    hudLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(bloodOxygenResultView.frame)+(iPhone5?35:50), MainScreenWidth-60, 100)];
    hudLabel.textAlignment = NSTextAlignmentCenter;
    hudLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    [self.view addSubview:hudLabel];
    hudLabel.text = @"身体不错呦(╯▽╰)";
    
    NSString *eval = @"";
    NSString *proposalStr = @"";
    if (_bloodOxygenValue < 90) {
        eval = @"3";
        hudLabel.text = @"血氧严重偏低";
        proposalStr = @"您的血氧严重偏低，请及时吸氧，同时注意休息，调整好状态并复查血氧。如果复查结果仍为血氧严重偏低，请及时就医诊疗。";
    }
    else if (_bloodOxygenValue < 95)
    {
        hudLabel.text = @"血氧偏低";
        eval = @"2";
        proposalStr = @"您的血氧偏低，请注意休息，清淡饮食，稳定情绪，调整好状态并复查血氧。";
    }
    else if (_bloodOxygenValue < 100)
    {
        hudLabel.text = @"血氧正常";
        eval = @"1";
        proposalStr = @"您的血氧正常，请予保持。";

    }
    shareURL = [NSString stringWithFormat:@"%@//app/#/testShare?type=oxygen&val=%li&eval=%@",BAT_WECHAT_Web_URL,_bloodOxygenValue,eval];

    [[NSUserDefaults standardUserDefaults] setValue:proposalStr forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CGFloat buttonH = 40;
    CGFloat buttonW = (MainScreenWidth - 100)/2;
    
    UIButton *accuracyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accuracyButton.frame = CGRectMake(MainScreenWidth/2-20-buttonW, CGRectGetMaxY(hudLabel.frame)+40, buttonW, buttonH);
    accuracyButton.backgroundColor = AppColor;
    [accuracyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accuracyButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [accuracyButton setTitle: @"手动校准" forState:UIControlStateNormal];
    accuracyButton.layer.cornerRadius = buttonH/2;
    [accuracyButton addTarget:self action:@selector(accuracyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accuracyButton];
    
    UIButton *kangButton = [UIButton buttonWithType:UIButtonTypeCustom];
    kangButton.frame = CGRectMake(MainScreenWidth/2+20, CGRectGetMaxY(hudLabel.frame)+40, buttonW, buttonH);
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

- (void)getBloodOxygenHeartMoveY
{
    CGFloat DetectioResultViewWidth = MainScreenWidth - 50; //色彩渐变条的宽度
    CGFloat pixelY = DetectioResultViewWidth/(HeightHeartRate-LowHeartRate);  //每个心跳需要移动的坐标
    CGFloat detectioHeartViewStartX = (25-DetectioHeartViewHeightAndWidth/2); //心的起始Y
    if (_bloodOxygenValue <=LowHeartRate)
    {
        _bloodOxygenValue = LowHeartRate;
    }
    else if (_bloodOxygenValue >=HeightHeartRate)
    {
        _bloodOxygenValue = HeightHeartRate;
    }
    bloodOxygenResultHeartViewY = (_bloodOxygenValue - LowHeartRate)*pixelY + detectioHeartViewStartX;
    if (bloodOxygenResultHeartViewY>(DetectioResultViewWidth+detectioHeartViewStartX))
    {
        bloodOxygenResultHeartViewY = DetectioResultViewWidth+detectioHeartViewStartX;
    }
    else if (bloodOxygenResultHeartViewY< detectioHeartViewStartX)
    {
        bloodOxygenResultHeartViewY = detectioHeartViewStartX;
    }
}

- (void)animateForheartMove
{
    [UIView animateWithDuration:TIDetectioResultViewControllerHeartMoveInterval
                     animations:^(void) {
                         CGRect heartFrame = bloodOxygenHeartView.frame;
                         heartFrame.origin.x = bloodOxygenResultHeartViewY;
                         bloodOxygenHeartView.frame = heartFrame;
                     } completion:^(BOOL completed) {
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)accuracyButton:(UIButton *)button
{
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    ManuallyEnteredViewController *helpViewController = [sboard instantiateViewControllerWithIdentifier:@"ManuallyEnteredViewController"];
    helpViewController.hidesBottomBarWhenPushed = YES;
    helpViewController.enteredType = EEnteredBloodOxygenType;
    [self.navigationController pushViewController:helpViewController animated:YES];
}

-(void)shareButton:(UIButton*)button
{
    [TalkingData trackEvent:@"210000702" label:@"测量结果页>分享"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"share_icon"]];
    if (imageArray)
    {
        NSString *paramsText = [NSString stringWithFormat:@"%@!%@",hudLabel.text,shareURL];
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
    healthDataVC.recordWebType = ERecordWebTypeOxygen;
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
