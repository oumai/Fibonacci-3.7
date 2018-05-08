//
//  BloodSugarValueHUD.h
//  Fibonacci
//
//  Created by woaiqiu947 on 2016/12/26.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BloodSugarJudgment.h"
@interface BloodSugarValueHUD : UIView

+(void)presentViewFromValue:(CGFloat)value type:(EBloodSugarType)type;
@end
