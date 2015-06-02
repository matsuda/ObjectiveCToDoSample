//
//  TBModel.h
//  TBAquarium
//
//  Created by Kosuke Matsuda on 2014/03/27.
//  Copyright (c) 2014年 matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBDatabase.h"

@interface TBModel : NSObject <NSCopying>

@property (nonatomic, assign) sqlite_int64 primaryKey;
@property (nonatomic, strong) NSDate *createdAt;

+ (NSString *)tableName;
+ (void)setDatabase:(TBDatabase *)database;
+ (TBDatabase *)database;

+ (instancetype)findById:(NSUInteger)primaryKey;
+ (NSArray *)findAll;
+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters;
+ (NSArray *)findWithCondition:(NSString *)condition withParameters:(NSArray *)parameters;
+ (NSArray *)findWithConditionForColumn:(NSString *)column withParameters:(NSArray *)parameters;
+ (NSUInteger)count;

- (BOOL)updateWithColumns:(NSArray *)columns;
- (BOOL)save;
- (BOOL)insert;
- (BOOL)insertWithSql:(NSString *)sql withColumns:(NSArray *)columns;
- (BOOL)insertWithSql:(NSString *)sql withValues:(NSArray *)values;
- (BOOL)delete;
+ (BOOL)deleteWithCondition:(NSString *)condition withParameters:(NSArray *)parameters;
+ (BOOL)deleteAll;

@end

@interface TBModel (Protected)
// NSCopying
- (void)copyWithOrigin:(id)origin;
@end