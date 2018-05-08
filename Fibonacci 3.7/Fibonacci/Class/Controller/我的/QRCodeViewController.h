//
//  QRCodeViewController.h
//  Fibonacci
//
//  Created by woaiqiu947 on 16/10/9.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QRCodeVCType) {
    QRCodeVCTypeDefault           = 0,
    QRCodeVCTypeReader         = 1,
};

@interface QRCodeViewController : KMUIViewController
{
    
}
@property (nonatomic,assign) QRCodeVCType type;
@end
