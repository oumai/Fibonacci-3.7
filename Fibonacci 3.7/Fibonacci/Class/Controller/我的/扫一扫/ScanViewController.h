//
//  ScanViewController.h
//  车主app
//
//  Created by 郭鹏飞 on 15/5/4.
//  Copyright (c) 2015年 沃特智联. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface ScanViewController : KMUIViewController
{
    int num;
    BOOL upOrdown;
    NSTimer *timer;
}

@property (nonatomic, strong) UIImageView * imgViewScanLine;
@property (nonatomic, retain) UIImageView * line;


@end
