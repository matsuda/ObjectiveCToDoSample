//
//  ToDoMigration.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/02.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "ToDoMigration.h"
#import "Task.h"

@implementation ToDoMigration

- (BOOL)migrateWithDatabaseVersion:(NSUInteger)version
{
    BOOL didMigrate = NO;
    if (version < 1) {
        [self createTaskTable];
        didMigrate = YES;
    }
    return didMigrate;
}

- (void)createTaskTable
{
    @autoreleasepool {
        NSString *tableName = [Task tableName];
        NSString *sql;
        sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
        [self executeMigration:sql];

        sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ("
               "primaryKey INTEGER PRIMARY KEY AUTOINCREMENT,"
               "title TEXT,"
               "memo TEXT,"
               "priority INTEGER,"
               "dueDate REAL"
               ")", tableName];
        [self executeMigration:sql];

        // index
        sql = [NSString stringWithFormat:@"CREATE INDEX createdAt_%@ ON %@ (dueDate)", tableName, tableName];
        [self executeMigration:sql];
    }
}

@end
