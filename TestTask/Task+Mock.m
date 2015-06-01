//
//  Task+Mock.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "Task+Mock.h"

@implementation Task (Mock)

+ (NSArray *)mocksWithCount:(NSInteger)count
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        [array addObject:[self mockWithIndex:i]];
    }
    return [NSArray arrayWithArray:array];
}

+ (instancetype)mockWithIndex:(NSInteger)index
{
    Task *obj = [self new];
    [obj assignDataForMockWithIndex:index];
    return obj;
}

+ (instancetype)mock
{
    Task *obj = [self new];
    [obj assignDataForMockWithIndex:0];
    return obj;
}

- (void)assignDataForMockWithIndex:(NSInteger)index
{
    self.title = [NSString stringWithFormat:@"タイトル : %ld", (long)index];
    NSMutableString *str = [NSMutableString string];
    for (NSInteger i = 0; i < index + 1; i++) {
        [str appendFormat:@"メモ :  %ld", (long)i];
        [str appendString:(i % 3 == 0 ? @"\n" : @"")];
    }
    self.memo = [NSString stringWithString:str];
    switch (index % 5) {
        case 0:
            self.priority = TaskPriorityHigh;
            break;
        case 2:
            self.priority = TaskPriorityRow;
            break;
        default:
            self.priority = TaskPriorityNormal;
            break;
    }
}

@end
