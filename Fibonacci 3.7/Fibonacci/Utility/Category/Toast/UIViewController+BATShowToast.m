//
//  UIViewController+BATShowToast.m
//  HealthBAT_Pro
//
//  Created by KM on 16/8/222016.
//  Copyright © 2016年 KMHealthCloud. All rights reserved.
//

#import "UIViewController+BATShowToast.h"
#import "SVProgressHUD.h"

@implementation UIViewController (BATShowToast)

- (void)showProgress {
    [SVProgressHUD show];
}

- (void)showProgres:(float)progress {
    [SVProgressHUD showProgress:progress];
}

- (void)dismissProgress {
    [SVProgressHUD dismiss];
}

- (void)showText:(NSString *)text {
    [SVProgressHUD showImage:nil status:text];
}

- (void)showSuccessWithText:(NSString *)text {
    [SVProgressHUD showSuccessWithStatus:text];
}

- (void)showErrorWithText:(NSString *)text {
    [SVProgressHUD showErrorWithStatus:text];
}

- (void)showProgressWithText:(NSString *)text {
    [SVProgressHUD showWithStatus:text];
}

- (void)showSuccessWithText:(NSString *)text completion:(void (^)(void))completion {
    
    [SVProgressHUD showSuccessWithStatus:text];
    NSTimeInterval time = [SVProgressHUD displayDurationForString:text];
    [self bk_performBlock:^(id obj) {
        if (completion) {
            completion();
        }
    } afterDelay:time];
    
}

- (void)showErrorWithText:(NSString *)text completion:(void (^)(void))completion {
    
    [SVProgressHUD showErrorWithStatus:text];
    NSTimeInterval time = [SVProgressHUD displayDurationForString:text];
    [self bk_performBlock:^(id obj) {
        if (completion) {
            completion();
        }
    } afterDelay:time];
}

- (void)showText:(NSString *)text withInterval:(NSTimeInterval)interval {
    [SVProgressHUD setMinimumDismissTimeInterval:interval];
    [self showText:text];
}
@end
