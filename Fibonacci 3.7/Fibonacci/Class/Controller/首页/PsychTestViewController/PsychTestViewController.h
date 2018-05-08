//
//  PsychTestViewController.h
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/19.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PsychTestViewController : KMUIViewController
{
    __weak IBOutlet UIWebView *myWebView;
//    UIImageView *HUDImageView;
    UIView *hudView;
    NSString *startStr;
    NSString *currentStr;
    BOOL once;
    NSInteger failCount;
    BOOL loading;
    UIView *badNetView;
}
@end
