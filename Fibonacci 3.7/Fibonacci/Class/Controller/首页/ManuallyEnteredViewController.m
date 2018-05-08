//
//  ManuallyEnteredViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 2016/10/13.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "ManuallyEnteredViewController.h"

#import "DetectioResultViewController.h"
#import "BloodOxygenResultViewController.h"
#import "BloodDetectioResultViewController.h"
#import "VitalCapacityResultViewController.h"
#import "EyeTestResultViewController.h"



@interface ManuallyEnteredViewController ()
@property (nonatomic, strong) UIPickerView *valuePickerView;
@property (nonatomic, strong) UIPickerView *lowPickerView;
@property (nonatomic, strong) UILabel *hudLabel;
@property (nonatomic, strong) UILabel *heightHudLabel;
@property (nonatomic, strong) UILabel *lowHudLabel;
@property (nonatomic, strong) UIButton *confirmButton;
@end

@implementation ManuallyEnteredViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手动校准";
    [self pagesLayout];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self deleteRepeatVC];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout
- (void)pagesLayout {
    /**
     *  判断手机型号，调整整体布局
     */
    CGFloat lineSpa;
    if(iPhone5){
        lineSpa = 50;
    }
    else
    {
        lineSpa = 100;
    }
//    else if(iPhone6){
//        lineSpa = 15;
//        height = 45;
//    }else if(iPhone6p){
//        lineSpa = 20;
//        height = 50;
//    }else if(([UIScreen mainScreen].currentMode.size.height) > 1334){
//        lineSpa = 20;
//        height = 50;
//    }
//    CGFloat buttonY;
    WEAK_SELF(self);
    //是否血压
    BOOL isBloodPressure = NO;
    if (_enteredType == 1)
    {
        isBloodPressure = YES;
    }
    
    [self.view addSubview:self.hudLabel];
    [self.hudLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.top.equalTo(self.view.mas_top).offset(isBloodPressure?25:85);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(MainScreenWidth);
    }];
    
    if (isBloodPressure)
    {
        [self.view addSubview:self.heightHudLabel];
        [self.heightHudLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hudLabel.mas_bottom).offset(25);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(MainScreenWidth);
        }];
    }
    
    [self.view addSubview:self.valuePickerView];
    [self.valuePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (isBloodPressure) {
            make.top.equalTo(self.heightHudLabel.mas_bottom);
        }
        else
        {
            make.top.equalTo(self.hudLabel.mas_bottom).offset(95);
        }
        make.height.mas_equalTo(isBloodPressure?130.0:162.0);
        make.width.mas_equalTo(MainScreenWidth);
    }];
    
    if (_enteredType == 1)
    {
        [self.view addSubview:self.lowHudLabel];
        [self.lowHudLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.valuePickerView.mas_bottom);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(MainScreenWidth);
        }];
        
        [self.view addSubview:self.lowPickerView];
        [self.lowPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lowHudLabel.mas_bottom);
            make.height.mas_equalTo(isBloodPressure?130.0:162.0);
            make.width.mas_equalTo(MainScreenWidth);
        }];
    }
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-lineSpa);
        make.height.mas_equalTo(45);
        make.left.equalTo(self.valuePickerView.mas_left).offset(20);
        make.width.mas_equalTo(MainScreenWidth - 40);
    }];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (_enteredType) {
        case EEnteredHeartRateType:
        case EEnteredBloodPressureType:
        case EEnteredHealthStepType:
        case EEnteredVisionDataType:
            return 3;
            break;
        case EEnteredBloodOxygenType:
            return 2;
            break;
        case EEnteredVitalCapacityType:
            return 4;
            break;
//        case EEnteredVisionDataType:
//            return 3;
//            break;
        default:
            break;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_enteredType == EEnteredVisionDataType &&component ==1) {
        return 1;
    }
    return 10;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_enteredType == EEnteredVisionDataType &&component ==1) {
        return @".";
    }
    NSString *str = [NSString stringWithFormat:@"%li",row];
    return str;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component

