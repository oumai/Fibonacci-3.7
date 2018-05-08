//
//  HTMLViewController.h
//  Fibonacci
//
//  Created by Apple on 2018/1/17.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EWebType  ) {
    EWebMyRecordType            = 0,
    EWebHealthRecordType        = 1,
    EWebPsychTestType           = 2
};

typedef NS_ENUM(NSInteger, EHealthWebType  ) {
    EHealthWebTypeHome = 0,
    EHealthWebTypeEvaluateReport,
};

typedef NS_ENUM(NSInteger, ERecordWebType  ) {
    ERecordWebTypeBloodPressure = 1,
    ERecordWebTypeBloodSugar,
    ERecordWebTypePulse,
    ERecordWebTypeStep,
    ERecordWebTypeOxygen,
    ERecordWebTypeVitalCapacity,

};

@interface HTMLViewController : KMUIViewController
{
    BOOL once;
}
@property(nonatomic,assign)BOOL gotoOutView;
@property(nonatomic,assign)EWebType webType;
@property(nonatomic,assign)ERecordWebType recordWebType;
@property(nonatomic,assign)EHealthWebType healthWebType;
@property(nonatomic,assign)NSInteger contentID;
@end
