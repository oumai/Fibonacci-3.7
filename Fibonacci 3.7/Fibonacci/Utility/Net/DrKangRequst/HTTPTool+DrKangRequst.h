//
//  HTTPTool+DrKangRequst.h
//  Fibonacci
//
//  Created by Apple on 2018/3/15.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "HTTPTool.h"

@interface HTTPTool (DrKangRequst)
/**
 康博士接口
 
 @param URLString url
 @param parameters 参数
 @param success 成功
 @param failure 失败
 */
+ (void)requestWithDrKangURLString:(NSString *)URLString
                        parameters:(id)parameters
                        showStatus:(BOOL)show
                           success:(void (^)(id responseObject))success
                           failure:(void (^)(NSError * error))failure;
@end
