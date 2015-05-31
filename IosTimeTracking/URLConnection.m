//
//  URLConnectionDelegate.m
//  Hospitale
//
//  Created by AeC on 1/25/13.
//  Copyright (c) 2013 AeC. All rights reserved.
//

#import "URLConnection.h"
#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface URLConnection()

@property BOOL ErrorAlreadyDisplayed;
@property int erroCount;

@end

@implementation URLConnection

@synthesize ErrorAlreadyDisplayed;
@synthesize erroCount;
@synthesize appDelegate = _appDelegate;


+ (id)get:(NSString *)requestUrl headers:(NSDictionary*)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t) completeBlock
{
    return [[self alloc] initWithRequest:requestUrl withContent:nil headers:headers withMethod:@"GET" successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];
}

+ (id)post:(NSString *)requestUrl withObject:(id)content headers:(NSDictionary*)headers successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock completeBlock:(completeBlock_t) completeBlock
{
    NSError *error;
    NSMutableDictionary* copiedHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    //[copiedHeaders setObject:@"application/json" forKey:@"Content-type"];
    [copiedHeaders setObject:@"application/x-www-form-urlencoded" forKey:@"Content-type"];

    if (! content) {
        NSLog(@"Got an error: %@", error);
    } else {
        return [[self alloc] initWithRequest:requestUrl withContent:content headers:copiedHeaders withMethod:@"POST" successBlock:successBlock errorBlock:errorBlock completeBlock:completeBlock];

    }
    return nil;
}


- (id) initWithRequest:(NSString *)requestUrl withContent:(id)content headers:(NSDictionary*)headers withMethod:(NSString*)method successBlock:(successBlock_t)successBlock errorBlock:(errorBlock_t)errorBlock  completeBlock:(completeBlock_t) completeBlock
{
    
    if ((self=[super init])) {
        
        _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        data_ = [[NSMutableData alloc] init];
        
        successBlock_ = [successBlock copy];
        completeBlock_ = [completeBlock copy];
        errorBlock_ = [errorBlock copy];
        
        NSURL *url = [NSURL URLWithString:requestUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:method];
        
        if(headers)
        {
            for(NSString* header in headers)
            {
                [request setValue:[headers objectForKey:header] forHTTPHeaderField:header];
            }
        }
        
        if(content && ![content isKindOfClass:[NSData class]])
        {
            if([[headers objectForKey:@"Content-type"] isEqualToString:@"application/json"]){

                
                NSData* dataJsonRequest;
                @try {
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                                       options:NSJSONWritingPrettyPrinted error:&error];
                    
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    dataJsonRequest = [jsonString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                }
                @catch (NSException *exception) {
                    
                    dataJsonRequest = [content dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                }
                [request setHTTPBody:dataJsonRequest];
            }else{
                if([content isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dictionaryContent = (NSDictionary*)content;
                    NSMutableString *contentString = [NSMutableString new];
                    if (dictionaryContent != nil && dictionaryContent.count > 0) {
                        BOOL first = YES;
                        for (NSString *key in dictionaryContent) {
                            if (!first) {
                                [contentString appendString:@"&"];
                            }
                            first = NO;
                            
                            [contentString appendString:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            [contentString appendString:@"="];
                            [contentString appendString:[[dictionaryContent valueForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        }
                    }
                    
                    NSData *httpBody = [contentString dataUsingEncoding:NSUTF8StringEncoding];
                    [request setHTTPBody:httpBody];
                }
            }
        }

        
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    
    return self;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust :challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data_ setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    responseHeaders = [httpResponse allHeaderFields];
    
    statusCode  = (int)httpResponse.statusCode;
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [data_ appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([[responseHeaders objectForKey:@"Content-type"] isEqualToString:@"text/plain; charset=utf-8"]) {
        NSString* dataStr = [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding];
        
        if(successBlock_)
            successBlock_(statusCode,dataStr);
    }
    else {
        if([[responseHeaders objectForKey:@"Content-type"] isEqualToString:@"application/json"]){
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data_ options:NSJSONReadingMutableContainers error:nil];
            if([jsonObjects isKindOfClass:[NSDictionary class]] && [jsonObjects objectForKey:@"ExceptionMessage"] != nil){
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:[jsonObjects objectForKey:@"ExceptionMessage"] forKey:NSLocalizedDescriptionKey];
                
                NSError* error = [NSError errorWithDomain:@"com.topics" code:1 userInfo:details];
                if(errorBlock_)
                    errorBlock_(error);
            }
            else
            {
                if(successBlock_)
                    successBlock_(statusCode,jsonObjects);
            }
        }
    }
    
    if(completeBlock_)
        completeBlock_();
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(errorBlock_)
        errorBlock_(error);
    if(completeBlock_)
        completeBlock_();
    
}


@end