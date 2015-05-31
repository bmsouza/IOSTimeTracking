//
//  NSDictionary+UrlEncode.m
//  IosTimeTracking
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import "NSDictionary+UrlEncode.h"

@implementation NSDictionary(UrlEncode)
- (NSString*)urlEncode
{
    return [[self encodeHttpBodyParamsWithParentKey:nil] componentsJoinedByString:@"&"];
}

- (NSArray*)encodeHttpBodyParamsWithParentKey:(NSString*)parentKey
{
    NSMutableArray *encodedParams = [NSMutableArray arrayWithCapacity:[self count]];
    
    for(NSString *dictKey in [self allKeys]) {
        
        id value = [self objectForKey:dictKey];
        NSString *key = dictKey;
        NSString *encodedValue;
        
        if([parentKey length] > 0) {
            key = [parentKey stringByAppendingFormat:@"[%@]", key];
        }
        
        // NSDictionary
        if([value isKindOfClass:[NSDictionary class]]) {
            NSArray *temp = [(NSDictionary*)value encodeHttpBodyParamsWithParentKey:dictKey];
            [encodedParams addObjectsFromArray:temp];
            
            // NSArray
        } else if([value isKindOfClass:[NSArray class]]) {
            NSArray *arrayValue = (NSArray*)value;
            NSArray *temp = [arrayValue encodeHttpBodyParamsWithKey:key];
            [encodedParams addObjectsFromArray:temp];
            
            // NSSet
        } else if([value isKindOfClass:[NSSet class]]) {
            NSArray *temp = [[value allObjects] encodeHttpBodyParamsWithKey:key];
            [encodedParams addObjectsFromArray:temp];
            
            // NSNull
        } else if([value isKindOfClass:[NSNull class]]) {
            [encodedParams addObject:[NSString stringWithFormat:@"%@=NULL", key]];
            
            // NSString & Others
        } else {
            encodedValue = [[value description] urlEncode];
            [encodedParams addObject:[NSString stringWithFormat:@"%@=%@", key, encodedValue]];
        }
        
        
    }
    
    return encodedParams;
}

@end
