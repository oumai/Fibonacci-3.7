//
//  MeViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/10/8.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "MeViewController.h"
#import "BATLoginViewController.h"
#import "SettingViewController.h"
#import "FeedbackViewController.h"
#import "QRCodeViewController.h"
#import "DetailViewController.h"
#import "WXWaveView.h"
#import "BATPerson.h"
#import "ShareCustom.h"
#import "AppDelegate+BATShare.h"
#import "SJAvatarBrowser.h"
#import "ScanViewController.h"
#import "WHAnimation.h"

@interface MeViewController ()

@end

@implementation MeViewController

static CGFloat avatarViewWidth = 100;

- (void)dealloc
{
    defaultImage = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataAvatarView)
                                                name:@"UPDATA_LOGIN_STATION"
                                              object:nil];
    cellTitleArray = @[@[@"分享",@"二维码",@"扫一扫"],@[@"反馈意见",@"设置",@"客服电话"]];
    cellIconArray = @[@[@"me_share_icon",@"me_qrcode_icon",@"me_readqr_icon"],@[@"me_feedback_icon",@"me_setting_icon",@"me_service_icon"]];

    defaultImage = [UIImage imageNamed:@"me_avatar_bg_06"];
    [self setTableViewHeaderView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (@available(iOS 11.0, *))
    {
        [myTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if (isGoLogin) {
        isGoLogin = NO;
    }
    [self setWaveViewAnimate:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updataAvatarView];
//    isDowmArrowAnimate = YES;
//    [self dowmArrowDownAnimate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *))
    {
        [myTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
//    isDowmArrowAnimate = NO;
//    [self dowmArrowUpAnimate];
    if (isGoLogin) {
        return;
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setWaveViewAnimate:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTableViewHeaderView
{
    CALayer *layerBG = [CALayer layer];
    layerBG.backgroundColor = AppColor.CGColor;
    layerBG.frame = CGRectMake(0, 0, MainScreenWidth, MainScreenHeight-kTabbarHeight);
    [self.view.layer addSublayer:layerBG];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight*0.45)];
    headerView.backgroundColor = AppColor;
    
    WXWaveView *waveView = [WXWaveView addToView:headerView withFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-4, MainScreenWidth, 6)];
    waveView.tag = 2017;
    [waveView wave];
    
    avatarView = [[UIImageView alloc] initWithFrame:CGRectMake((MainScreenWidth-avatarViewWidth)/2, (CGRectGetHeight(headerView.frame)-avatarViewWidth-30)/2, avatarViewWidth, avatarViewWidth)];
    avatarView.image = defaultImage;
    avatarView.layer.cornerRadius = avatarViewWidth/2;
    avatarView.clipsToBounds = YES;
    avatarView.layer.borderWidth = 3;
    avatarView.layer.borderColor = RGB(255,255,255).CGColor;
    avatarView.layer.allowsEdgeAntialiasing = YES;
    avatarView.userInteractionEnabled = YES;
    [headerView addSubview:avatarView];
    
//    UIImageView *dowmArrowBG = [[UIImageView alloc] initWithFrame:CGRectMake((MainScreenWidth-23)/2, CGRectGetMinY(avatarView.frame)-50, 23, 27)];
//    dowmArrowBG.image = [UIImage imageNamed:@"me_pull_down"];
//    dowmArrowBG.tag = 10086;
//    [headerView addSubview:dowmArrowBG];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(MainScreenWidth/4, CGRectGetMaxY(avatarView.frame), MainScreenWidth/2, 40)];
    nameLabel.text = @"登录/注册";
    nameLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 14];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.tag = 101;
    [headerView addSubview:nameLabel];
    
    UITapGestureRecognizer *avatarTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAvatarVC:)];
    [avatarView addGestureRecognizer:avatarTapGesture];
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goLoginVC:)];
    [headerView addGestureRecognizer:tapGesture];
    
    myTableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight-kTabbarHeight) style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;

    [self.view addSubview:myTableView];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    myTableView.backgroundView = view;
    
    bgLayer = [CALayer layer];
    bgLayer.frame = CGRectMake(0, 0, MainScreenWidth, 1);
    bgLayer.backgroundColor = AppColor.CGColor;
    [view.layer addSublayer:bgLayer];
    
    myTableView.tableHeaderView = headerView;
    myTableView.rowHeight = 50;
    myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    myTableView.bounces = NO;

}


#pragma mark -
//- (void)dowmArrowDownAnimate
//{
//    UIView *view = [headerView viewWithTag:10086];
//    CGFloat y = CGRectGetMinY(avatarView.frame)-50;
//    [UIView animateWithDuration:0.6f animations:^{
//        CGRect rect = view.frame;
//        rect.origin.y = y + 10;
//        view.frame = rect;
//    } completion:^(BOOL finished) {
//        if (isDowmArrowAnimate) {
//            [self dowmArrowUpAnimate];
//        }
//    }];
//}

