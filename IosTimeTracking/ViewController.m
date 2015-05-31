//
//  ViewController.m
//  ;
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import "ViewController.h"
#import "TimeTracking.h"

@interface ViewController ()
@property (nonatomic, strong) TimeTracking* timeTracking;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSTimer*  timer;
@property (nonatomic, strong) NSDateFormatter *format;
@end

@implementation ViewController

@synthesize timeTracking;
@synthesize timer;
@synthesize format;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.format = [[NSDateFormatter alloc] init];
    [self.format setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    timeTracking = [[TimeTracking alloc] init];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.txtUserName.text = [prefs stringForKey:@"username"];
    self.txtPassword.text = [prefs stringForKey:@"password"];
}

-(void)viewWillAppear:(BOOL)animated{
    [timeTracking getTime:^(NSDate* date){
        self.date = date;
        timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimer:) userInfo:nil repeats:TRUE];
        [self lblDate].text = [format stringFromDate:date];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.txtPassword resignFirstResponder];
    [self.txtUserName resignFirstResponder];
}

- (void)onTimer:(NSTimer *)timer {
    self.date = [self.date dateByAddingTimeInterval:1];
    [self lblDate].text = [format stringFromDate:self.date];
}

- (IBAction)btnCheckInOut:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // saving an NSString
    [prefs setObject:self.txtUserName.text forKey:@"username"];
    [prefs setObject:self.txtPassword.text forKey:@"password"];
    
    [timeTracking checkInOutWithUserName:self.txtUserName.text andPassword:self.txtPassword.text callback:^(NSString *message) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Marcação" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil, nil];
        [alert show];
        
    }];    
}

@end
