//
//  VitalCapacityResultViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/22.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "VitalCapacityResultViewController.h"
#import "DetectioResultView.h"
#import "HeartView.h"
#import "ManuallyEnteredViewController.h"
#import "ShareCustom.h"
#import "AppDelegate+BATShare.h"
#import "BATPerson.h"
#import "HTMLViewController.h"
#import "BATNewDrKangViewController.h"
@interface VitalCapacityResultViewController ()

@end

#define DetectioHeartViewHeightAndWidth 35
#define HeightHeartRate 5000 //设定显示的最大值
#define LowHeartRate 1 //设定显示的最小值

static const NSTimeInterval TIDetectioResultViewControllerHeartMoveInterval = 1.0;


@implementation VitalCapacityResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试结果";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KMDataManager sharedDatabaseInstance] insertVitalCapacityDataModelFromNumber:[NSNumber numberWithInteger:_markValue]];
    });
    [self initResultViewAndData];
    [self getHeartMoveY];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateForheartMove];
}

- (void)initResultViewAndData
{
    UILabel* heartResultLabel = [[UILabel alloc] initWithFrame:CGRectMake((MainScreenWidth- 140)/2, 50, 140, 50)];
    heartResultLabel.textColor = [UIColor redColor];
    heartResultLabel.font = [UIFont systemFontOfSize: 50];
    heartResultLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_markValue];
    heartResultLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:heartResultLabel];
    
    UILabel* HUDLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(heartResultLabel.frame) + 10, CGRectGetMaxY(heartResultLabel.frame)-30, 50, 25)];
    HUDLabel.textColor = [UIColor grayColor];
    HUDLabel.font = [UIFont fontWithName:@"Avenir-Light" size:15];
    HUDLabel.text = @"毫升";
    HUDLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:HUDLabel];
    
    CGFloat detectioHeartViewStartX = (25-DetectioHeartViewHeightAndWidth/2); //心的起始X
    CGFloat detectioHeartViewStartY = CGRectGetMaxY(heartResultLabel.frame)+(iPhone5?50:100);
    vitalCapacityHeartView = [[HeartView alloc]initWithFrame:CGRectMake(detectioHeartViewStartX, detectioHeartViewStartY, DetectioHeartViewHeightAndWidth, DetectioHeartViewHeightAndWidth)];
    vitalCapacityHeartView.lineWidth = 0.1;
    vitalCapacityHeartView.strokeColor = [UIColor redColor];
    vitalCapacityHeartView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:vitalCapacityHeartView];
    
    CGFloat DetectioResultViewWidth = MainScreenWidth - 50; //色彩渐变条的宽度
    DetectioResultView *detectioResultView = [[DetectioResultView alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(vitalCapacityHeartView.frame), DetectioResultViewWidth, 12)];
    detectioResultView.backgroundColor = [UIColor whiteColor];
    detectioResultView.layer.cornerRadius = 7.0;
    detectioResultView.layer.masksToBounds = YES;
    [self.view addSubview:detectioResultView];
    
    CGFloat labelW = DetectioResultViewWidth/4;
    NSArray *textArray = @[@"<1500",@"1500-2000",@"2500-4000",@">4000"];
    for (int i = 0; i <4; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelW*i+25, CGRectGetMaxY(detectioResultView.frame), labelW, 30)];
        label.text = textArray[i];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:14];;
        label.textAlignment = i>1?NSTextAlignmentRight:NSTextAlignmentLeft;
        [self.view addSubview:label];
    }
    UILabel *hudLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(detectioResultView.frame)+(iPhone5?35:50), MainScreenWidth-60, 100)];
    hudLabel.textAlignment = NSTextAlignmentCenter;
    hudLabel.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    [self.view addSubview:hudLabel];
    
    NSString *ageKey = @"";
    NSString *sexKey = @"";
    if (LOGIN_STATION)
    {
        BATPerson *person = PERSON_INFO;
        if (person.Data.Sex.length > 0)
        {
            NSLog(@"%@",person.Data.Birthday);
            sexKey =  person.Data.Sex;
            if (person.Data.Age > 0) {
                ageKey = [NSString stringWithFormat:@"%li",person.Data.Age];
            }
            else  if(person.Data.Birthday.length > 0)
            {
                NSDate *date = [KMTools getDateFromString:person.Data.Birthday dateFormat:@"YYYY-MM-dd HH:mm:ss"];
                ageKey = [KMTools dateToOld:date];
                
            }
            else if (person.Data.Birthdays.length > 0)
            {
                NSDate *date = [KMTools getDateFromString:person.Data.Birthdays dateFormat:@"YYYY-MM-dd HH:mm:ss"];
                ageKey = [KMTools dateToOld:date];
            }
        }
    }
    NSInteger value = 2500;
    if (ageKey.length > 0 &&sexKey.length > 0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"VitalCapacityValue" ofType:@"plist"];
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:filePath] ;
        NSString *sex = @"Male";
        if ([sexKey isEqualToString:@"0"]) {
            sex = @"Female";
        }
        NSDictionary *ageDic = [dic objectForKey:sex];
        if (![ageDic.allKeys containsObject:ageKey]) {
            if ([ageKey integerValue] <20) {
                ageKey = @"20";
            }
            else
            {
                ageKey = @"69";
            }
        }
        NSInteger integerValue = [[ageDic objectForKey:ageKey] integerValue];
        if (integerValue > 0) {
            value = integerValue;
        }
    }
    hudLabel.text = @"确定是用嘴吹的？";
    NSString *proposalStr = @"肺活量过小，建议积极参加体育活动，并进行专门锻炼，如深呼吸，吹气球等";
    NSString *eval = @"1";
    if (_markValue >= value) {
        hudLabel.text = @"身体不错呦(╯▽╰)";
        proposalStr = @"肺活量正常，建议保持";
        eval = @"2";
    }
    shareText = hudLabel.text;
    shareURL = [NSString stringWithFormat:@"%@//app/#/testShare?type=pulmonary&val=%li&eval=%@",BAT_WECHAT_Web_URL,_markValue,eval];

    [[NSUserDefaults standardUserDefaults] setValue:proposalStr forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];

    CGFloat buttonH = 40;
    CGFloat buttonW = (MainScreenWidth - 100)/2;
    UIButton *accuracyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    accuracyButton.frame = CGRectMake(MainScreenWidth/2-20-buttonW, CGRectGetMaxY(hudLabel.frame)+10, buttonW, buttonH);
    accuracyButton.backgroundColor = AppColor;
    [accuracyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accuracyButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [accuracyButton setTitle: @"手动校准" forState:UIControlStateNormal];
    accuracyButton.layer.cornerRadius = buttonH/2;
    [accuracyButton addTarget:self action:@selector(accuracyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accuracyButton];
    
    UIButton *kangButton = [UIButton buttonWithType:UIButtonTypeCustom];
    kangButton.frame = CGRectMake(MainScreenWidth/2+20, CGRectGetMaxY(hudLabel.frame)+10, buttonW, buttonH);
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
    
    UILabel *resultHUDLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MainScreenHeight-kStatusAndNavHeight-40, MainScreenWidth, 40)];
    resultHUDLabel.font = [UIFont fontWithName:AppFontHelvetica size:13];
    resultHUDLabel.textAlignment = NSTextAlignmentCenter;
    resultHUDLabel.textColor = RGB(151, 151, 151);
    resultHUDLabel.numberOfLines = 2;
    resultHUDLabel.text = @"数据可能会存在一定范围的误差,测量结果仅供参考";
    [self.view addSubview:resultHUDLabel];
}

