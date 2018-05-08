//
//  BloodSugarJudgment.m
//  Fibonacci
//
//  Created by Apple on 2018/3/14.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "BloodSugarJudgment.h"

@implementation BloodSugarJudgment

+ (EBloodSugarDiagnosisType)diagnosisFromBloodSugarType:(EBloodSugarType)bloodSugarType bloodSugarValue:(CGFloat)value
{
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                       scale:1
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:NO];
    NSDecimalNumber *a = [[NSDecimalNumber alloc] initWithFloat:value];
    NSDecimalNumber *valueNumber = [a decimalNumberByRoundingAccordingToBehavior:roundUp];
    if (bloodSugarType != EBloodSugarTypeBeforeBreakfast)
    {
        NSDecimalNumber*lowNumber = [NSDecimalNumber decimalNumberWithString:@"4.4"];
        NSComparisonResult result = [valueNumber compare: lowNumber];
        if (result == NSOrderedAscending) {
            return  EBloodSugarDiagnosisTypeLow;
        }
    }
    switch (bloodSugarType) {
        case EBloodSugarTypeBeforeBreakfast:
            {
                NSDecimalNumber*lowNumber = [NSDecimalNumber decimalNumberWithString:@"4"];
                NSComparisonResult result = [valueNumber compare: lowNumber];
                if (result == NSOrderedAscending) {
                    return  EBloodSugarDiagnosisTypeLow;
                }
                
                NSDecimalNumber*normaNumber = [NSDecimalNumber decimalNumberWithString:@"5.6"];
                NSComparisonResult result2 = [valueNumber compare: normaNumber];
                if (result2 == NSOrderedAscending) {
                    return  EBloodSugarDiagnosisTypeNormal;
                }
                
                NSDecimalNumber*highNumber = [NSDecimalNumber decimalNumberWithString:@"7"];
                NSComparisonResult result3 = [valueNumber compare: highNumber];
                if (result3 == NSOrderedAscending) {
                    return  EBloodSugarDiagnosisTypeDamaged;
                }
                else {
                    return  EBloodSugarDiagnosisTypeDiabetes;
                }
            }
            break;
        case EBloodSugarTypeAfterBreakfast:
        case EBloodSugarTypeAfterLunch:
        case EBloodSugarTypeAfterDinner:
        case EBloodSugarTypeRandom:
        {
            NSDecimalNumber*lowNumber = [NSDecimalNumber decimalNumberWithString:@"8"];
            NSComparisonResult result = [valueNumber compare: lowNumber];
            if (result == NSOrderedAscending) {
                return  EBloodSugarDiagnosisTypeNormal;
            }
            else
            {
                return  EBloodSugarDiagnosisTypeHigh;
            }
        }
            break;
        case EBloodSugarTypeBeforeLunch:
        case EBloodSugarTypeBeforeDinner:
        case EBloodSugarTypeBeforeBedtime:
        case EBloodSugarTypeWeeHours:
        {
            NSDecimalNumber*lowNumber = [NSDecimalNumber decimalNumberWithString:@"6.1"];
            NSComparisonResult result = [valueNumber compare: lowNumber];
            if (result == NSOrderedAscending) {
                return  EBloodSugarDiagnosisTypeNormal;
            }
            else
            {
                return  EBloodSugarDiagnosisTypeHigh;
            }
        }
            break;
        default:
            break;
    }
    return  EBloodSugarDiagnosisTypeLow;
}



@end