//- (void)dowmArrowUpAnimate
//{
//    UIView *view = [headerView viewWithTag:10086];
//    CGFloat y = CGRectGetMinY(avatarView.frame)-50;
//    [UIView animateWithDuration:0.6f animations:^{
//        CGRect rect = view.frame;
//        rect.origin.y = y;
//        view.frame = rect;
//    } completion:^(BOOL finished) {
//        if (isDowmArrowAnimate) {
//            [self dowmArrowDownAnimate];
//        }
//    }];
//}

- (void)updataAvatarView
{
    if (LOGIN_STATION == NO)
    {
        nameLabel.text = @"登录/注册";
        avatarView.image = defaultImage;
    }
    else
    {
        BATPerson *person = PERSON_INFO;
        nameLabel.text = person.Data.UserName;
        [self personInfoListRequest];
    }
}

- (void)setWaveViewAnimate:(BOOL)stop
{
    WXWaveView *view2 = [headerView viewWithTag:2017];
    if (!stop) {
        [view2 stop];
    }
    else
    {
        [view2 wave];
    }
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [cellTitleArray count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellTitleArray[section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = cellTitleArray[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 15];
    cell.imageView.image = [UIImage imageNamed:cellIconArray[indexPath.section][indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sboard = [KMTools getStoryboardInstance];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
                    UIImage *shareImage = [UIImage imageNamed:@"me_avatar_bg_06"];
                    NSArray* imageArray = @[shareImage];
                    if (imageArray)
                    {
                        NSString *paramsText = [NSString stringWithFormat:@"真素好玩Cry噜%@",SHARE_URL];
                        [shareParams SSDKSetupShareParamsByText:paramsText
                                                         images:imageArray
                                                            url:[NSURL URLWithString:SHARE_URL]
                                                          title:@"康美小管家"
                                                           type:SSDKContentTypeAuto];
                    }
                    [ShareCustom shareWithContent:shareParams];
                }
                    break;
                case 1:
                {
                    QRCodeViewController *heartChartViewController = [sboard instantiateViewControllerWithIdentifier:@"QRCodeViewController"];
                    heartChartViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartChartViewController animated:YES];
                }
                    break;
                case 2:
                {
                    ScanViewController *heartChartViewController = [[ScanViewController alloc]init];
                    heartChartViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartChartViewController animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (!LOGIN_STATION)
            {
                [self showText:@"请登录"];
                return;
            }
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            switch (indexPath.row) {
                case 0:
                {
                    FeedbackViewController *heartChartViewController = [sboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
                    heartChartViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartChartViewController animated:YES];
                }
                    break;
                case 1:
                {
                    SettingViewController *heartChartViewController = [sboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
                    heartChartViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartChartViewController animated:YES];
                }
                    break;
                case 2:
                {
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"客服电话：400-888-6158转1" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4008886158"]];
                        });
                    }];
                    [alertController addAction:sureAction];
                    UIAlertAction *canleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:canleAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            if (!LOGIN_STATION)
            {
                [self showText:@"请登录"];
                return;
            }
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            switch (indexPath.row) {
                case 0:
                {
                    FeedbackViewController *heartChartViewController = [sboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
                    heartChartViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartChartViewController animated:YES];
                }
                    break;
                case 1:
                {
                    SettingViewController *heartChartViewController = [sboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
                    heartChartViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartChartViewController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)goLoginVC:(UITapGestureRecognizer *)tap
{
    if (!LOGIN_STATION)
    {
        [TalkingData trackEvent:@"2200001" label:@"我的>登录/注册"];
        BATLoginViewController *heartTrendViewController = [[BATLoginViewController alloc] init];
        heartTrendViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:heartTrendViewController animated:YES];
        isGoLogin = YES;
    }
}
- (void)goAvatarVC:(UITapGestureRecognizer *)tap
{
    if (!LOGIN_STATION)
    {
        [TalkingData trackEvent:@"2200001" label:@"我的>登录/注册"];
        BATLoginViewController *heartTrendViewController = [[BATLoginViewController alloc] init];
        heartTrendViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:heartTrendViewController animated:YES];
        isGoLogin = YES;
    }
    else
    {
        [TalkingData trackEvent:@"2200002" label:@"我的>我的详细资料"];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        UIStoryboard *sboard = [KMTools getStoryboardInstance];
        DetailViewController *heartChartViewController = [sboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        heartChartViewController.hidesBottomBarWhenPushed = YES;
        heartChartViewController.defaultImage = avatarView.image;
        [self.navigationController pushViewController:heartChartViewController animated:YES];
    }
}

#pragma mark -
-(NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to
{
    NSInteger value = from + (arc4random() % (to-from + 1));
    return value;
}

#pragma mark - NET
- (void)personInfoListRequest {
    [HTTPTool requestWithURLString:@"/api/Patient/Info" parameters:nil showStatus:NO type:kGET success:^(id responseObject) {
        BATPerson *person = [BATPerson mj_objectWithKeyValues:responseObject];
        if (person.ResultCode == 0) {
            //保存个人信息
            NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Person.data"];
            [NSKeyedArchiver archiveRootObject:person toFile:file];
            nameLabel.text = person.Data.UserName;
            avatarView.image = nil;
            [avatarView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", person.Data.PhotoPath]] placeholderImage:defaultImage];
        }
    } failure:^(NSError *error) {
    }];
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
