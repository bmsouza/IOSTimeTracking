//
//  URLConnectionDelegate.h
//  Hospitale
//
//  Created by AeC on 1/25/13.
//  Copyright (c) 2013 AeC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

typedef void (^successBlock_t)(int data, id jsonData);
typedef void (^successBlock_t_data)(int data, NSData* jsonData);
typedef void (^errorBlock_t)(NSError *error);
typedef void (^completeBlock_t)();

@interface URLConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSMutableData *data_;
    int statusCode;
    NSDictionary* responseHeaders;
    successBlock_t successBlock_;
    completeBlock_t completeBlock_;
    errorBlock_t errorBlock_;
    successBlock_t_data successBlock_t_data_;
}

+ (id)get:(NSString *)requestUrl headers:(NSDictionary*)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t) completeBlock;

+ (id)post:(NSString *)requestUrl withObject:(id)content headers:(NSDictionary*)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t) completeBlock;

- (id) initWithRequest:(NSString *)requestUrl withContent:(NSString*)content headers:(NSDictionary*)headers withMethod:(NSString*)method successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock  completeBlock:(completeBlock_t) completeBlock;

@property (weak, nonatomic) AppDelegate *appDelegate;
@end