//
//  DetectioResultViewController.m
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/26.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "DetectioResultViewController.h"
#import "DetectioResultView.h"
#import "HeartView.h"
#import "HelpViewController.h"
#import "ManuallyEnteredViewController.h"
#import "ShareCustom.h"
#import "AppDelegate+BATShare.h"
#import "HTMLViewController.h"
#import "BATNewDrKangViewController.h"
#define DetectioHeartViewHeightAndWidth 35

@interface DetectioResultViewController ()

@end

static const NSTimeInterval TIDetectioResultViewControllerHeartMoveInterval = 1.0;

@implementation DetectioResultViewController
@synthesize sumCount = _sumCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试结果";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KMDataManager sharedDatabaseInstance] insertHeartRateDataModelNumber:[NSNumber numberWithInteger:_sumCount]];
    });
    [self initControllerView];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)initControllerView
{
    CGFloat heartResultY = 50;
    if(iPhone5)
    {
        heartResultY = 20;
    }
    UILabel* heartResultLabel = [[UILabel alloc] initWithFrame:CGRectMake((MainScreenWidth- 100)/2-50, heartResultY, 100, 50)];
    heartResultLabel.textColor = [UIColor redColor];

    heartResultLabel.font = [UIFont systemFontOfSize: 50];
    heartResultLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_sumCount];
    heartResultLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:heartResultLabel];
    
    HeartView * heartView = [[HeartView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(heartResultLabel.frame) + 10, CGRectGetMinY(heartResultLabel.frame)+5, 23, 23)];
    heartView.lineWidth = 1;
    heartView.strokeColor = [UIColor redColor];
    heartView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:heartView];
    
    UILabel* HUDLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(heartResultLabel.frame) + 10, CGRectGetMaxY(heartView.frame)-5, 50, 25)];
    HUDLabel.textColor = [UIColor grayColor];
    HUDLabel.font = [UIFont systemFontOfSize: 18];
    HUDLabel.text = @"BMP";
    HUDLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:HUDLabel];
    
    CGFloat DetectioResultViewWidth = MainScreenWidth - 50; //色彩渐变条的宽度
    CGFloat detectioHeartViewStartX = (25-DetectioHeartViewHeightAndWidth/2); //心的起始Y
    CGFloat detectioHeartViewMinY = CGRectGetMaxY(heartResultLabel.frame)+50;
    if(iPhone5)
    {
        detectioHeartViewMinY = CGRectGetMaxY(heartResultLabel.frame)+20;
    }
    detectioHeartView = [[HeartView alloc]initWithFrame:CGRectMake(detectioHeartViewStartX, detectioHeartViewMinY, DetectioHeartViewHeightAndWidth, DetectioHeartViewHeightAndWidth)];
    detectioHeartView.lineWidth = 0.1;
    detectioHeartView.strokeColor = [UIColor redColor];
    detectioHeartView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:detectioHeartView];
    
    detectioResultView = [[DetectioResultView alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(detectioHeartView.frame), DetectioResultViewWidth, 12)];
    detectioResultView.backgroundColor = [UIColor whiteColor];
    detectioResultView.layer.cornerRadius = 7.0;
    detectioResultView.layer.masksToBounds = YES;
    [self.view addSubview:detectioResultView];
    
    [self setValueHUDLabelFromType:0];
    
    UILabel *textLable = [[UILabel alloc] initWithFrame:(CGRect){0,CGRectGetMaxY(detectioResultView.frame)+30+30, MainScreenWidth, 50}];
    textLable.backgroundColor = RGB(240, 240, 240);
    textLable.text = @"  本次测量时状态";
    textLable.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:textLable];
    
    NSArray *titleArray = @[@"休息",@"运动前",@"运动后",@"最大心率"];
    NSArray *imageArray = @[@"cardiograph_rest_icon", @"cardiograph_beforeexercise_icon", @"cardiograph_postexercise_icon", @"cardiograph_maximum_icon"];
    NSUInteger count = 4;
    CGFloat imageWidth = 35;
    CGFloat imageHeight = 35;
    CGFloat labelWidth = imageWidth +20;
    CGFloat labelHeight = 40;
    CGFloat width = (MainScreenWidth -count*labelWidth)/count;
    CGFloat viewHeight = imageHeight + labelHeight;
    CGFloat viewWidth = labelWidth;
    CGFloat stateViewHeight = 0;
    UIView *stateView = [[UIView alloc] init];
    [self.view addSubview:stateView];
    for (NSInteger i = 0;i< [titleArray count];i++)
    {
        UIView *btnView = [[UIView alloc] init];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonStateTap :)];
        [btnView addGestureRecognizer:tapGesture];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(10, 0, imageWidth, imageHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 101+i;
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, imageHeight, labelWidth, labelHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor blackColor];
        [btnView addSubview:imageView];
        [btnView addSubview:label];
        
        btnView.tag = i;
        btnView.frame = CGRectMake(width/2+(i%count)*width+((i%count)*labelWidth), 10+(i/count)*(viewWidth + 30), viewWidth, viewHeight);
        label.text = titleArray[i];
        [stateView addSubview:btnView];
        stateViewHeight = CGRectGetHeight(btnView.frame);
        imageView.image = [UIImage imageNamed: imageArray[i]];
    }
    stateView.frame = (CGRect){0,CGRectGetMaxY(textLable.frame)+5,MainScreenWidth,stateViewHeight};
    
    CGFloat buttonH = 40;
    CGFloat buttonW = (MainScreenWidth - 100)/2;
    UIButton *accuracyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    accuracyButton.frame = CGRectMake(MainScreenWidth/2-20-buttonW, CGRectGetMaxY(stateView.frame)+40, buttonW, buttonH);
    accuracyButton.backgroundColor = AppColor;
    [accuracyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accuracyButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [accuracyButton setTitle: @"手动校准" forState:UIControlStateNormal];
    accuracyButton.layer.cornerRadius = buttonH/2;
    [accuracyButton addTarget:self action:@selector(accuracyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accuracyButton];
    
    UIButton *kangButton = [UIButton buttonWithType:UIButtonTypeCustom];
    kangButton.frame = CGRectMake(MainScreenWidth/2+20, CGRectGetMaxY(stateView.frame)+40, buttonW, buttonH);
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
    
    NSString *proposalStr = @"";
    NSString *eval = @"";
    if (_sumCount < 60) {
        eval = @"3";
        proposalStr = @"您的心率过缓，饮食宜多选用高热量、高维生素而易消化的食物。";
    }
    else if (_sumCount < 100)
    {
        eval = @"1";
        proposalStr = @"您的心率正常，请予保持。";

    }
    else
    {
        proposalStr = @"您的心率过速，请注意不能过度体力活动、情绪激动、饱餐、饮浓茶、饮咖啡、吸烟、饮酒等。";
        eval = @"2";
    }
    shareURL = [NSString stringWithFormat:@"%@//app/#/testShare?type=rate&val=%li&eval=%@",BAT_WECHAT_Web_URL,_sumCount,eval];
    [[NSUserDefaults standardUserDefaults] setValue:proposalStr forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setValueHUDLabelFromType:(NSInteger)type
{
    CGFloat y = CGRectGetMaxY(detectioResultView.frame);
    detectioResultView.shadeType = type;
    NSArray *textArray;
    CGFloat labelWRatio = 0.f;
    CGFloat labelW = (MainScreenWidth - 50)/3;
        switch (type) {
            case 0:
            {
                labelWRatio = 1;
                HeightHeartRate = 140;
                LowHeartRate = 20;
                textArray = @[@"<60过缓",@"60-100正常",@">100过快"];
            }
                break;
            case 1:
            {
                labelWRatio = 1.1;
                HeightHeartRate = 130;
                LowHeartRate = 50;
                textArray = @[@"<75过缓",@"75-100正常",@">100过快"];
            }
                break;
            case 2:
            {
                labelWRatio = 1.2;

                HeightHeartRate = 140;
                LowHeartRate = 60;
                textArray = @[@"<90过缓",@"90-120正常",@">120过快"];
            }
                break;
            case 3:
            {
                labelWRatio = 1.3;
                HeightHeartRate = 155;
                LowHeartRate = 75;
                textArray = @[@"<105过缓",@"105-135正常",@">135过快"];
            }
                break;
                
            default:
                break;
    }
    for (UIView *elem in self.view.subviews) {
        if (elem.tag >999) {
            [elem removeFromSuperview];
        }
    }
    CGFloat lastWitdh = 0.f;
    CGFloat lastX = 0.f;
    for (int i = 0; i <3; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = textArray[i];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:13];
        label.tag = 1000+i;
        switch (i) {
            case 0:
                label.frame = CGRectMake(lastX+25, y, labelWRatio *labelW, 30);
                label.textAlignment = NSTextAlignmentRight;
                break;
            case 1:
                label.frame = CGRectMake(lastX+25, y, lastWitdh, 30);
                label.textAlignment = NSTextAlignmentCenter;
                break;
            case 2:
                //NSLog(@"%f",MainScreenWidth - 50-lastWitdh);
                label.frame = CGRectMake(type==3?lastX+12:lastX+25, y, MainScreenWidth - 25-lastX, 30);
                label.textAlignment = NSTextAlignmentLeft;
                break;
            default:
                break;
        }
        lastX = CGRectGetMaxX(label.frame)-25;
        lastWitdh = CGRectGetWidth(label.frame);
        [self.view addSubview:label];
    }
    [self getHeartMoveY:_sumCount];
    [self animateForheartMove];
}

//计算坐标
- (void)getHeartMoveY:(CGFloat)sum
{
    CGFloat DetectioResultViewWidth = MainScreenWidth - 50; //色彩渐变条的宽度
    CGFloat pixelY = DetectioResultViewWidth/(HeightHeartRate-LowHeartRate);  //每个心跳需要移动的坐标
    CGFloat detectioHeartViewStartX = (25-DetectioHeartViewHeightAndWidth/2); //心的起始Y
    if (sum<LowHeartRate)
    {
        sum = LowHeartRate;
    }
    else if (sum >HeightHeartRate)
    {
        sum = HeightHeartRate;
    }
    detectioHeartViewY = (sum - LowHeartRate)*pixelY + detectioHeartViewStartX;
    if (detectioHeartViewY>(DetectioResultViewWidth+detectioHeartViewStartX))
    {
        detectioHeartViewY = DetectioResultViewWidth+detectioHeartViewStartX;
    }
    else if (detectioHeartViewY< detectioHeartViewStartX)
    {
        detectioHeartViewY = detectioHeartViewStartX;
    }
}

#pragma mark -
- (void)buttonStateTap:(UITapGestureRecognizer *)tap
{
    UITapGestureRecognizer *tempTap = (UITapGestureRecognizer *)tap;
    UIView *view = (UIView *)tempTap.view;
    
    [self setValueHUDLabelFromType:view.tag];
    for (UIView *elem in tap.view.subviews) {
        if (elem.tag>100)
        {
            [UIView animateWithDuration:1 animations:^{
                elem.transform = CGAffineTransformMakeScale(1.3, 1.3);
                elem.alpha = 0.5;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    elem.alpha = 1;
                    elem.transform = CGAffineTransformIdentity;
                }];
            }];
        }
    }
}

