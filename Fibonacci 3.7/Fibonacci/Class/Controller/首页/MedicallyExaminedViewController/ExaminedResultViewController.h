//
//  ExaminedResultViewController.h
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/23.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExaminedResultViewController : KMUIViewController
{
    __weak IBOutlet UITableView *myTableView;
    NSArray *typeArray;
    NSArray *detailArray;
    NSArray *valueArray;

}
@property (nonatomic, assign)NSInteger lowPressureValue;
@property (nonatomic, assign)NSInteger heightPressureValue;
@property (nonatomic, assign)NSInteger bloodOxygenValue;
@property (nonatomic, assign)NSInteger heartRateValue;

@end
