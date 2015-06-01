//
//  Task.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "Task.h"

@implementation Task

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dueDate = [NSDate date];
    }
    return self;
}

- (NSString *)dueDateAsString
{
    NSDateFormatter *formatter = [self dateFormatter];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm";
    return [formatter stringFromDate:self.dueDate];
}

- (NSDateFormatter *)dateFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *_instantce = nil;
    dispatch_once(&onceToken, ^{
        _instantce = [NSDateFormatter new];
    });
    return _instantce;
}

@end

NSString *TaskPropertyString(TaskProperty property) {
    switch (property) {
        case TaskPropertyTitle:
            return @"タイトル";
        case TaskPropertyPriority:
            return @"優先度";
        case TaskPropertyDueDate:
            return @"予定日時";
        case TaskPropertyMemo:
            return @"メモ";
    }
}

NSString *TaskPriorityString(TaskPriority priority) {
    switch (priority) {
        case TaskPriorityRow:
            return @"低";
        case TaskPriorityHigh:
            return @"高";
        default:
            return @"中";
    }
}
