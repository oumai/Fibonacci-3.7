//
//  BATNewDrKangViewController.m
//  HealthBAT_Pro
//
//  Created by mac on 2018/3/19.
//  Copyright © 2018年 KMHealthCloud. All rights reserved.
//

#import "BATNewDrKangViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BATLoginModel.h"
#import "BATPerson.h"
#import "HTTPTool+DrKangRequst.h"



#import "BATDrKangHistoryViewController.h"//历史记录
#import "BATHealthThreeSecondsController.h"  //健康3秒钟
#import "BATHealthyInfoViewController.h"  //健康3秒钟健康资料
#import "BATHealthThreeSecondsStatisController.h" //健康3秒钟 统计
#import "BATHealth360EvaluationViewController.h"//健康360健康评估
#import "BATLoginViewController.h"//登录
#import "HTMLViewController.h"
#import "EyeTestViewController.h"   //视力
#import "MedicallyExaminedViewController.h" //快速体检
#import "VitalCapacityViewController.h" //肺活量
#import "BloodSugarViewController.h" //血糖

@interface BATNewDrKangViewController ()

@end

@implementation BATNewDrKangViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    
    [super loadView];
    BATLoginModel *login = LOGIN_INFO;
    
    //必要参数赋值
    self.userID = [NSString stringWithFormat:@"%ld",(long)login.Data.ID];
    self.userDeviceId = [KMTools getPostUUID];
    self.lat = @"";
    self.lon = @"";
    self.requestSource = @"manager";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    WEAK_SELF(self);
//    [self setRightBarActionBlock:^(NSInteger tag) {
//        STRONG_SELF(self);
//        switch (tag) {
//            case BATDrKangRightBarButtonHistory:
//            {
//                //智能问诊历史评估
//                [self pushDrKangHistoryVC];
//            }
//                break;
//
//            case BATDrKangRightBarButtonEvaluation:
//            {
//                //健康360 健康评估
//                [self pushHealth360EvaluationVC];
//            }
//                break;
//
//            case BATDrKangRightBarButtonHealthThreeSecond:
//            {
//                //健康3秒钟统计
//                [self pushHealthThreeSecondsVC];
//            }
//                break;
//
//            default:
//                break;
//        }
//    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogin) name:@"UPDATA_LOGIN_STATION" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:@"APPLICATION_LOGOUT" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override
- (void)handleFlag:(NSString *)flag allPara:(NSDictionary *)allPara {
    
    [super handleFlag:flag allPara:allPara];
     if ([flag isEqualToString:@"健康3秒钟"]){
        [self pushHealthThreeSecondsVC];
        
    }
}

- (void)executiveOrder:(NSString *)order {
    
    [super executiveOrder:order];
    [super setIsNeedLogin:NO];
    if ([order isEqualToString:@"login"]) {
        //跳转登陆
        [super setIsNeedLogin:YES];
        [super pushNextVC];
        PUSH_LOGIN_VD;
    }
    else if ([order containsString:@"healthReport"]) {
        //跳转健康报告
        [self pushHealth360EvaluationVC];
    }
    else if ([order containsString:@"health360"]) {
        //跳转健康360（健康档案）
        [self pushHealth360DocumentVC];
    }
    else if ([order containsString:@"health3s"]) {
        //跳转健康3s
        [self pushHealthThreeSecondsVC];
    }
    else if ([order containsString:@"visionMeasurement"]) {
        //跳转视力测量界面
        [self pushEyeTestVC];
        
    }
    else if ([order containsString:@"bloodGlucoseEntry"]) {
        //跳转录入血糖界面
        [self pushBloodSugarVC];
    }
    else if ([order containsString:@"fastHealthTest"]) {
        //跳转到快速体检页面
        [self pushMedicallyExaminedVC];
    }
    else if ([order containsString:@"lungTest"]) {
        //跳转到肺活量页面
        [self pushVitalCapacityVC];
    }
    else if([order containsString:@"homePage"])
    {
        if (self.measureType < 1) {
            [[NSUserDefaults standardUserDefaults] setValue:KEY_KANG_SELECTTABBAR forKey:KEY_KANG_SELECTTABBAR];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self backHome];
    }
}

