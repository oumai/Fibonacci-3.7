//
//  ExaminedTableViewCell.h
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/23.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExaminedTableViewCell : UITableViewCell
@property (strong, nonatomic)  UILabel *typeLabel;
@property (strong, nonatomic)  UILabel *valueLabel;
@property (strong, nonatomic)  UILabel *lowValueLabel;

- (void)setCellValue:(NSString *)value lowValue:(NSString *)lowValue;

@end
