//
//  ExaminedTableViewCell.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/23.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "ExaminedTableViewCell.h"

@implementation ExaminedTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellValue:(NSString *)value lowValue:(NSString *)lowValue
{
    WEAK_SELF(self);
    UIView *layer = [[UIView alloc] init];
    layer.backgroundColor = RGB(244, 244, 244);
    [self.contentView addSubview:layer];
    [layer mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.height.mas_equalTo(1);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(MainScreenWidth-20);
    }];
    
    [self.contentView addSubview: self.typeLabel];
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(100);
    }];
    
    if (lowValue) {
        [self.contentView addSubview: self.valueLabel];
        [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF(self);
            make.top.equalTo(_typeLabel.mas_bottom).offset(5);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_centerX);
            make.height.mas_equalTo(80);
        }];
        
        [self.contentView addSubview: self.lowValueLabel];
        [_lowValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF(self);
            make.top.equalTo(_typeLabel.mas_bottom).offset(5);
            make.left.equalTo(self.contentView.mas_centerX);
            make.right.equalTo(self.contentView.mas_right);
            make.height.mas_equalTo(80);
        }];
        _valueLabel.attributedText = [self getValueAttributedText:value];
        _lowValueLabel.attributedText = [self getValueAttributedText:lowValue];

    }
    else
    {
        [self.contentView addSubview: self.valueLabel];
        [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            STRONG_SELF(self);
            make.top.equalTo(_typeLabel.mas_bottom).offset(5);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.height.mas_equalTo(80);
        }];
        _valueLabel.attributedText = [self getValueAttributedText:value];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Property
- (UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel labelWithFont: [UIFont fontWithName:AppFontHelvetica size:16] textColor: [UIColor blackColor] textAlignment: NSTextAlignmentCenter];
        _typeLabel.backgroundColor = [UIColor whiteColor];
    }
    return _typeLabel;
}

- (UILabel *)valueLabel
{
    if (!_valueLabel) {
        _valueLabel = [UILabel labelWithFont: [UIFont fontWithName:AppFontHelvetica size:20] textColor: [UIColor grayColor] textAlignment: NSTextAlignmentCenter];
    }
    return _valueLabel;
}

- (UILabel *)lowValueLabel
{
    if (!_lowValueLabel) {
        _lowValueLabel = [UILabel labelWithFont: [UIFont fontWithName:AppFontHelvetica size:20] textColor: [UIColor grayColor] textAlignment: NSTextAlignmentCenter];
    }
    return _lowValueLabel;
}

#pragma mark -
- (NSMutableAttributedString *)getValueAttributedText:(NSString* )text
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(251, 85, 92) range:NSMakeRange(0, 3)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(3, text.length - 3)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(0, 3)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(3, text.length - 3)];
    return attributedString;
}

@end
