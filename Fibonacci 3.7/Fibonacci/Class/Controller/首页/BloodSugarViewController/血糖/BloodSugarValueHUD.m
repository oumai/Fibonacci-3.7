//
//  BloodSugarValueHUD.m
//  Fibonacci
//
//  Created by woaiqiu947 on 2016/12/26.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "BloodSugarValueHUD.h"
#import "JudgeView.h"
#import "AppDelegate.h"
#define Help_Width    MainScreenWidth - 100
#define Help_Height    MainScreenWidth

@implementation BloodSugarValueHUD

+(void)presentViewFromValue:(CGFloat)value type:(EBloodSugarType)type
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)];
    blackView.backgroundColor = UIColorFromHEX(00000, 0);
    blackView.tag = 450;
    [window addSubview:blackView];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [blackView addGestureRecognizer:tapGesture];
    
    UIView *helpView = [[UIView alloc] initWithFrame:CGRectMake(50, MainScreenHeight, Help_Width, Help_Height)];
    helpView.layer.cornerRadius = 5;
    helpView.backgroundColor = [UIColor whiteColor];
    helpView.tag = 451;
    [window addSubview:helpView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, Help_Width, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:AppFontHelvetica size:16];
    titleLabel.textColor = RGB(51, 51, 51);
    [helpView addSubview:titleLabel];
    
    UIImage *image = nil;
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(titleLabel.frame), Help_Width - 60, 80)];
    [helpView addSubview:textLabel];
    textLabel.font = [UIFont fontWithName:AppFontHelvetica size:14];
    textLabel.numberOfLines = 0;
    textLabel.textColor = RGB(102, 102, 102);
    NSString *textString = @"";
    
    NSString *proposalStr = @"";
    EBloodSugarDiagnosisType diagnosisType = [BloodSugarJudgment diagnosisFromBloodSugarType:type bloodSugarValue:value];
    if (diagnosisType == 1)
    {
        titleLabel.text = @"血糖正常";
        textString = @"超赞哦！血糖控制很好，继续保持~";
        image = [UIImage imageNamed:@"blood_normal"];
        proposalStr = @"血糖控制很好，继续保持~";
    }
    else if (diagnosisType == 0)
    {
        titleLabel.text = @"血糖过低";
        textString = @"亲，您的血糖过低，建议进食和及时就医。";
        image = [UIImage imageNamed:@"blood_low"];
        proposalStr = @"请控制血糖在正常范围，必要时请于内分泌科就诊";
    }
    else
    {
        titleLabel.text = @"血糖过高";
        textString = @"亲，您的血糖过高，持续的高血糖容易出现酮症中毒或糖尿病急症，建议就医";
        image = [UIImage imageNamed:@"blood_heigth"];
        proposalStr = @"请复查血糖，低糖饮食，控制血糖在正常范围";
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:proposalStr forKey:KEY_KANG_PROPOSALSTRING];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textString length])];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(102, 102, 102) range:NSMakeRange(0, [textString length])];
    textLabel.attributedText = attributedString;
    
    CGFloat bgWidth = Help_Width-60-30;
    CGFloat bgHeigth = Help_Height-CGRectGetMaxY(textLabel.frame)-25-20;
    if (bgWidth < bgHeigth) {
        bgWidth = bgHeigth;
    }
    UIImageView *helpBG = [[UIImageView alloc] initWithFrame:CGRectMake((Help_Width-bgWidth)/2, CGRectGetMaxY(textLabel.frame)+20, bgWidth, bgWidth)];
    helpBG.image = image;
    [helpView addSubview:helpBG];
    
    JudgeView *view = [[JudgeView alloc] initWithFrame:CGRectMake((Help_Width-30)/2,Help_Height + 30, 30, 30) status:JudgeViewStatusButton];
    view.backgroundColor = [UIColor clearColor];
    view.layer.shouldRasterize = YES;
    [helpView addSubview:view];
    
    [UIView animateWithDuration:0.35f animations:^{
        CGRect rect = helpView.frame;
        rect.origin.y = (MainScreenHeight-Help_Height)/2;
        helpView.frame = rect;
        blackView.backgroundColor = UIColorFromHEX(00000, 0.85);
    } completion:^(BOOL finished) {
    }];

}

+(void)dismiss
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *blackView = [window viewWithTag:450];
    UIView *helpView = [window viewWithTag:451];
    
    //为了弹窗不那么生硬，这里加了个简单的动画
    [UIView animateWithDuration:0.2f animations:^{
        CGRect rect = helpView.frame;
        rect.origin.y = MainScreenHeight;
        helpView.frame = rect;
        blackView.alpha = 0;
    } completion:^(BOOL finished) {
        for (UIView *elem in helpView.subviews) {
            if ([elem isKindOfClass:[UIImageView class]])
            {
                UIImageView *view = (UIImageView *)elem;
                view.image = nil;
            }
            [elem removeFromSuperview];
        }
        [helpView removeFromSuperview];
        [blackView removeFromSuperview];
        AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *nav = delegate.rootViewController.selectedViewController;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 *NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [nav popViewControllerAnimated:YES];
        });
    }];
    
}
@end
