//
//  Task+Mock.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "Task.h"

@interface Task (Mock)

+ (NSArray *)mocksWithCount:(NSInteger)count;
+ (instancetype)mock;

@end
