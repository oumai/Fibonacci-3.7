//
//  HTTPTool+HeartDataRequst.m
//  Fibonacci
//
//  Created by woaiqiu947 on 2017/3/10.
//  Copyright © 2017年 woaiqiu947. All rights reserved.
//

#import "HTTPTool+HeartDataRequst.h"
#import "KMDataManager.h"
#import "HealthKitManage.h"
#import "BATPerson.h"

@implementation HTTPTool (HeartDataRequst)

+ (void)getPhysicalRecoidCompletion:(void(^)(BOOL success,NSMutableDictionary * dict, NSError *error))completion
{
    BATPerson *person = PERSON_INFO;
    if (!LOGIN_STATION || person.Data.IDNumber.length< 1)
    {
        completion(NO,nil,nil);
        return;
    }
    
}


//+ (void)uploadHeartStepCountCompletion:(void(^)(BOOL success,NSMutableDictionary * dict, NSError *error))completion
//{
//    BATPerson *person = PERSON_INFO;
//    if (!LOGIN_STATION || person.Data.PhoneNumber.length< 1)
//    {
//        completion(NO,nil,nil);
//        return;
//    }
//
//    __block NSNumber * lastCountNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"STEPCONUT_UPLOAD_COUNT"];
//    [[HealthKitManage shareInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
//        if (success)
//        {
//            HealthKitManage *manage = [HealthKitManage shareInstance];
//            [manage getStepCountFromDate:[NSDate date] completion:^(double value, NSError *error) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    double lastValue = [lastCountNumber doubleValue];
//                    if (lastValue != value) {
//                        NSString *ResultValue = [NSString stringWithFormat:@"%.0f", value];
//                        NSTimeInterval interval= [[NSDate date]timeIntervalSince1970];
//                        double timeFloat =  interval*1000;
//                        NSString * TimeStamp = [NSString stringWithFormat:@"%.f",timeFloat]; //时间戳
//                        NSInteger  type = 6;
//                        NSString *typeStr = [NSString stringWithFormat:@"%li", type]; //类型
//                        NSDictionary *dic = @{@"OBJType":typeStr, @"TimeStamp":TimeStamp, @"ResultValue":ResultValue, @"BloodValue":@"",@"Type":@""};
//                        [[KMDataManager sharedDatabaseInstance] requestUpload:dic type:type timer:@0];
//                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                        [defaults setValue:[NSNumber numberWithDouble:interval] forKey:@"STEPCONUT_UPLOAD_TIME"];
//                        [defaults setValue:[NSNumber numberWithDouble:value] forKey:@"STEPCONUT_UPLOAD_COUNT"];
//                        [defaults synchronize];
//                        completion(YES,nil,nil);
//                        return;
//                    }
//                    else
//                    {
//                        completion(NO,nil,nil);
//                        return;
//                    }
//                });
//            }];
//        }
//        else
//        {
//            completion(NO,nil,nil);
//            return;
//        }
//    }];
//
//
//}

//+(BOOL)isUpdateHealthStepCount
//{
//    NSNumber * lastDateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"STEPCONUT_UPLOAD_TIME"];
//    NSNumber * lastCountNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"STEPCONUT_UPLOAD_COUNT"];
//    if (![lastCountNumber isKindOfClass:[NSNumber class]]) {
//        return YES;
//    }
//    double lastInterval = [lastDateNumber doubleValue];
//    double nowInterval = [[NSDate date ]timeIntervalSince1970];
//    if ((nowInterval - lastInterval) > 300) {
//        return YES;
//    }
//    return NO;
//}

@end