- (void)userLogin
{
//    [super updateLoginState];
    if (LOGIN_STATION == NO)
    {
        //必要参数赋值
        self.userID = @"";
        self.userDeviceId = [KMTools getPostUUID];
        self.lat = @"";
        self.lon = @"";
        self.requestSource = @"manager";
    }
    else
    {
        BATLoginModel *login = LOGIN_INFO;
        //必要参数赋值
        self.userID = [NSString stringWithFormat:@"%ld",(long)login.Data.ID];
        self.userDeviceId = [KMTools getPostUUID];
        self.lat = @"";
        self.lon = @"";
        self.requestSource = @"manager";
    }

}

- (void)userLogout {
    

}



#pragma mark - private
- (void)backHome
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 *NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        if (self.measureType) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        else
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            UITabBarController *vc =  (UITabBarController *)window.rootViewController;
            [vc setSelectedIndex:0];
        }
    });


}
//跳转到智能问诊历史记录
- (void)pushDrKangHistoryVC {
    [super pushNextVC];
    BATDrKangHistoryViewController *historyVC = [[BATDrKangHistoryViewController alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}

//跳转到健康3秒钟统计界面
- (void)pushHealthThreeSecondsVC{
    
    [super pushNextVC];

    if ( !LOGIN_STATION) {
        PUSH_LOGIN_VD;
        return;
    }
    
    BATPerson *loginUserModel = PERSON_INFO;
    
    BOOL isEdit = (loginUserModel.Data.Weight && loginUserModel.Data.Height && loginUserModel.Data.Birthday.length);
    
    if ( !LOGIN_STATION) {
        PUSH_LOGIN_VD;
        return;
    }
    
    
    if (!isEdit && ![[NSUserDefaults standardUserDefaults]boolForKey:@"isFirstEnterHealthThreeSecond"]) {
        
        //完善资料
        BATHealthyInfoViewController *editInfo = [[BATHealthyInfoViewController alloc]init];
        editInfo.isShowNavButton = YES;
        editInfo.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editInfo animated:YES];
        
        
    }else{
        
        BATHealthThreeSecondsController *healthDataVC = [[BATHealthThreeSecondsController alloc]init];
        healthDataVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:healthDataVC animated:YES];
        
        //健康3秒钟统计
        //        BATHealthThreeSecondsStatisController *healthThreeSecondsStatisVC = [[BATHealthThreeSecondsStatisController alloc]init];
        //        healthThreeSecondsStatisVC.hidesBottomBarWhenPushed = YES;
        //        [self.navigationController pushViewController:healthThreeSecondsStatisVC animated:YES];
    }
}

//健康360的评估页面
- (void)pushHealth360EvaluationVC {
//    BOOL openBAT = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"com.KmHealthBAT.app://healthEvaluateReport"]];
//    NSLog(@"Open %@: %d",@"asdasdasa",openBAT);
    __block NSString *scheme = @"com.KmHealthBAT.app://healthEvaluateReport";
    UIApplication * application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{}
           completionHandler:^(BOOL success) {
               if (!success) {
                   NSString *urlString = [NSString stringWithFormat:@"%@/app/newsindex?sys=ios",WEB_URL];
                   [application openURL:[NSURL URLWithString: urlString] options:@{}
                      completionHandler:^(BOOL success) {
                      }];
               }
           }];
    } else {
        BOOL success = [application openURL:URL];
        NSLog(@"Open %@: %d",scheme,success);
        if (success) {
            //        NSString *urlString = [NSString stringWithFormat:@"com.KmHealthBAT.app://healthEvaluateReport"];
            NSString *urlString = [NSString stringWithFormat:@"com.KmHealthBAT.app://healthEvaluateReport"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
        else
        {
            NSString *urlString = [NSString stringWithFormat:@"%@/app/newsindex?sys=ios",WEB_URL];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
    

}

//健康360的健康档案页面
- (void)pushHealth360DocumentVC {
    [super pushNextVC];
    if (!LOGIN_STATION) {
        PUSH_LOGIN_VD;
        return;
    }

    HTMLViewController *healthDataVC = [[HTMLViewController alloc]init];
    healthDataVC.hidesBottomBarWhenPushed = YES;
    healthDataVC.webType = 1;
    [self.navigationController pushViewController:healthDataVC animated:YES];
}

//跳转视力测量界面
- (void)pushEyeTestVC
{
    [super pushNextVC];
    [self needProposal];
    EyeTestViewController *eyeTestViewController = [[KMTools getStoryboardInstance] instantiateViewControllerWithIdentifier:@"EyeTestViewController"];
    eyeTestViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:eyeTestViewController animated:YES];
}

//跳转录入血糖界面
- (void)pushBloodSugarVC
{
    [super pushNextVC];
    [self needProposal];
    BloodSugarViewController *bloodSugarViewController = [[KMTools getStoryboardInstance] instantiateViewControllerWithIdentifier:@"BloodSugarViewController"];
    bloodSugarViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:bloodSugarViewController animated:YES];
}

//跳转到快速体检页面
- (void)pushMedicallyExaminedVC
{
    [super pushNextVC];
    [self needProposal];
    MedicallyExaminedViewController *bloodOxygenView = [[KMTools getStoryboardInstance] instantiateViewControllerWithIdentifier:@"MedicallyExaminedViewController"];
    bloodOxygenView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:bloodOxygenView animated:YES];
}

