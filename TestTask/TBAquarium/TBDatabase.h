//
//  TBDatabase.h
//  TBAquarium
//
//  Created by Kosuke Matsuda on 2014/03/27.
//  Copyright (c) 2014年 matsuda. All rights reserved.
//

#import "FMDatabase.h"

@interface TBDatabase : FMDatabase

+ (instancetype)databaseWithFileName:(NSString *)fileName;
- (NSArray *)columnsForTableName:(NSString *)tableName;

@end
