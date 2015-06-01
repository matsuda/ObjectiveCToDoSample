//
//  TBMigration.h
//  TBAquarium
//
//  Created by Kosuke Matsuda on 2014/03/27.
//  Copyright (c) 2014年 matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const TBMigrationDidMigrateNotification;

@class TBDatabase;

@interface TBMigration : NSObject

+ (BOOL)migrateWithDatabase:(TBDatabase *)database;
+ (void)asyncMigrateWithDatabase:(TBDatabase *)database;
+ (NSUInteger)databaseVersion:(TBDatabase *)database;

@end

@interface TBMigration ()

/**
 Override this method for implementing migration.

 Migrations for database version 1 will run here.
 if ([self databaseVersion] < 2) {
    [self createXXXTable];
    return YES;
 }
 */
- (BOOL)migrateWithDatabaseVersion:(NSUInteger)version;

- (BOOL)executeMigration:(NSString*)sql, ...;

@end
