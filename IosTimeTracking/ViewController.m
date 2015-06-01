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

@interface ViewController () <CBCentralManagerDelegate>
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
    
    timeTracking = [[TimeTracking alloc] init];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.txtUserName.text = [prefs stringForKey:@"username"];
    self.txtPassword.text = [prefs stringForKey:@"password"];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
}

- (IBAction)btnScanBeaconClicked:(id)sender {
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
        {
            NSDictionary *options = @{
                                      CBCentralManagerScanOptionAllowDuplicatesKey: @YES
                                      };
            [_manager scanForPeripheralsWithServices:nil
                                             options:options];
            NSLog(@"I just started scanning for peripherals");
            break;
        }
        case CBCentralManagerStateUnsupported:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beacon" message:@"Não foi possível scanear beacons." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil, nil];
            [alert show];
            break;
        }
        default:{
            break;
        }
    }
}
- (void)   centralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary *)advertisementData
                     RSSI:(NSNumber *)RSSI
{
    
    HGBeacon *beacon = [HGBeacon beaconWithAdvertismentDataDictionary:advertisementData];
    beacon.RSSI = RSSI;
    if (beacon) {
        _peripheral = peripheral;
        _peripheral.delegate = (id)self;
        
        currentUUID = beacon.proximityUUID;
        
        NSString* message = [NSString stringWithFormat:@"Deseja salvar o beacon %@ como padrão?", beacon.proximityUUID.UUIDString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Sim",@"Não", nil];
        [alert show];
        
    }
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Checks For Approval
    if (buttonIndex == 1) {
        [self setBeaconUUID:self.currentUUID.UUIDString];
        //[self setBeaconIdentifier:_peripheral.identifier];
        //do something because they selected button one, yes
    } else {
        //do nothing because they selected no
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [timeTracking getTime:^(NSDate* date){
        self.date = date;
        timer =  [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onTimer:) userInfo:nil repeats:TRUE];
        [self lblDate].text = [format stringFromDate:date];
    }];

}

-(NSString*)getBeaconUUID
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"UUID_preference"];
    
    
//    return @"DC0A818A-C7D3-4608-B8FB-A3E62DC952A2";
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
//    return @"com.bertholdo.beacon";
}

-(void)setBeaconIdentifier:(NSString*)value
{
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:value forKey:@"Identifier_preference"];
}

-(void)initRegion
{
    NSString* beaconUUID = [self getBeaconUUID];
    
    if(beaconUUID)
    {
        NSString* beanconIdentifier = [self getBeaconIdentifier];
        NSUUID *guid = [[NSUUID alloc] initWithUUIDString:beaconUUID];
        if(beanconIdentifier)
            self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:guid identifier:beanconIdentifier];
               
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

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if([self getBeaconUUID]){
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if([region.identifier isEqualToString:[self getBeaconIdentifier]])
    {
        if(!self.hasBeenNotified)
        {
            self.hasBeenNotified = true;
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            localNotification.alertBody = @"Lembrete: Registre o seu ponto no TT.";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
}


@end