//计算坐标
- (void)getHeartMoveY
{
    CGFloat DetectioResultViewWidth = MainScreenWidth - 50; //色彩渐变条的宽度
    CGFloat pixelY = DetectioResultViewWidth/(HeightHeartRate-LowHeartRate);  //每个心跳需要移动的坐标
    CGFloat detectioHeartViewStartX = (25-DetectioHeartViewHeightAndWidth/2); //心的起始Y
    if (_markValue<=LowHeartRate)
    {
        _markValue = LowHeartRate;
    }
    else if (_markValue >=HeightHeartRate)
    {
        _markValue = HeightHeartRate;
    }
    vitalCapacityHeartViewY = (_markValue - LowHeartRate)*pixelY + detectioHeartViewStartX;
    if (vitalCapacityHeartViewY>(DetectioResultViewWidth+detectioHeartViewStartX))
    {
        vitalCapacityHeartViewY = DetectioResultViewWidth+detectioHeartViewStartX;
    }
    else if (vitalCapacityHeartViewY< detectioHeartViewStartX)
    {
        vitalCapacityHeartViewY = detectioHeartViewStartX;
    }
}

- (void)animateForheartMove
{
    [UIView animateWithDuration:TIDetectioResultViewControllerHeartMoveInterval
                     animations:^(void) {
                         CGRect heartFrame = vitalCapacityHeartView.frame;
                         heartFrame.origin.x = vitalCapacityHeartViewY;
                         vitalCapacityHeartView.frame = heartFrame;
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
    helpViewController.enteredType = EEnteredVitalCapacityType;
    [self.navigationController pushViewController:helpViewController animated:YES];
}

-(void)shareButton:(UIButton*)button
{
    [TalkingData trackEvent:@"210000602" label:@"测量结果页>分享"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"share_icon"]];
    if (imageArray)
    {
        NSString *paramsText = [NSString stringWithFormat:@"%@ %@",shareText,shareURL];
        [shareParams SSDKSetupShareParamsByText:paramsText
                                         images:imageArray
                                            url:[NSURL URLWithString:shareURL]
                                          title:@"康美小管家"
                                           type:SSDKContentTypeAuto];
    }
    [ShareCustom shareWithContent:shareParams];
}

- (void)kangButton:(UIButton *)button
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
        kangViewController.measureType = EKangMeasureTypeVitalCapacity;
        //    kangViewController.proposalStr
        [self.navigationController pushViewController:kangViewController animated:YES];
    }
}

-(void)trendButton:(UIButton *)button
{
    HTMLViewController *healthDataVC = [[HTMLViewController alloc]init];
    healthDataVC.hidesBottomBarWhenPushed = YES;
    healthDataVC.recordWebType = ERecordWebTypeVitalCapacity;
    [self.navigationController pushViewController:healthDataVC animated:YES];
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
