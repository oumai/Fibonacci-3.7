//
//  BATClockManager.m
//  HealthBAT_Pro
//
//  Created by cjl on 2017/3/2.
//  Copyright © 2017年 KMHealthCloud. All rights reserved.
//

#import "BATClockManager.h"
#import "BATMyProgrammesModel.h"
#import "BATProgrammeDetailModel.h"
#import "GLDateUtils.h"
#import "BATPerson.h"
@implementation BATClockManager

+ (BATClockManager *)shared
{
    static BATClockManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BATClockManager alloc] init];
    });
    return instance;
}

- (void)resetClock
{
    //防止未清成功
    [self removeClock:nil];

    [HTTPTool requestWithURLString:@"/api/trainingteacher/GetMyProgrammes" parameters:@{@"pageIndex":@(0),@"pageSize":@(NSIntegerMax)} showStatus:YES type:kGET success:^(id responseObject) {
        
        BATMyProgrammesModel *myProgrammesModel = [BATMyProgrammesModel mj_objectWithKeyValues:responseObject];
        
        for (ProgrammesData *program in myProgrammesModel.Data) {
            if (program.IsFlag) {
                for (BATProgrammeItem *programItem in program.ProgrammeLst) {
                    [self settingClock:programItem.Title body:programItem.ResultDesc clockTime:programItem.JobTime identifier:[NSString stringWithFormat:@"template_%ld_%ld",(long)program.TemplateID,(long)programItem.ID] nextDay:program.IsSecondDayOpenclock];
                }
            }
        }

    } failure:^(NSError *error) {
        
    }];
}

- (NSTimeInterval)changeSecond:(NSString *)time
{
    
    NSArray *times = [time componentsSeparatedByString:@":"];
    NSInteger hour = [[times objectAtIndex:0] integerValue];
    NSInteger minute = [[times objectAtIndex:1] integerValue];
    
    if (hour - 8 > 0) {
        return (hour - 8) * 60 * 60 + minute * 60;
    } else if (hour - 8 < 0) {
        return (24 - 8 + hour) * 60 * 60 + minute * 60;
    } else {
        
        NSCalendar *calender = [NSCalendar autoupdatingCurrentCalendar];
        
        NSDateComponents *components = [calender components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
        
        if (minute > [components minute]) {
            return minute * 60;
        } else {
            return 24 * 60 * 60 + minute * 60;
        }
    }
    
}

- (void)settingClock:(NSString *)title body:(NSString *)body clockTime:(NSString *)clockTime identifier:(NSString *)identifier nextDay:(BOOL)isNextDay
{
   
}

- (void)registerHealthThreeSecondLocalNotificationWithTitle:(NSString *)title body:(NSString *)body date:(NSDate*)date {
//    JPushNotificationContent *content = [[JPushNotificationContent alloc] init];
//    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
//    [userInfo jk_setObj:@"BATHealthThreeSecondKey" forKey:BATHealthThreeSecondKey];
//    if (title != nil) {
//        content.title = title;
//        [userInfo jk_setObj:title forKey:@"title"];
//    }
//    if (body != nil) {
//        content.body = body;
//        [userInfo jk_setObj:body forKey:@"body"];
//    }
//    content.userInfo = userInfo;
//    JPushNotificationTrigger *trigger = [[JPushNotificationTrigger alloc] init];
//    trigger.repeat = YES;
//
//    NSDate *tempDate = nil;
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:BATHealthThreeSecondDateKey] == nil) {
//        NSDate *date = [NSDate date];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSDate *threeDate = [GLDateUtils dateByAddingDays:3 toDate:date];
//        NSString *dateStr = [formatter stringFromDate:threeDate];
//        NSArray *dateArr = [dateStr componentsSeparatedByString:@" "];
//        NSString *threeDateStr = [NSString stringWithFormat:@"%@ %@",dateArr[0],@"21:00:00"];
//        NSDate *tDate = [formatter dateFromString:threeDateStr];
//        [[NSUserDefaults standardUserDefaults] setObject:tDate forKey:BATHealthThreeSecondDateKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        tempDate = tDate;
//    } else {
//        tempDate = date;
//    }
//    NSCalendar *calender = [NSCalendar autoupdatingCurrentCalendar];
//    NSDateComponents *components = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:tempDate];
//
////    if (IS_IOS10) {
////        trigger.dateComponents = components;
////    } else {
////        trigger.fireDate = tempDate;
////    }
//
//    if (IS_IOS10) {
//        trigger.timeInterval = 60;
//    } else {
//        trigger.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];
//    }
//    JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
//    request.content = content;
//    request.trigger = trigger;
//    request.requestIdentifier = BATHealthThreeSecondKey;
//    request.completionHandler = ^(id result) {
//        DDLogDebug(@"%@", result);
//    };
//    [JPUSHService addNotification:request];
}

//- (void)removeHealthThreeSecondNotification {
//    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
//    identifier.identifiers = @[BATHealthThreeSecondKey];
//    [JPUSHService removeNotification:identifier];
//}

//- (void)registerHealthThreeSecondLocalNotificationWith:(NSInteger)alerTime {
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    content.body = [NSString localizedUserNotificationStringForKey:@"要坚持记录，为你的健康打卡！" arguments:nil];
//    content.sound = [UNNotificationSound defaultSound];
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime repeats:YES];
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:BATHealthThreeSecondKey content:content trigger:trigger];
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        if (!error) {
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"健康3秒钟成功添加本地推送" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//            [alertVC addAction:cancelAction];
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
//        }
//    }];
//}


- (void)removeClock:(NSArray *)identifiers
{
//    JPushNotificationIdentifier *identifier = [[JPushNotificationIdentifier alloc] init];
//    identifier.identifiers = identifiers;
//    [JPUSHService removeNotification:identifier];
//    if (identifiers == nil) {
//        BATPerson *person = PERSON_INFO;
//        NSInteger accountID = person.Data.AccountID;
//        NSInteger saveAccountID = [[NSUserDefaults standardUserDefaults] integerForKey:isRecordHealthThreeSecondAccountID];
//        NSDate *saveDate = [[NSUserDefaults standardUserDefaults] objectForKey:BATHealthThreeSecondDateKey];
//        if (saveDate != nil && accountID == saveAccountID) {
//            [self registerHealthThreeSecondLocalNotificationWithTitle:nil body:@"要坚持记录，为你的健康打卡！" date:saveDate];
//        }
//    }
}

@end
