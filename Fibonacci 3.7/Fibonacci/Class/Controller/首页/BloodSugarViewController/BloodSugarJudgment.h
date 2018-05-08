//
//  BloodSugarJudgment.h
//  Fibonacci
//
//  Created by Apple on 2018/3/14.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EBloodSugarType ) {
    EBloodSugarTypeBeforeBreakfast = 1, //早餐前
    EBloodSugarTypeAfterBreakfast,//早餐后
    EBloodSugarTypeBeforeLunch,//午餐前
    EBloodSugarTypeAfterLunch,//午餐后
    EBloodSugarTypeBeforeDinner,//晚餐前
    EBloodSugarTypeAfterDinner,//晚餐后
    EBloodSugarTypeBeforeBedtime,//睡前
    EBloodSugarTypeWeeHours,//凌晨
    EBloodSugarTypeRandom,//随机
};

typedef NS_ENUM(NSInteger, EBloodSugarDiagnosisType ) {
    EBloodSugarDiagnosisTypeLow = 0, //低
    EBloodSugarDiagnosisTypeNormal,// 正常
    EBloodSugarDiagnosisTypeHigh,// 高
    EBloodSugarDiagnosisTypeDamaged,//受损
    EBloodSugarDiagnosisTypeDiabetes,//糖尿病

};

@interface BloodSugarJudgment : NSObject

+ (EBloodSugarDiagnosisType)diagnosisFromBloodSugarType:(EBloodSugarType )bloodSugarType bloodSugarValue:(CGFloat)value;

@end