{
    if (_enteredType == EEnteredVisionDataType &&component ==1) {
        return 20;
    }
    return 50;
}


#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    NSLog(@"%li",pickerView.numberOfComponents);
}

#pragma mark - Button
- (void)confirmAciton:(UIButton *)button
{
    NSInteger component = self.valuePickerView.numberOfComponents;
    NSString *numberStr = @"";
    for (int i = 0; i < component; i++)
    {
        NSInteger selectedRow = [self.valuePickerView selectedRowInComponent:i];
        
        if (_enteredType == EEnteredVisionDataType&&i==1) {
            numberStr = [numberStr stringByAppendingFormat:@"."];
        }
        else
        {
            numberStr = [numberStr stringByAppendingFormat:@"%li",selectedRow];
        }

    }

    CGFloat numberFloat = [numberStr floatValue];
    
    NSInteger lowComponent = self.lowPickerView.numberOfComponents;
    NSString *lowNumberStr = @"";
    for (int i = 0; i < lowComponent; i++)
    {
        NSInteger selectedRow = [self.lowPickerView selectedRowInComponent:i];
        lowNumberStr = [lowNumberStr stringByAppendingFormat:@"%li",selectedRow];
    }
    CGFloat lowNumberFloat = [lowNumberStr floatValue];

    switch (_enteredType) {
        case EEnteredHeartRateType:
        {
            if (numberFloat>220 ||numberFloat <50) {
                [self showText:@"请选择正确的数值"];
                return;
            }
            else
            {
                [self pushResultViewControllerNnumber:numberStr lowNumber:nil];
            }
        }
            break;
        case EEnteredBloodPressureType:
        {
            if (lowNumberFloat>120||numberFloat<80)
            {
                [self showText:@"请选择正确的数值"];
                return;
            }
            else
            {
                [self pushResultViewControllerNnumber:numberStr lowNumber:lowNumberStr];

            }
        }
            break;
        case EEnteredBloodOxygenType:
        {
            if (numberFloat>110 ||numberFloat <85) {
                [self showText:@"请选择正确的数值"];
                return;
            }
            else
            {
                [self pushResultViewControllerNnumber:numberStr lowNumber:nil];

            }
        }
            break;
        case EEnteredVitalCapacityType:
        {
            if (numberFloat <1000||numberFloat >6000) {
                [self showText:@"请选择正确的数值"];
                return;
            }
            else
            {
                [self pushResultViewControllerNnumber:numberStr lowNumber:nil];
            }
        }
            break;
        case EEnteredVisionDataType:
        {
            if (numberFloat >5.2) {
                [self showText:@"请选择正确的数值"];
                return;
            }
            else
            {
                [self pushResultViewControllerNnumber:numberStr lowNumber:nil];
            }
        }
            break;
        default:
            break;
    }
    [self showSuccessWithText:@"已添加数据"];
    [button setUserInteractionEnabled:NO];
}

