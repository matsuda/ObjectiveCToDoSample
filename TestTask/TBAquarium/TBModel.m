//
//  TBModel.m
//  TBAquarium
//
//  Created by Kosuke Matsuda on 2014/03/27.
//  Copyright (c) 2014年 matsuda. All rights reserved.
//

#import "TBModel.h"
#import "NSString+TBAquarium.h"
#import <objc/runtime.h>

static const char * getPropertyType(objc_property_t property);

static TBDatabase *__database = nil;
static NSMutableDictionary *__tableCache = nil;


@interface FMResultSet (TBAquarium)
- (NSDictionary*)resultDictionaryWithPropertyList:(NSDictionary *)propertyList;
@end

@implementation FMResultSet (TBAquarium)
- (NSDictionary*)resultDictionaryWithPropertyList:(NSDictionary *)propertyList
{
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count([_statement statement]);

    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        int columnCount = sqlite3_column_count([_statement statement]);
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name([_statement statement], columnIdx)];
            id objectValue = [self objectForColumnIndex:columnIdx];
            NSString *type = [propertyList objectForKey:columnName];
            if ([type isEqualToString:@"NSDate"] && [objectValue isKindOfClass:[NSNumber class]]) {
                objectValue = [NSDate dateWithTimeIntervalSince1970:[objectValue doubleValue]];
            }
            [dict setObject:objectValue forKey:columnName];
        }
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    return nil;
}
@end


@interface TBModel ()

@property (nonatomic, assign) BOOL  savedInDatabase;
@property (nonatomic, strong) NSDictionary *propertyList;

+ (void)assertDatabaseExists;
- (NSArray *)propertyValues;

@end


@implementation TBModel

+ (void)setDatabase:(TBDatabase *)database
{
    if (__database != database) {
        __database = database;
        __tableCache = nil;
    }
}

+ (TBDatabase *)database
{
    return __database;
}

+ (void)assertDatabaseExists
{
    NSAssert([self database], @"Database not set.");
}

+ (NSString *)tableName
{
    NSString         *str = [[self class] description];
    NSMutableArray *parts = [NSMutableArray array];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z][a-z]*" options:0 error:nil];
    NSRange range = NSMakeRange(0, str.length);
    [regex enumerateMatchesInString:str options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [parts addObject:[str substringWithRange:[result rangeAtIndex:0]]];
    }];
    return [[[parts componentsJoinedByString:@"_"] tb_pluralizeString] lowercaseString];
}

- (TBDatabase *)database
{
    return [[self class] database];
}

#pragma mark - DB Methods

- (NSDictionary *)propertyList
{
    if (!_propertyList) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (int i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);

            // printf("name = %s\n", propName);
            if (propName) {
                const char *propType = getPropertyType(property);
                NSString *propertyName = [[NSString alloc] initWithCString:propName encoding:NSUTF8StringEncoding];
                NSString *propertyType = [[NSString alloc] initWithCString:propType encoding:NSUTF8StringEncoding];
                // NSLog(@"propertyName >>>> %@", propertyName);
                // NSLog(@"propertyType >>>> %@", propertyType);
                [dict setObject:propertyType forKey:propertyName];
            }
        }
        _propertyList = [NSDictionary dictionaryWithDictionary:dict];
        free(properties);
    }
    return _propertyList;
}

- (NSArray *)columns
{
    if (!__tableCache) {
        __tableCache = [@{} mutableCopy];
    }
    NSString *tableName = [[self class] tableName];
    NSArray *columns = [__tableCache objectForKey:tableName];

    if (!columns) {
        columns = [[self database] columnsForTableName:tableName];
        [__tableCache setObject:columns forKey:tableName];
    }
    return columns;
}

- (NSArray *)columnsWithoutPrimaryKey
{
    NSMutableArray *columns = [NSMutableArray arrayWithArray:[self columns]];
    [columns removeObjectAtIndex:0];
    return columns;
}

- (NSArray *)propertyValues
{
    NSMutableArray *values = [NSMutableArray array];

    for (NSString *column in [self columnsWithoutPrimaryKey]) {
        id value = [self valueForKey:column];
        if (value) {
            [values addObject:value];
        } else if ([column isEqualToString:@"createdAt"]) {
            [values addObject:[NSDate date]];
        } else {
            [values addObject:[NSNull null]];
        }
    }
    return values;
}

- (NSArray *)propertyValuesWithColumns:(NSArray *)columns
{
    NSMutableArray *values = [@[] mutableCopy];

    for (NSString *column in [self columnsWithoutPrimaryKey]) {
        if (![columns containsObject:column]) continue ;
        id value = [self valueForKey:column];
        if (value) {
            [values addObject:value];
        } else if ([column isEqualToString:@"createdAt"]) {
            [values addObject:[NSDate date]];
        } else {
            [values addObject:[NSNull null]];
        }
    }
    return values;
}

- (NSDate *)createdAt
{
    if (!_createdAt) return nil;
    if ([_createdAt isKindOfClass:[NSDate class]]) {
        return _createdAt;
    }
    NSNumber *numberOfdate = (NSNumber *)_createdAt;
    return [NSDate dateWithTimeIntervalSince1970:[numberOfdate unsignedIntegerValue]];
}

