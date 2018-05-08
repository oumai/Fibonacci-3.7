//
//  MarriagePickerView.h
//  Fibonacci
//
//  Created by Apple on 2018/3/8.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MarriagePickerView;
@protocol MarriagePickerViewDelegate <NSObject>

- (void)marriagePickerView:(MarriagePickerView *)marriagePickerView didSelectRow:(NSInteger)row titleForRow:(NSString *)title;

@end

@interface MarriagePickerView : UIView

@property (nonatomic,strong) UIToolbar *toolBar;

@property (nonatomic,strong) UIPickerView *pickerView;

@property (nonatomic,weak) id<MarriagePickerViewDelegate> delegate;

- (void)show;

- (void)hide;

@end