- (void)pushResultViewControllerNnumber:(NSString *)numberStr lowNumber:(NSString *)lowNumberStr
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    NSInteger index = [marr count];
    [marr removeObjectAtIndex:index-2];
    self.navigationController.viewControllers = marr;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 *NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        switch (_enteredType) {
            case EEnteredHeartRateType:
            {
                NSInteger value = [numberStr integerValue];
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                DetectioResultViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"DetectioResultViewController"];
                workGradeViewController.sumCount = value;
                [self.navigationController pushViewController:workGradeViewController animated:YES];
            }
                break;
            case EEnteredBloodPressureType:
            {
                NSInteger value = [numberStr integerValue];
                NSInteger lowValue = [lowNumberStr integerValue];
                
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                BloodDetectioResultViewController *bloodDetectioResultViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodDetectioResultViewController"];
                bloodDetectioResultViewController.systolicPressure = value;
                bloodDetectioResultViewController.diatolicPressure = lowValue;
                bloodDetectioResultViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:bloodDetectioResultViewController animated:YES];
            }
                break;
            case EEnteredBloodOxygenType:
            {
                NSInteger value = [numberStr integerValue];
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                BloodOxygenResultViewController *viewController = [sboard instantiateViewControllerWithIdentifier:@"BloodOxygenResultViewController"];
                viewController.bloodOxygenValue = value;
                [self.navigationController pushViewController:viewController animated:YES];
            }
                break;
            case EEnteredVitalCapacityType:
            {
                NSInteger value = [numberStr integerValue];
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                VitalCapacityResultViewController *vitalCapacityResultViewController = [sboard instantiateViewControllerWithIdentifier:@"VitalCapacityResultViewController"];
                vitalCapacityResultViewController.markValue = value;
                [self.navigationController pushViewController:vitalCapacityResultViewController animated:YES];
            }
                break;
            case EEnteredVisionDataType:
            {
                CGFloat value = [numberStr floatValue];
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                EyeTestResultViewController *eyeTestResultViewController = [sboard instantiateViewControllerWithIdentifier:@"EyeTestResultViewController"];
                eyeTestResultViewController.value = value;
                [self.navigationController pushViewController:eyeTestResultViewController animated:YES];
            }
                break;
                
            default:
                break;
        }
    });
    

}

- (void)deleteRepeatVC
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    UIViewController *repeatVC;
    for (UIViewController *elem in marr ) {
        if ([elem isKindOfClass:[ManuallyEnteredViewController class]]) {
            if (!repeatVC) {
                repeatVC = elem;
            }
            else
            {
                [marr removeObject:repeatVC];
            }
        }
    }
    self.navigationController.viewControllers = marr;
}
#pragma mark - setter && getter
- (UILabel *)hudLabel
{
    if (!_hudLabel) {
        _hudLabel = [[UILabel alloc] init];
        _hudLabel.text = @"测试不准，尝试手动输入吧";
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.textColor = RGB(51, 51, 51);
        _hudLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 16];
    }
    return _hudLabel;
}

- (UILabel *)heightHudLabel
{
    if (!_heightHudLabel) {
        _heightHudLabel = [[UILabel alloc] init];
        _heightHudLabel.text = @"      高压/mmHg";
        _heightHudLabel.textAlignment = NSTextAlignmentLeft;
        _heightHudLabel.textColor = RGB(153, 153, 153);
        _heightHudLabel.backgroundColor = RGB(240, 240, 240);
        _heightHudLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 14];
    }
    return _heightHudLabel;
}

- (UILabel *)lowHudLabel
{
    if (!_lowHudLabel) {
        _lowHudLabel = [[UILabel alloc] init];
        _lowHudLabel.text = @"      低压/mmHg";
        _lowHudLabel.textAlignment = NSTextAlignmentLeft;
        _lowHudLabel.textColor = RGB(153, 153, 153);
        _lowHudLabel.backgroundColor = RGB(240, 240, 240);
        _lowHudLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 14];
    }
    return _lowHudLabel;
}

- (UIPickerView *)valuePickerView {
    if (!_valuePickerView) {
        _valuePickerView = [[UIPickerView alloc] init];
        _valuePickerView.delegate = self;
        _valuePickerView.dataSource = self;
        _valuePickerView.tag = 100;
    }
    return _valuePickerView;
}

- (UIPickerView *)lowPickerView
{
    if (!_lowPickerView) {
        _lowPickerView = [[UIPickerView alloc] init];
        _lowPickerView.delegate = self;
        _lowPickerView.dataSource = self;
        _lowPickerView.tag = 101;
    }
    return _lowPickerView;
}

- (UIButton *)confirmButton
{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom Title:@"确定" titleColor:[UIColor whiteColor] backgroundColor:AppColor backgroundImage:nil Font:[UIFont systemFontOfSize:17]];
        _confirmButton.layer.cornerRadius = 20.0f;
        [_confirmButton addTarget:self action:@selector(confirmAciton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
