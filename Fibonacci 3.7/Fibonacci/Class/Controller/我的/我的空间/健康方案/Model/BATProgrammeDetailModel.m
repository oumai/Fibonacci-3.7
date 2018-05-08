//
//  BATProgrammeDetailModel.m
//  Fibonacci
//
//  Created by Apple on 2018/1/22.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "BATProgrammeDetailModel.h"

@implementation BATProgrammeDetailModel
MJExtensionCodingImplementation
@end

@implementation BATProgrammeDetailData
+ (NSDictionary *)objectClassInArray{
    return @{@"ProgrammeLst" : [BATProgrammeItem class],
             @"PlanLst" : [BATPlanItem class],
             @"ProductList" : [ProductList class],
             @"ClockInList" : [BATClockInItem class],
             @"RelevantSolutionList": [BATRelevantSolutionItem class]};
}
MJExtensionCodingImplementation
@end


@implementation BATProgrammeItem
MJExtensionCodingImplementation
@end

@implementation BATPlanItem
MJExtensionCodingImplementation
@end

@implementation ProductList
MJExtensionCodingImplementation
@end

@implementation BATClockInItem
MJExtensionCodingImplementation
@end

@implementation BATRelevantSolutionItem
MJExtensionCodingImplementation
@end
