//
//  HTTPTool+DrKangRequst.m
//  Fibonacci
//
//  Created by Apple on 2018/3/15.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "HTTPTool+DrKangRequst.h"

@implementation HTTPTool (DrKangRequst)
+ (void)requestWithDrKangURLString:(NSString *)URLString
                        parameters:(id)parameters
                        showStatus:(BOOL)show
                           success:(void (^)(id responseObject))success
                           failure:(void (^)(NSError * error))failure
{
    AFHTTPSessionManager *manager = [HTTPTool managerWithBaseURL:nil sessionConfiguration:NO];
    //请求的序列化
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //回复的序列化
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/javascript",@"text/json",@"text/plain", nil];
    NSString *URL = [[NSString stringWithFormat:@"%@%@",DR_KANG_URL,URLString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (LOGIN_STATION == YES) {
        NSString * token = [[NSUserDefaults standardUserDefaults] valueForKey:@"Token"];
        if (token) {
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"Token"];
        }
    }
    [manager POST:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        //成功
//        NSLog(@"成功 = %@",responseObject);
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"成功 = %@",string);
        NSDictionary *tempDictQueryDiamond = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"成功 = %@",tempDictQueryDiamond);
        if (success) {
            success(tempDictQueryDiamond);
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"\nURL---\n%@\n请求失败 error---\n%@", URL, error.description);
        NSLog(@"\nURL---\n%@\n请求失败 error---\n%@", URL, error.description);
        if (failure) {
            NSError * tmpError = [[NSError alloc] initWithDomain:@"CONNECT_FAILURE" code:-3 userInfo:@{NSLocalizedDescriptionKey:@"啊哦，无法连线上网",NSLocalizedFailureReasonErrorKey:@"未知",NSLocalizedRecoverySuggestionErrorKey:@"未知"}];
            failure(tmpError);
        }
        if (show) {
            [SVProgressHUD showImage:nil status:@"啊哦，无法连线上网"];
        }
    }];
}
@end