- (void)animateForheartMove
{
    CGRect heartFrame = detectioHeartView.frame;
    heartFrame.origin.x = (25-DetectioHeartViewHeightAndWidth/2);
    detectioHeartView.frame = heartFrame;
    [UIView animateWithDuration:TIDetectioResultViewControllerHeartMoveInterval
                     animations:^(void) {
                         CGRect heartFrame = detectioHeartView.frame;
                         heartFrame.origin.x = detectioHeartViewY;
                         detectioHeartView.frame = heartFrame;
                     } completion:^(BOOL completed) {
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
-(void)accuracyButton:(UIButton *)button
{
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    ManuallyEnteredViewController *helpViewController = [sboard instantiateViewControllerWithIdentifier:@"ManuallyEnteredViewController"];
    helpViewController.hidesBottomBarWhenPushed = YES;
    helpViewController.enteredType = EEnteredHeartRateType;
    [self.navigationController pushViewController:helpViewController animated:YES];
}

-(void)shareButton:(UIButton*)button
{
    [TalkingData trackEvent:@"210000202" label:@"测量结果页>分享"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"share_icon"]];
    if (imageArray)
    {
        NSString *paramsText = [NSString stringWithFormat:@"心率测量 %li %@",_sumCount,shareURL];
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
    healthDataVC.recordWebType = ERecordWebTypePulse;
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
