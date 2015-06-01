//
//  TBDatabase.m
//  TBAquarium
//
//  Created by Kosuke Matsuda on 2014/03/27.
//  Copyright (c) 2014年 matsuda. All rights reserved.
//

#import "TBDatabase.h"
#import "TBModel.h"

@implementation TBDatabase

+ (instancetype)databaseWithPath:(NSString *)inPath
{
    TBDatabase *db = [super databaseWithPath:inPath];
    [TBModel setDatabase:db];
    return db;
}

+ (instancetype)databaseWithFileName:(NSString *)fileName
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths[0];
    return [self databaseWithPath:[documentDirectory stringByAppendingPathComponent:fileName]];
}

- (NSArray *)columnsForTableName:(NSString *)tableName
{
    NSMutableArray *rows = [@[] mutableCopy];
    FMResultSet *resultSet = [self executeQuery:[NSString stringWithFormat:@"pragma table_info(%@)", tableName]];
    while ([resultSet next]) {
        [rows addObject:[resultSet resultDictionary]];
    }
    return [rows valueForKey:@"name"];
}

@end
