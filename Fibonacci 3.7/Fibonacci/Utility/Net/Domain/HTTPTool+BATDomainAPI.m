//
//  HTTPTool+BATDomainAPI.m
//  HealthBAT_Pro
//
//  Created by Skyrim on 16/8/15.
//  Copyright © 2016年 KMHealthCloud. All rights reserved.
//

#import "HTTPTool+BATDomainAPI.h"
#import "BATDomainModel.h"

@implementation HTTPTool (BATDomainAPI)

+ (void)getDomain {

    NSUserDefaults *userDeafaults = [NSUserDefaults standardUserDefaults];
#ifdef DEBUG
    //    [[NSUserDefaults standardUserDefaults] setValue:@"http://10.2.21.65:730" forKey:@"XGJApiUrl"];//张玮
    //    [[NSUserDefaults standardUserDefaults] setValue:@"http://10.2.21.198:9999" forKey:@"XGJApiUrl"];//金迪
    //    [[NSUserDefaults standardUserDefaults] setValue:@"http://10.2.21.83:9998" forKey:@"XGJApiUrl"];//催扬
    //    [[NSUserDefaults standardUserDefaults] setValue:@"http://10.2.21.83:9999" forKey:@"BATWebUrl"];//催扬
    //    [[NSUserDefaults standardUserDefaults] setValue:@"http://10.2.21.90:8888" forKey:@"XGJApiUrl"];//李何苗
    
//    [userDeafaults setValue:@"http://api.bulter.test.jkbat.cn" forKey:@"XGJApiUrl"];
//    [userDeafaults setValue:@"http://test.jkbat.com" forKey:@"BATWebUrl"];
//    [userDeafaults setValue:@"http://search.test.jkbat.com" forKey:@"BATSearchUrl"];
//    [userDeafaults setValue:@"http://api.test.jkbat.com" forKey:@"BATApiUrl"];//BAT API地址
//    [userDeafaults setValue:@"http://weixin.test.jkbat.com" forKey:@"BATWeChatWebUrl"];//BAT微信H5地址
//    [userDeafaults setValue:@"http://mobile.hmtest.kmhealthcloud.cn:8165" forKey:@"KMHEALTH360APIURL"];
//    [userDeafaults setValue:@"http://dockang.jkbat.com" forKey:@"DrKangUrl"];
    [userDeafaults setValue:@"http://api.bulter.jkbat.cn" forKey:@"XGJApiUrl"];
    [userDeafaults setValue:@"http://www.jkbat.com" forKey:@"BATWebUrl"];
    [userDeafaults setValue:@"http://search.jkbat.com" forKey:@"BATSearchUrl"];
    [userDeafaults setValue:@"http://api.jkbat.com" forKey:@"BATApiUrl"];//
    [userDeafaults setValue:@"http://weixin.jkbat.com" forKey:@"BATWeChatWebUrl"];//
    [userDeafaults setValue:@"http://djymbgl.kmhealthcloud.com:9003" forKey:@"KMHEALTH360APIURL"];
    [userDeafaults setValue:@"http://dockang.jkbat.com" forKey:@"DrKangUrl"];
#elif AZURE
    //Azure测试环境
    [userDeafaults setValue:@"http://hc016tn-web.chinacloudsites.cn" forKey:@"XGJApiUrl"];
    [userDeafaults setValue:@"http://hc001tn-web.chinacloudsites.cn" forKey:@"BATWebUrl"];
    [userDeafaults setValue:@"http://search.test.jkbat.com" forKey:@"BATSearchUrl"];
    [userDeafaults setValue:@"http://hc001tn-app.chinacloudsites.cn" forKey:@"BATApiUrl"];//测试
    [userDeafaults setValue:@"http://weixin.test.jkbat.com" forKey:@"BATWeChatWebUrl"];//BAT微信H5地址
    [userDeafaults setValue:@"http://dockang.jkbat.com" forKey:@"DrKangUrl"];
    [userDeafaults setValue:@"http://mobile.hmtest.kmhealthcloud.cn:8165" forKey:@"KMHEALTH360APIURL"];

#elif AZUREPREVIEW
    //Azure预发布环境
    [userDeafaults setValue:@"http://api.bulter.apreview.jkbat.cn" forKey:@"XGJApiUrl"];
    [userDeafaults setValue:@"http://apreview.jkbat.com" forKey:@"BATWebUrl"];
    [userDeafaults setValue:@"http://search.apreview.jkbat.com" forKey:@"BATSearchUrl"];
    [userDeafaults setValue:@"http://api.apreview.jkbat.com" forKey:@"BATApiUrl"];//测试
    [userDeafaults setValue:@"http://weixin.test.jkbat.com" forKey:@"BATWeChatWebUrl"];//BAT微信H5地址
    [userDeafaults setValue:@"http://dockang.jkbat.com" forKey:@"DrKangUrl"];
    [userDeafaults setValue:@"http://mobile.hmtest.kmhealthcloud.cn:8165" forKey:@"KMHEALTH360APIURL"];

#elif PREVIEW
    
    //预发布
    [userDeafaults setValue:@"http://api.bulter.preview.jkbat.cn" forKey:@"XGJApiUrl"];
    [userDeafaults setValue:@"http://preview.jkbat.com" forKey:@"BATWebUrl"];
    [userDeafaults setValue:@"http://search.jkbat.com" forKey:@"BATSearchUrl"];
    [userDeafaults setValue:@"http://api.preview.jkbat.com" forKey:@"BATApiUrl"];
    [userDeafaults setValue:@"http://weixin.jkbat.com" forKey:@"BATWeChatWebUrl"];//BAT微信H5地址
    [userDeafaults setValue:@"http://djymbgl.kmhealthcloud.com:9003" forKey:@"KMHEALTH360APIURL"];
    [userDeafaults setValue:@"http://dockang.jkbat.com" forKey:@"DrKangUrl"];
#elif RELEASE
    //#warning 打包记得修改Scheme
    //正式（APPSTORE）
    [userDeafaults setValue:@"http://api.bulter.jkbat.cn" forKey:@"XGJApiUrl"];
    [userDeafaults setValue:@"http://www.jkbat.com" forKey:@"BATWebUrl"];
    [userDeafaults setValue:@"http://search.jkbat.com" forKey:@"BATSearchUrl"];
    [userDeafaults setValue:@"http://api.jkbat.com" forKey:@"BATApiUrl"];//
    [userDeafaults setValue:@"http://weixin.jkbat.com" forKey:@"BATWeChatWebUrl"];//
    [userDeafaults setValue:@"http://djymbgl.kmhealthcloud.com:9003" forKey:@"KMHEALTH360APIURL"];
    [userDeafaults setValue:@"http://dockang.jkbat.com" forKey:@"DrKangUrl"];

#endif
    [userDeafaults synchronize];

}

//+ (void)domainRequest {
//    AFHTTPSessionManager *manager = [HTTPTool managerWithBaseURL:nil sessionConfiguration:NO];
//    NSString * URL = @"http://www.jkbat.com/api/GetXGJApiUrl";
//    [manager GET:URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        DDLogVerbose(@"\nGET返回值---\n%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
//        id dic = [HTTPTool responseConfiguration:responseObject];
//
//        BATDomainModel * urlModel = [BATDomainModel mj_objectWithKeyValues:dic];
//        if (urlModel.ResultCode == 0) {
//            [[NSUserDefaults standardUserDefaults] setValue:urlModel.Data.XGJApiUrl forKey:@"XGJApiUrl"];
//            [[NSUserDefaults standardUserDefaults] setValue:urlModel.Data.storedominUrl forKey:@"storedominUrl"];
//            [[NSUserDefaults standardUserDefaults] setValue:urlModel.Data.hotquestionUrl forKey:@"hotquestionUrl"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//    }];
//
//}

@end
