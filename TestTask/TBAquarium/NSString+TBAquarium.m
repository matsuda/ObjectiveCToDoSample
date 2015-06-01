//
//  NSString+TBAquarium.m
//  TBAquarium
//
//  Created by Kosuke Matsuda on 2014/03/27.
//  Copyright (c) 2014年 matsuda. All rights reserved.
//

#import "NSString+TBAquarium.h"

static NSDictionary *tb_plurals = nil;

@implementation NSString (TBAquarium)

+ (NSDictionary *)tb_dictionaryPlurals
{
    if (!tb_plurals) {
        tb_plurals = @{
                      @"$"                         :   @"s"       ,
                      @"s$"                        :   @"s"       ,
                      @"(ax|test)is$"              :   @"$1es"    ,
                      @"(octop|vir)us$"            :   @"$1i"     ,
                      @"(alias|status)$"           :   @"$1es"    ,
                      @"(bu)s$"                    :   @"$1ses"   ,
                      @"(buffal|tomat)o$"          :   @"$1oes"   ,
                      @"([ti])um$"                 :   @"$1a"     ,
                      @"sis$"                      :   @"ses"     ,
                      @"(?:([^f])fe|([lr])f)$"     :   @"$1$2ves" ,
                      @"(hive)$"                   :   @"$1s"     ,
                      @"([^aeiouy]|qu)y$"          :   @"$1ies"   ,
                      @"(x|ch|ss|sh)$"             :   @"$1es"    ,
                      @"(matr|vert|ind)(?:ix|ex)$" :   @"$1ices"  ,
                      @"([m|l])ouse$"              :   @"$1ice"   ,
                      @"^(ox)$"                    :   @"$1en"    ,
                      @"(quiz)$"                   :   @"$1zes"   ,
                      };
    }
    return tb_plurals;
}

- (NSString *)tb_pluralizeString
{
    NSDictionary *plurals = [[self class] tb_dictionaryPlurals];
    NSArray *keys = [plurals allKeys];
    NSString *replaceStr = self;
    for (NSString *key in keys) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSString *s = [regex stringByReplacingMatchesInString:self
                                                      options:NSMatchingReportCompletion
                                                        range:NSMakeRange(0, self.length)
                                                 withTemplate:[plurals objectForKey:key]];
        if (![self isEqualToString:s]) replaceStr = s;
    }
    return replaceStr;
}

@end
