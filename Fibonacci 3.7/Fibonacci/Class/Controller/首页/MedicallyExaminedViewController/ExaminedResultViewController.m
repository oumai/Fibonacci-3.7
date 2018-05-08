//
//  ExaminedResultViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/23.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "ExaminedResultViewController.h"
#import "ExaminedTableViewCell.h"
#import "ShareCustom.h"
#import "AppDelegate+BATShare.h"
#import "BATNewDrKangViewController.h"

@interface ExaminedResultViewController ()

@end

@implementation ExaminedResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"体检结果";
    
    typeArray = @[@"血压数值", @"心率数值", @"血氧数值"];
    [self initShareButton];
    myTableView.rowHeight = 150;
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KMDataManager sharedDatabaseInstance] insertBloodOxygenDataModelFromNumber:[NSNumber numberWithInteger:_bloodOxygenValue]];
        [[KMDataManager sharedDatabaseInstance] insertHeartRateDataModelNumber:[NSNumber numberWithInteger:_heartRateValue]];
        [[KMDataManager sharedDatabaseInstance] insertBloodPressureDataModelFromSPNumber: [NSNumber numberWithInteger: _heightPressureValue] andDPNumber:[NSNumber numberWithInteger: _lowPressureValue]];
    });
    [self judgeString];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)initShareButton
{
    CGFloat buttonH = 40;
    CGFloat buttonW = MainScreenWidth - 100;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, MainScreenHeight-kStatusAndNavHeight-40, MainScreenWidth, 40)];
    label.font = [UIFont fontWithName:AppFontHelvetica size:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = RGB(151, 151, 151);
    label.numberOfLines = 2;
    label.text = @"数据可能会存在一定范围的误差,测量结果仅供参考";
    [self.view addSubview:label];
    
    UIButton *kangButton = [UIButton buttonWithType:UIButtonTypeCustom];
    kangButton.frame = CGRectMake( 50, CGRectGetMinY(label.frame)-50, buttonW, buttonH);
    kangButton.backgroundColor = RGB(253, 155, 71);
    [kangButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [kangButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [kangButton setTitle: @"咨询康博士" forState:UIControlStateNormal];
    [kangButton addTarget:self action:@selector(kangButton:) forControlEvents:UIControlEventTouchUpInside];
    kangButton.layer.cornerRadius = buttonH/2;
    [self.view addSubview:kangButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [typeArray count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ExaminedTableViewCell";
    ExaminedTableViewCell *cell = (ExaminedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ExaminedTableViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.typeLabel.text = typeArray[indexPath.row];
    if (indexPath.row == 0)
    {
        [cell setCellValue:[NSString stringWithFormat:@"%li mmHg",(long)_heightPressureValue] lowValue:[NSString stringWithFormat:@"%li mmHg",(long)_lowPressureValue]];
    }
    else if (indexPath.row == 1)
    {
        [cell setCellValue: [NSString stringWithFormat:@"%li 次/分钟",(long)_heartRateValue]
                  lowValue:nil];
    }
    else if (indexPath.row == 2)
    {
        [cell setCellValue:[NSString stringWithFormat:@"%li %%",(long)_bloodOxygenValue] lowValue:nil];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
-(void)judgeString
{
    NSString *proposalStr = @"";
    NSString *bloodPressureStr = @"";
    if (_heightPressureValue<90)
    {
        bloodPressureStr = @"请复查血压，必要时请于心内科就诊";
    }
    else if (_heightPressureValue < 120)
    {
        bloodPressureStr = @"您的血压正常，请予保持。";
    }
    else if (_heightPressureValue < 140)
    {
        bloodPressureStr = @"请复查血压，保持血压在正常范围";
    }
    else
    {
        bloodPressureStr = @"请复查血压，必要时请于心内科就诊";
    }
    proposalStr =  [proposalStr stringByAppendingFormat:@"%@/",bloodPressureStr];
    
    NSString *rateString = @"";
    if (_heartRateValue < 60) {
        rateString = @"您的心率过缓，饮食宜多选用高热量、高维生素而易消化的食物。。";
    }
    else if (_heartRateValue <= 100)
    {
        rateString = @"您的心率正常，请予保持。";
    }
    else
    {
        rateString = @"您的心率过速，请注意不能过度体力活动、情绪激动、饱餐、饮浓茶、饮咖啡、吸烟、饮酒等。";
    }
    proposalStr =  [proposalStr stringByAppendingFormat:@"%@/",rateString];

    NSString *bloodOxygenStr = @"";
    if (_bloodOxygenValue < 90) {
        bloodOxygenStr = @"您的血氧严重偏低，请及时吸氧，同时注意休息，调整好状态并复查血氧。如果复查结果仍为血氧严重偏低，请及时就医诊疗。";
    }
    else if (_bloodOxygenValue < 95)
    {
        bloodOxygenStr = @"您的血氧偏低，请注意休息，清淡饮食，稳定情绪，调整好状态并复查血氧。";
    }
    else if (_bloodOxygenValue < 100)
    {
        bloodOxygenStr = @"您的血氧正常，请予保持。";
    }
    proposalStr =  [proposalStr stringByAppendingFormat:@"%@",bloodOxygenStr];
    [[NSUserDefaults standardUserDefaults] setValue:proposalStr forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark -
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
        kangViewController.measureType = EKangMeasureTypeMedicallyExamined;
        //    kangViewController.proposalStr
        [self.navigationController pushViewController:kangViewController animated:YES];
    }
}

-(void)shareButton:(UIButton*)button
{
    [TalkingData trackEvent:@"210000102" label:@"测量结果页>分享"];

    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"share_icon"]];
    if (imageArray)
    {
        NSString *paramsText = [NSString stringWithFormat:@"天了噜%@",SHARE_URL];
        [shareParams SSDKSetupShareParamsByText:paramsText
                                         images:imageArray
                                            url:[NSURL URLWithString:SHARE_URL]
                                          title:@"康美小管家"
                                           type:SSDKContentTypeAuto];
    }
    [ShareCustom shareWithContent:shareParams];
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
