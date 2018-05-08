//
//  RecordTableViewCell.m
//  Fibonacci
//
//  Created by woaiqiu947 on 2016/12/19.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "RecordTableViewCell.h"
#import "BloodSugarDataModel.h"
#import "InsulinDataModel.h"
#import "BloodSugarJudgment.h"

@implementation RecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellData:(id)obj
{
    NSString *imageNameStr = @"";
    NSString *unitStr = @"";
    NSString *timeStr = @"";
    NSInteger type = 0;
    NSString *typeStr = @"";
    
    typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(MainScreenWidth-80-10-100, 0, 100, 50)];
    NSString *noteStr = @"";
    if ([obj isKindOfClass:[BloodSugarDataModel class]])
    {
        BloodSugarDataModel *model = (BloodSugarDataModel*)obj;
        imageNameStr = @"bloodglucose_icon";
        unitStr = @"mmol/L";
        CGFloat value = [model.value_id floatValue];
        _valueLabel.text = [NSString stringWithFormat:@"%0.1f", value];
        timeStr = model.time;
        type = [model.timeScale integerValue];
        EBloodSugarDiagnosisType diagnosisType = [BloodSugarJudgment diagnosisFromBloodSugarType:type-1 bloodSugarValue:value];
        if (diagnosisType == 1) {
            _valueLabel.textColor = RGB(38, 208, 254);

        }
        else if (diagnosisType == 0)
        {
            _valueLabel.textColor = RGB(253, 80, 137);
            self.lowOrHeight.image = [UIImage imageNamed:@"alert_red"];
        }
        else
        {
            _valueLabel.textColor = RGB(253, 175, 83);
            self.lowOrHeight.image = [UIImage imageNamed:@"alert_orange"];
        }
        
        NSArray *segmentTitleArray = @[@"早餐前",@"早餐后",@"午餐前",@"午餐后",@"晚餐前",@"晚餐后", @"睡前", @"凌晨", @"随机"];
        type --;
        if (type == [segmentTitleArray count])
        {
            type -- ;
        }
        typeStr = [NSString stringWithFormat:@"%@血糖",segmentTitleArray[type]];
        noteStr = model.note;
    }
    else
    {
        InsulinDataModel *model = (InsulinDataModel*)obj;
        imageNameStr = @"insulin_icon";
        unitStr = @"U";
        _valueLabel.text = [NSString stringWithFormat:@"%.1f",[model.dose floatValue]];
        _valueLabel.textColor = RGB(0, 0, 0);
        timeStr = model.time;
        NSArray *array = [model.name componentsSeparatedByString:@" "];
        typeStr = array[0];
        noteStr = model.note;

    }
    if (noteStr.length > 0)
    {
        CGFloat labelX = MainScreenWidth-80-10-100;
        typeLabel.frame = CGRectMake(labelX, 0, 100, 30);
        noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 25, 100, 20)];
        noteLabel.text = noteStr;
        noteLabel.textAlignment = NSTextAlignmentRight;
        noteLabel.textColor = [UIColor grayColor];
        noteLabel.font = [UIFont fontWithName:AppFontHelvetica size:11];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        [self.contentView addSubview:noteLabel];
    }
    _iconBG.image = [UIImage imageNamed: imageNameStr];
    
    _valueLabel.font = [UIFont fontWithName:AppFontHelvetica size:23];
    _valueLabel.textAlignment = NSTextAlignmentCenter;

    _unitLabel.textAlignment = NSTextAlignmentCenter;
    _unitLabel.textColor = RGB(91, 92, 93);
    _unitLabel.font = [UIFont fontWithName:AppFontHelvetica size:9];
    _unitLabel.text = unitStr;
    
//    timeStr = [timeStr substringWithRange:NSMakeRange(0,5)];
    timeStr = [timeStr substringToIndex:5];
    _timeLabel.text = timeStr;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.textColor = RGB(200, 200, 200);
    _timeLabel.font = [UIFont fontWithName:AppFontHelvetica size:14];
    
    typeLabel.text = typeStr;
    typeLabel.textAlignment = NSTextAlignmentRight;
    typeLabel.font = [UIFont fontWithName:AppFontHelvetica size:14];
    [self.contentView addSubview:typeLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
