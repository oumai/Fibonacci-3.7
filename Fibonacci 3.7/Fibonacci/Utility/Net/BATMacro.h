//
//  BATMacro.h
//  HealthBAT_Pro
//
//  Created by Skyrim on 16/8/15.
//  Copyright © 2016年 KMHealthCloud. All rights reserved.
//

#ifndef BATMacro_h
#define BATMacro_h

//引入地区信息
#import "BATLocalDataSourceMacro.h"

//引入通知宏定义
#import "BATNotificationMacro.h"

//引入公用枚举定义
#import "BATEnumMacro.h"

#define ServiceName @"com.KMBATHalthyManage.app"    //保存密码的标示
#define KEY_LOGIN_TOKEN @"Token"                    //登录TOKEN
#define KEY_LOGIN_NAME  @"LOGIN_NAME"               //登录名key
#define KEY_LOGIN_MANUAL @"KEY_LOGIN_MANUAL"        //用户自动退出则不进行自动登录
#define KEY_INSULINNAME_TARRAY @"InsulinNameArray"  //胰岛素常用药品
#define KEY_REMINDER_ARRAY @"REMINDER_ARRAY"        //血糖定时提醒
#define KEY_PHYSICALRECORD_DIC @"PhysicalRecord_Dic"    //网络医院体检数据记录
#define KEY_KANG_PROPOSALSTRING @"KEY_KANG_PROPOSALSTRING" //提供给康博士的各个测量结果的建议
#define KEY_KANG_NEEDPROPOSAL @"KEY_KANG_NEEDPROPOSAL" //提供给康博士的各个测量结果的建议
#define KEY_KANG_SELECTTABBAR @"KEY_KANG_SELECTTABBAR" //点击底部Tabbar

//网络
#define API_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"XGJApiUrl"]//小管家
#define WEB_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"BATWebUrl"]//Web地址
#define BAT_SEARCH_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"BATSearchUrl"]//BAT搜索地址
#define BAT_API_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"BATApiUrl"]//BAT API地址
#define BAT_WECHAT_Web_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"BATWeChatWebUrl"]//BAT微信web地址
#define KM_HEALTH360_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"KMHEALTH360APIURL"]//健康360地址
#define DR_KANG_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"DrKangUrl"]//康博士域名

#define SHARE_URL  [NSString stringWithFormat:@"%@/app/shareindex",WEB_URL]//分享地址
#define APPSTORE_URL @"https://itunes.apple.com/cn/app/kang-mei-xiao-guan-jia/id1169968028?l=zh&mt=8"

#define LOCAL_TOKEN [[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]//存入本地的token

//网络状态
#define NET_STATION [[NSUserDefaults standardUserDefaults] boolForKey:@"netStatus"]//有无网络
//请求状态
#define RESQUEST_STATION [[NSUserDefaults standardUserDefaults] boolForKey:@"resquestStatus"]//请求成功还是失败

//登录
#define LOGIN_STATION [[NSUserDefaults standardUserDefaults] boolForKey:@"LoginStation"]//登录状态
#define SET_LOGIN_STATION(bool) [[NSUserDefaults standardUserDefaults] setBool:bool forKey:@"LoginStation"];[[NSUserDefaults standardUserDefaults] synchronize];//改变登录状态
#define PRESENT_LOGIN_VC [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[BATLoginViewController new]] animated:YES completion:nil];//弹出登录界面

#define PUSH_LOGIN_VD BATLoginViewController *heartTrendViewController = [[BATLoginViewController alloc] init];heartTrendViewController.hidesBottomBarWhenPushed = YES;[self.navigationController pushViewController: heartTrendViewController animated:YES];
#define GET_PHYSICALRECOID [[NSUserDefaults standardUserDefaults] valueForKey: KEY_PHYSICALRECORD_DIC ]//登录状态

//颜色
//#define BASE_COLOR [UIColor colorWithRed:69.0/255.0  green:160.0/255.0   blue:240.0/255.0  alpha:1.0]
//#define BASE_COLOR UIColorFromHEX(0X1579f1, 1)
//
//#define BASE_BACKGROUND_COLOR [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0]

#define kAllTextGrayColor [UIColor colorWithRed:133.0 / 255 green:138.0 / 255 blue:142.0 / 255 alpha:1.0]

//个人信息
#define PERSON_INFO [NSKeyedUnarchiver unarchiveObjectWithFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Person.data"]]

//登录信息
#define LOGIN_INFO [NSKeyedUnarchiver unarchiveObjectWithFile: [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UserLogin.data"]]

//标记首次进入健康3秒钟界面
#define isFirstEnterHealthThreeSecond @"isFirstEnterHealthThreeSecond"
#define isRecordHealthThreeSecondNotification @"isRecordHealthThreeSecondNotification"
#define isRecordHealthThreeSecondAccountID @"isRecordHealthThreeSecondAccountID"
#define BATHealthThreeSecondKey     @"BATHealthThreeSecondKey"
#define BATHealthThreeSecondDateKey     @"BATHealthThreeSecondDateKey"

//导航首页缩放系数
#define scaleValue (3.0f / 4.0f)
#define scale6pValue (4.0f / 5.0f)

#endif /* BATMacro_h */
