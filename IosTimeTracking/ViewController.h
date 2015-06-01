//
//  ViewController.h
//  IosTimeTracking
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#ifdef __IPHONE_8_0
#define GregorianCalendar NSCalendarIdentifierGregorian
#else
#define GregorianCalendar NSGregorianCalendar
#endif

@interface ViewController : UIViewController  <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@end