//跳转到肺活量页面
- (void)pushVitalCapacityVC
{
    [super pushNextVC];
    [self needProposal];
    VitalCapacityViewController *vitalCapacityViewController = [[KMTools getStoryboardInstance] instantiateViewControllerWithIdentifier:@"VitalCapacityViewController"];
    vitalCapacityViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vitalCapacityViewController animated:YES];
}

- (void)needProposal
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:KEY_KANG_NEEDPROPOSAL forKey:KEY_KANG_NEEDPROPOSAL];
    [userDefaults synchronize];
}
#pragma mark - NET
- (void)sendTextRequestWithParameters:(NSDictionary *)parameters isSound:(BOOL)isSound {
    
    [super sendTextRequestWithParameters:parameters isSound:isSound];
    
//    BATLoginModel *login = LOGIN_INFO;
    NSString *url = @"/drkang/test/chatWithDrKang";
    if (self.firstInVC) {
        url = @"/drkang/test/resetProcess";
        self.firstInVC = NO;
    }
    NSString *key = [parameters objectForKey:@"keyword"];
//    NSLog(@"开始发送 ：%@",key);
    [HTTPTool requestWithDrKangURLString:url
                              parameters:parameters
                              showStatus:YES
                                 success:^(id responseObject) {
                                     
                                     if (!responseObject) {
                                         
                                         return ;
                                     }
                                     
                                     if ([responseObject isKindOfClass:[NSArray class]]) {
                                         //新形势接口解析
                                         [self handleNewResponseObject:responseObject isSound:isSound];
                                     }
                                     else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                         //旧接口解析
                                         [self handleResponseObject:responseObject];
                                     }
                                     
                                 } failure:^(NSError *error) {
                                     
                                     
                                 }];
}

- (void)eventRequestWithURL:(NSString *)url {
    
    [super eventRequestWithURL:url];
    
    url = [NSString stringWithFormat:@"%@&userDeviceId=%@&userId=%@",url,self.userDeviceId,self.userID];
    
    [HTTPTool requestWithDrKangURLString:url parameters:nil showStatus:YES success:^(id responseObject) {
        if (!responseObject) {
            
            return ;
        }
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            
            [self handleNewResponseObject:responseObject isSound:NO];
        }
        else if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            [self handleResponseObject:responseObject];
        }
    }failure:^(NSError *error) {
        
    }];
}

- (void)detailRequestWithURL:(NSString *)url {
    
    [super detailRequestWithURL:url];
    
    url = [NSString stringWithFormat:@"%@&userDeviceId=%@&userId=%@",url,self.userDeviceId,self.userID];
    
    [HTTPTool requestWithDrKangURLString:url parameters:nil showStatus:YES success:^(id responseObject) {
        if (!responseObject) {
            
            return ;
        }
        
        [self expandDeitalViewWithResponseObject:responseObject];
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
