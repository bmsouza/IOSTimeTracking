//
//  ViewController.m
//  ;
//
//  Created by Rafael Bertholdo on 5/31/15.
//  Copyright (c) 2015 Rafael Bertholdo. All rights reserved.
//

#import "ViewController.h"
#import "TimeTracking.h"
#import "HGBeacon.h"
#import <CoreBluetooth/CoreBluetooth.h>
@import CoreLocation;

@interface ViewController () <CBCentralManagerDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong) TimeTracking* timeTracking;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSTimer*  timer;
@property (nonatomic, strong) NSDateFormatter *format;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) bool hasBeenNotified;
@property (nonatomic,strong) CBCentralManager *_manager;
@property (nonatomic,strong) CBPeripheral *_peripheral;
@property (nonatomic,strong) NSUUID* currentUUID;

@end

@implementation ViewController

@synthesize timeTracking;
@synthesize timer;
@synthesize format;
@synthesize _manager;
@synthesize _peripheral;
@synthesize currentUUID;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.format = [[NSDateFormatter alloc] init];
    [self.format setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        //[self.locationManager requestWhenInUseAuthorization];
        //[self requestAlwaysAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    //[self.locationManager startUpdatingLocation];
    timeTracking = [[TimeTracking alloc] init];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.txtUserName.text = [prefs stringForKey:@"username"];
    self.txtPassword.text = [prefs stringForKey:@"password"];
    [self initRegion];
}


#pragma mark - interface posiiton

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (IBAction)btnScanBeaconClicked:(id)sender {
    //_manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingsURL];
}

-(void)viewWillAppear:(BOOL)animated{
    [timeTracking getTime:^(NSDate* date){
        self.date = date;
        timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimer:) userInfo:nil repeats:TRUE];
        [self lblDate].text = [format stringFromDate:date];
    }];

}


-(NSDate*)getLastNotifiedDate
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"lastNotifiedDate"];
}

-(void)setLastNotifiedDate:(NSDate*)value
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:value forKey:@"lastNotifiedDate"];
}

-(NSString*)getBeaconUUID
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"UUID_preference"];
}

-(void)setBeaconUUID:(NSString*)value
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:value forKey:@"UUID_preference"];
}

-(NSString*)getBeaconIdentifier
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"Identifier_preference"];
}

-(void)setBeaconIdentifier:(NSString*)value
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:value forKey:@"Identifier_preference"];
}

-(void)initRegion
{
    NSString* beaconUUID = [self getBeaconUUID];
    NSString* beanconIdentifier = [self getBeaconIdentifier];
    if(beaconUUID && beanconIdentifier)
    {

        NSUUID *guid = [[NSUUID alloc] initWithUUIDString:beaconUUID];
        
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:guid identifier:beanconIdentifier];
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
    
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

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if([region.identifier isEqualToString:[self getBeaconIdentifier]])
    {
        NSDate* currentDate = [NSDate date];
        NSDate* lastNotifiedDate = [self getLastNotifiedDate];
        int daysBetween = 1;
        if(lastNotifiedDate)
        {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:GregorianCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                                       fromDate:[self getLastNotifiedDate]
                                                         toDate:currentDate
                                                        options:0];
            daysBetween = (int)[components day];
        }
        if(daysBetween > 0)
        {
            [self setLastNotifiedDate:currentDate];
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            localNotification.alertBody = @"Lembrete: Registre o seu ponto no TT.";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]] && state == CLRegionStateInside) {
        [self locationManager:manager didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *) manager didStartMonitoringForRegion:(CLRegion *) region {
    [manager requestStateForRegion:region];
}

@end
