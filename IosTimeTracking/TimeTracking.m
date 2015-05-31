//
//  TimeTracking.m
//  IosTimeTracking
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import "TimeTracking.h"
#import "URLConnection.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface TimeTracking ()

@property (nonatomic, strong) NSMutableDictionary* params;
@property (nonatomic, strong) NSMutableDictionary* headers;

@end


@implementation TimeTracking

#define URL_TT_CHECK_IN_OUT @"https://tt.ciandt.com/.net/index.ashx/SaveTimmingEvent";
#define URL_TT_TIME @"https://tt.ciandt.com/.net/index.ashx/GetClockDeviceInfo?deviceID=2";

@synthesize params;
@synthesize headers;

- (id)init {
    self = [super init];
    
    if (self) {
        params = [[NSMutableDictionary alloc] init];
        [params setObject:@"2" forKey:@"deviceID"];
        [params setObject:@"1" forKey:@"eventType"];
        [params setObject:@"" forKey:@"userName"];
        [params setObject:@"" forKey:@"password"];
        [params setObject:@"" forKey:@"cracha"];
        [params setObject:@"" forKey:@"costCenter"];
        [params setObject:@"" forKey:@"leave"];
        [params setObject:@"" forKey:@"func"];
        [params setObject:@"2" forKey:@"cdiDispositivoAcesso"];
        [params setObject:@"10" forKey:@"cdiDriverDispositivoAcesso"];
        [params setObject:@"7" forKey:@"cdiTipoIdentificacaoAcesso"];
        [params setObject:@"false" forKey:@"oplLiberarPETurmaRVirtual"];
        [params setObject:@"1" forKey:@"cdiTipoUsoDispositivo"];
        [params setObject:@"0" forKey:@"qtiTempoAcionamento"];
        [params setObject:@"Nenhuma" forKey:@"d1sEspecieAreaEvento"];
        [params setObject:@"Nenhum" forKey:@"d1sAreaEvento"];
        [params setObject:@"Nenhum(a)" forKey:@"d1sSubAreaEvento"];
        [params setObject:@"Nenhum" forKey:@"d1sEvento"];
        [params setObject:@"false" forKey:@"oplLiberarFolhaRVirtual"];
        [params setObject:@"false" forKey:@"oplLiberarCCustoRVirtual"];
        [params setObject:@"0" forKey:@"qtiHorasFusoHorario"];
        [params setObject:@"127.0.0.1" forKey:@"cosEnderecoIP"];
        [params setObject:@"7069" forKey:@"nuiPorta"];
        [params setObject:@"false" forKey:@"oplValidaSenhaRelogVirtual"];
        [params setObject:@"true" forKey:@"useUserPwd"];
        [params setObject:@"false" forKey:@"useCracha"];
        [params setObject:@"" forKey:@"dtTimeEvent"];
        [params setObject:@"false" forKey:@"oplLiberarFuncoesRVirtual"];
        [params setObject:@"0" forKey:@"sessionID"];
        [params setObject:@"0" forKey:@"selectedEmployee"];
        [params setObject:@"0" forKey:@"selectedCandidate"];
        [params setObject:@"0" forKey:@"selectedVacancy"];
        [params setObject:@"d/m/Y" forKey:@"dtFmt"];
        [params setObject:@"H:i:s" forKey:@"tmFmt"];
        [params setObject:@"H:i" forKey:@"shTmFmt"];
        [params setObject:@"d/m/Y H:i:s" forKey:@"dtTmFmt"];
        [params setObject:@"0" forKey:@"language"];
        [params setObject:@"" forKey:@"userName"];
        
        
        headers = [[NSMutableDictionary alloc] init];
        [headers setObject:@"Accept:*/*" forKey:@"Accept"];
        [headers setObject:@"clockDeviceToken=nHuH/qaEaN1TzYclwDbze2UcjZeQtjjudvHqcjFufA==" forKey:@"Cookie"];
        [headers setObject:@"android" forKey:@"Origin"];
        [headers setObject:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36" forKey:@"User-Agent"];
        
    }
    
    return self;
}

-(void) checkInOutWithUserName:(NSString*)userName andPassword:(NSString*)password callback:(void (^)(NSString*))callbackBlock{
    
    [params setObject:userName forKey:@"userName"];
    [params setObject:password forKey:@"password"];
    
    NSString* url = URL_TT_CHECK_IN_OUT;
    [URLConnection post:url withObject:params headers:headers successBlock:^(int data, id jsonData) {
        NSLog(@"%@",jsonData);
        if(data == 200)
        {
            NSString* responseData = (NSString*)jsonData;
            
            NSString *jsFunctionText = [NSString stringWithFormat: @"var response = %@; "
                                        " var msg = response.msg.msg;",responseData];
            
            JSContext* context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
            [context evaluateScript:jsFunctionText];
            callbackBlock([context[@"msg"] toString]);
        }else{
            callbackBlock(@"erro");
        }
        
    } errorBlock:nil completeBlock:nil];
}

-(void) getTime:(void (^)(NSDate*))callbackBlock {
    NSString* url = URL_TT_TIME;
    
    [URLConnection get:url headers:headers successBlock:^(int data, id jsonData) {
        NSString* responseData = (NSString*)jsonData;
        
        // defining a JavaScript function
        NSString *jsFunctionText = [NSString stringWithFormat: @"var response = %@; "
                                    " var data = response.deviceInfo.dtTimeEvent;",responseData];
        
        JSContext* context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
        [context evaluateScript:jsFunctionText];
        callbackBlock([context[@"data"] toDate]);
        
    } errorBlock:nil completeBlock:nil];
}
@end
