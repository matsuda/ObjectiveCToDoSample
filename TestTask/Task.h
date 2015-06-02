//
//  Task.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "TBModel.h"

typedef NS_ENUM(NSInteger, TaskProperty) {
    TaskPropertyTitle,
    TaskPropertyPriority,
    TaskPropertyDueDate,
    TaskPropertyMemo,
};

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityRow = -1,
    TaskPriorityNormal,
    TaskPriorityHigh,
};

@interface Task : TBModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *memo;
@property (nonatomic, copy) NSDate *dueDate;
@property (nonatomic, assign) TaskPriority priority;

- (NSString *)dueDateAsString;

@end

FOUNDATION_EXPORT NSString *TaskPropertyString(TaskProperty property);
FOUNDATION_EXPORT NSString *TaskPriorityString(TaskPriority priority);
