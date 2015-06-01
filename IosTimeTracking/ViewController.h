//
//  ViewController.h
//  IosTimeTracking
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController  <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@end

