//
//  RootViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 2016/10/14.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "MeViewController.h"
#import "Health360ViewController.h"
#import "KangDoctorViewController.h"
#import "HealthKitManage.h"
#import "SFHFKeychainUtils.h"
#import "HTTPTool+LoginRequest.h"
#import "BATNewDrKangViewController.h"
#import "HTTPTool+HeartDataRequst.h"
#import "BATNewDrKangViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewControllers];
    [self setHelpPagesCount];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];

#if TARGET_OS_IPHONE//真机
    if (IS_IOS8) {
        [[HealthKitManage shareInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
        }];
    }
#endif
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        [self applyNetworkPrivileges];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)applyNetworkPrivileges
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *allKeys = [[NSUserDefaults standardUserDefaults].dictionaryRepresentation allKeys];
    if (![allKeys containsObject: @"FisrtBoot"])
    {
        [userDefaults setValue:@"FisrtBoot" forKey: @"FisrtBoot"];
        [userDefaults synchronize];
        [HTTPTool requestWithURLString:@""
                            parameters:nil
                            showStatus:NO
                                  type:kPOST
                               success:^(id responseObject)
         {
         }
                               failure:^(NSError *error) {
                               }];
    }
    else
    {
        [self automaticLogin];
    }
    
}

-(void)automaticLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults] ;
    NSArray *allKeys = [[NSUserDefaults standardUserDefaults].dictionaryRepresentation allKeys];
    NSString *userName = [userDefaults valueForKey: KEY_LOGIN_NAME];
    if (userName.length >1 && ![allKeys containsObject:KEY_LOGIN_MANUAL])
    {
        NSError *error;
        NSString * password = [SFHFKeychainUtils getPasswordForUsername: userName andServiceName:ServiceName error:&error];
        if(error){
            DDLogError(@"从Keychain里获取密码出错：%@",error);
            return;
        }
        [HTTPTool LoginWithUserName: userName
                           password: password
                            Success:^{
                                [self dismissProgress];
                            }failure:^(NSError *error) {
                            }];
    }

    
}

- (void)initViewControllers
{
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:KEY_KANG_SELECTTABBAR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //创建viewControllers
    UIStoryboard *sboard = [KMTools getStoryboardInstance];

    ViewController *_mainController = [sboard instantiateViewControllerWithIdentifier:@"ViewController"];
    UIImage *mallNormal = [[UIImage imageNamed:@"table_home_normal_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *mallSelect = [[UIImage imageNamed:@"table_home_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _mainController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:mallNormal selectedImage:mallSelect];
    KMUINavigationController *nav1 = [[KMUINavigationController alloc] initWithRootViewController:_mainController];
    
    Health360ViewController *healthDataVC = [sboard instantiateViewControllerWithIdentifier:@"Health360ViewController"];
    UIImage *healthNormal = [[UIImage imageNamed:@"tabbar_360_normal_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *healthSelect = [[UIImage imageNamed:@"tabbar_360_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    healthDataVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"健康360" image:healthNormal selectedImage:healthSelect];
    KMUINavigationController *nav2 = [[KMUINavigationController alloc] initWithRootViewController:healthDataVC];
    
    //
//    KangDoctorViewController *batVC = [sboard instantiateViewControllerWithIdentifier:@"KangDoctorViewController"];
//    BATNewDrKangViewController *batVC = [[BATNewDrKangViewController alloc]init];
    
    BATNewDrKangViewController *batVC = [[BATNewDrKangViewController alloc]init];
    UIImage *batNormal = [[UIImage imageNamed:@"tabbar_kang_normal_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *batSelect = [[UIImage imageNamed:@"tabbar_kang_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    batVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"康博士" image:batNormal selectedImage:batSelect];
    KMUINavigationController *nav3 = [[KMUINavigationController alloc] initWithRootViewController:batVC];
    
    MeViewController *meVC = [sboard instantiateViewControllerWithIdentifier:@"MeViewController"];
    UIImage *meNormal = [[UIImage imageNamed:@"table_me_normal_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *meSelect = [[UIImage imageNamed:@"table_me_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    meVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:meNormal selectedImage:meSelect];
    KMUINavigationController *nav5 = [[KMUINavigationController alloc] initWithRootViewController:meVC];
    
    NSArray *tabArray = @[nav1,nav2,nav3,nav5];
    
    [self setViewControllers:tabArray];
    //RGB(142, 142, 142)
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB(142, 142, 142),NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName, nil]forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:AppColor,NSForegroundColorAttributeName,[UIFont systemFontOfSize:11],NSFontAttributeName, nil]forState:UIControlStateSelected];
}

-(void)setHelpPagesCount
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *allKeys = [[NSUserDefaults standardUserDefaults].dictionaryRepresentation allKeys];
    NSArray *firstArray = @[@"FirstGoEye", @"FirstGoColor", @"FirstGoHeartRate", @"FirstGoBloodOxygen", @"FirstGoBloodPressure", @"FirstGoMedicallyExamined", @"FirstGoHome"];
    for (NSString *elem in firstArray)
    {
        if (![allKeys containsObject: elem])
        {
            [userDefaults setValue:elem forKey: elem];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//- (void)uploadStepCount
//{
//    [HTTPTool uploadHeartStepCountCompletion:^(BOOL success, NSMutableDictionary *dict, NSError *error) {
//        if (success) {
//            NSLog(@"嗯嗯 ");
//        }
//        NSTimer *timer = [NSTimer timerWithTimeInterval:300 target:self selector:@selector(uploadStepCount) userInfo:nil repeats:NO];
//        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    }];
//}

#pragma mark -
- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
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
