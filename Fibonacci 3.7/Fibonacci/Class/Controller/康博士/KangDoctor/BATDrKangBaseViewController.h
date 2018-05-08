//
//  BATDrKangBaseViewController.h
//  HealthBAT_Pro
//
//  Created by mac on 2018/3/19.
//  Copyright © 2018年 KMHealthCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 康博士右上角按钮枚举
 
 - BATDrKangRightBarButtonHistory: 历史智能问诊
 - BATDrKangRightBarButtonEvaluation: 健康评估
 - BATDrKangRightBarButtonHealthThreeSecond: 健康3秒钟
 */
typedef NS_ENUM(NSInteger, BATDrKangRightBarButtonItems) {
    
    BATDrKangRightBarButtonHistory = 2000,
    BATDrKangRightBarButtonEvaluation = 2001,
    BATDrKangRightBarButtonHealthThreeSecond = 2002,
};

/**
 康博士当前页面状况
 
 - BATDrKangViewStationChat: 聊天
 - BATDrKangViewStationWelcome: 欢迎
 - BATDrKangViewStationAskView: 特殊问题页面
 */
typedef NS_ENUM(NSInteger, BATDrKangViewStation) {
    
    BATDrKangViewStationChat = 1000,
    BATDrKangViewStationWelcome = 1001,
    BATDrKangViewStationAskView = 1002,
};

typedef NS_ENUM(NSInteger, EKangMeasureType ) {
    EKangMeasureTypeBlood = 1, //视力
    EKangMeasureTypeVitalCapacity,//肺活量
    EKangMeasureTypeMedicallyExamined,//快速体检
};

@interface BATDrKangBaseViewController : KMUIViewController

//必要参数
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *userDeviceId;
@property (nonatomic,strong) NSString *lat;
@property (nonatomic,strong) NSString *lon;
@property (nonatomic,strong) NSString *requestSource;

@property (nonatomic,copy) void(^rightBarActionBlock)(NSInteger tag);

//可选参数
@property (nonatomic,strong) NSString *avatarUrl;

@property(nonatomic, assign)EKangMeasureType measureType; //从测量页进入
@property(nonatomic, copy) NSString *proposalStr;
@property (nonatomic,assign) BOOL gotoStepVC; //进入测量页
@property (nonatomic,assign) BOOL firstInVC; //从测量也第一次进入康博士
@property (nonatomic,assign) BOOL pageNavHidden; //从测量也第一次进入康博士
@property (nonatomic,assign) BOOL isExecutiveOrder;//记录是否正在执行order，当order执行完返回康博士时，需要发出end命令
@property (nonatomic,assign) BOOL isNeedLogin;//记录是否正在执行order，当order执行完返回康博士时，需要发出end命令
@property (nonatomic,assign) BOOL selectTabbar;//点击了外部Tabbar

/**
 点击了超链接，根据超链接的参数处理
 
 @param flag 处理标识
 @param dic  超链接参数
 */
- (void)handleFlag:(NSString *)flag allPara:(NSDictionary *)allPara;

//执行order
/**
 执行order
 
 @param order order命令
 */
- (void)executiveOrder:(NSString *)order;

//进入下个页面
/**
 执行order
 
 */
- (void)pushNextVC;

//登录状态已改变
/**
 执行order
 
 @param order order命令
 */
- (void)updateLoginState;

//需要登录
/**
 执行order
 
 @param order order命令
 */
- (void)setIsNeedLogin:(BOOL)isNeedLogin;

/**
 发送信息
 
 @param content 内容
 @param isSound 是否语音输入
 */
- (void)sendTextRequestWithContent:(NSString *)content isSound:(BOOL)isSound;


/**
 发送信息
 
 @param parameters 参数
 @param isSound 是否语音输入
 */
- (void)sendTextRequestWithParameters:(NSDictionary *)parameters isSound:(BOOL)isSound;


/**
 点击事件
 
 @param url url
 */
- (void)eventRequestWithURL:(NSString *)url;


/**
 点击展开详情
 
 @param url url
 */
- (void)detailRequestWithURL:(NSString *)url;


/**
 欢迎语
 */
- (void)introduceRequest;


/**
 展开详情接口处理
 
 @param responseObject responseObject
 */
- (void)expandDeitalViewWithResponseObject:(id)responseObject;


/**
 新接口处理
 
 @param responseObject responseObject
 @param isSound 是否语音输入
 */
- (void)handleNewResponseObject:(id)responseObject isSound:(BOOL)isSound;


/**
 旧接口处理
 
 @param responseObject responseObject
 */
- (void)handleResponseObject:(id)responseObject;
@end

