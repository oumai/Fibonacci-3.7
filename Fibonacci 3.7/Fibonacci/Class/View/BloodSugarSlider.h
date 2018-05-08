//
//  BloodSugarSlider.h
//  Fibonacci
//
//  Created by woaiqiu947 on 2016/12/14.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXCircleSlider.h"
#import "BloodSugarJudgment.h"

@interface BloodSugarSlider : UIView<UITextFieldDelegate>
{
    CAGradientLayer *gradientLayer;
    JXCircleSlider *slider;
}
@property (nonatomic,assign)CGFloat angle;
@property (nonatomic,assign)EBloodSugarType bloodSugarType;
@property (nonatomic, strong)UITextField *textField;
@end
