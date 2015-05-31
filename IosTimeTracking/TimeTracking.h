//
//  TimeTracking.h
//  IosTimeTracking
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTracking : NSObject 

-(void) checkInOutWithUserName:(NSString*)userName andPassword:(NSString*)password callback:(void (^)(NSString*))callbackBlock;
-(void) getTime:(void (^)(NSDate*))callbackBlock;
@end
