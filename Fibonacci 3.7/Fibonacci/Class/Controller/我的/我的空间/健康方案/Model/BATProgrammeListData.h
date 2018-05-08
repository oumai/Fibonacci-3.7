//
//  BATProgrammeListData.h
//  Fibonacci
//
//  Created by shipeiyuan on 2018/1/20.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@class BATProgrammeData;
@interface BATProgrammeListData : NSObject
@property (nonatomic, assign) NSInteger    PageIndex;

@property (nonatomic, assign) NSInteger    PageSize;

@property (nonatomic, assign) NSInteger    RecordsCount;

@property (nonatomic, assign) NSInteger    ResultCode;

@property (nonatomic, copy  ) NSString     *ResultMessage;

@property (nonatomic, strong) NSArray <BATProgrammeData*> *Data;

@end

@interface BATProgrammeData : NSObject

@property (nonatomic, assign) NSInteger    ClockInCount;

@property (nonatomic, copy  ) NSString     *ComplateTime;

@property (nonatomic, copy  ) NSString     *CreatedTime;

@property (nonatomic, assign) NSInteger    ExpectClockInCount;

@property (nonatomic, assign) NSInteger    ID;

@property (nonatomic, assign) NSInteger    IsFlag;

@property (nonatomic, assign) NSInteger    IsSecondDayOpenclock;

@property (nonatomic, assign) NSInteger    JoinCount;

@property (nonatomic, copy  ) NSString     *ProgrammeLst;

@property (nonatomic, copy  ) NSString     *Remark;

@property (nonatomic, assign) NSInteger    TemplateID;

@property (nonatomic, copy  ) NSString     *TemplateImage;

@property (nonatomic, copy  ) NSString     *Theme;


@end