- (NSDate *)toLocalCreatedAt
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSDate   *date = [self createdAt];
    NSUInteger seconds = [tz secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:seconds sinceDate:date];
}

#pragma mark - Finder Methods

+ (instancetype)findById:(NSUInteger)primaryKey
{
    NSArray *results = [self findWithCondition:@"primaryKey = ?" withParameters:@[@(primaryKey)]];
    if ([results count]) {
        return results[0];
    } else {
        return nil;
    }
}

+ (NSArray *)findAll
{
    return [self findWithSql:[NSString stringWithFormat:@"SELECT * FROM %@", [self tableName]] withParameters:nil];
}

+ (NSArray *)findWithSql:(NSString *)sql withParameters:(NSArray *)parameters
{
    [self assertDatabaseExists];
    NSMutableArray *results = [@[] mutableCopy];
    FMResultSet  *resultSet = [[self database] executeQuery:sql withArgumentsInArray:parameters];
    while ([resultSet next]) {
        TBModel *model = [self new];
        [model setValuesForKeysWithDictionary:[resultSet resultDictionaryWithPropertyList:model.propertyList]];
        model.savedInDatabase = YES;
        [results addObject:model];
    }
    return results;
}

+ (NSArray *)findWithCondition:(NSString *)condition withParameters:(NSArray *)parameters
{
    return [self findWithSql:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [self tableName], condition] withParameters:parameters];
}

+ (NSArray *)findWithConditionForColumn:(NSString *)column withParameters:(NSArray *)parameters
{
    NSInteger count = [parameters count];
    if (count < 1) return nil;

    NSMutableArray *binds = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        [binds addObject:@"?"];
    }
    NSString *sql = [NSString stringWithFormat:@"%@ IN (%@)", column, [binds componentsJoinedByString:@","]];

    return [self findWithCondition:sql withParameters:parameters];
}

+ (NSUInteger)count
{
    NSArray *result = [self findWithSql:[NSString stringWithFormat:@"SELECT primaryKey FROM %@", [self tableName]] withParameters:nil];
    return result.count;
}

#pragma mark - CUD Methods

- (BOOL)save
{
    [[self class] assertDatabaseExists];
    if (!_savedInDatabase) {
        return [self insert];
    } else {
        return [self update];
    }
}

- (BOOL)insert
{
    NSMutableArray *parameterList = [[NSMutableArray alloc] init];
    NSArray *columns = [self columnsWithoutPrimaryKey];
    for (int i = 0; i < [columns count]; i++) {
        [parameterList addObject:@"?"];
    }

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) values(%@)", [[self class] tableName], [columns componentsJoinedByString:@", "], [parameterList componentsJoinedByString:@","]];
    return [self insertWithSql:sql withValues:[self propertyValues]];
}

- (BOOL)insertWithSql:(NSString *)sql withColumns:(NSArray *)columns
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (NSString *column in columns) {
        id value = [self valueForKey:column];
        if (value)
            [values addObject:value];
        else if ([column isEqualToString:@"createdAt"])
            [values addObject:[NSDate date]];
        else
            [values addObject:[NSNull null]];
    }

    BOOL result = [[self database] executeUpdate:sql withArgumentsInArray:values];
    _savedInDatabase = result;
    _primaryKey = [[self database] lastInsertRowId];
    return result;
}

- (BOOL)insertWithSql:(NSString *)sql withValues:(NSArray *)values
{
    BOOL result = [[self database] executeUpdate:sql withArgumentsInArray:values];
    _savedInDatabase = result;
    _primaryKey = [[self database] lastInsertRowId];
    return result;
}

- (BOOL)update
{
    NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE primaryKey = ?", [[self class] tableName], setValues];
    NSArray  *parameters = [[self propertyValues] arrayByAddingObject:@(_primaryKey)];
    BOOL result = [[self database] executeUpdate:sql withArgumentsInArray:parameters];
    _savedInDatabase = result;
    return result;
}

- (BOOL)updateWithColumns:(NSArray *)columns
{
    NSString *setValues = [[columns componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE primaryKey = ?", [[self class] tableName], setValues];
    NSArray  *parameters = [[self propertyValuesWithColumns:columns] arrayByAddingObject:@(_primaryKey)];
    BOOL result = [[self database] executeUpdate:sql withArgumentsInArray:parameters];
    _savedInDatabase = result;
    return result;
}

- (BOOL)delete
{
    [[self class] assertDatabaseExists];
    if (!_savedInDatabase) {
        return YES;
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE primaryKey = ?", [[self class] tableName]];
    BOOL result = [[self database] executeUpdate:sql withArgumentsInArray:@[@(_primaryKey)]];
    _savedInDatabase = NO;
    _primaryKey = 0;
    return result;
}

+ (BOOL)deleteWithCondition:(NSString *)condition withParameters:(NSArray *)parameters
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", [[self class] tableName], condition];
    return [[self database] executeUpdate:sql withArgumentsInArray:parameters];
}

+ (BOOL)deleteAll
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", [self tableName]];
    return [[self database] executeUpdate:sql];
}

#pragma mark - validate

- (BOOL)valid
{
    return YES;
}

@end

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}
