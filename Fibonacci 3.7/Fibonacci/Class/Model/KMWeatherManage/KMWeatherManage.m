//
//  KMWeatherManage.m
//  Fibonacci
//
//  Created by shipeiyuan on 2016/11/26.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "KMWeatherManage.h"
#import "HTTPTool+WeatherRequest.h"
#import "WeatherModel.h"

@implementation KMWeatherManage
@synthesize isFirstUpdate;

static KMWeatherManage *weatherManage = nil;

#define key @"5f024974459a4660acf7d88715ae293a"
#define CustomErrorDomain @"com.weather.get"

+ (KMWeatherManage *)sharedWeatherManage
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        weatherManage = [[self alloc] init];
        
    });
    return weatherManage;
}

-(id)init
{
    if (self=[super init])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        self.isFirstUpdate = YES;
        [self findCurrentLocation];
    }
    return self;
}

- (void)findCurrentLocation {
    [locationManager requestWhenInUseAuthorization];
}

- (BOOL)getLocationAuthorization
{
    CLAuthorizationStatus  status = [CLLocationManager authorizationStatus];
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse ||  status == kCLAuthorizationStatusAuthorizedAlways)
    {
        return YES;
    }
    return NO;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
//            NSLog(@"用户还未决定授权");
//            [self findCurrentLocation];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
//            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
//                NSLog(@"定位服务开启，被拒绝");
            } else {
//                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
//            NSLog(@"获得前后台授权");
            [locationManager startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
//            NSLog(@"获得前台授权");
            [locationManager startUpdatingLocation];
            break;
        }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.isFirstUpdate) {
        // 4
        self.isFirstUpdate = NO;
        return;
    }
    
    // 5
    CLLocation *newLocation = [locations lastObject];
    
    currentLocation = newLocation;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    // 反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (! error) {
            if ([placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                
                // 获取城市
                NSString *city = placemark.locality;
                if (! city) {
                    // 6
                    city = placemark.administrativeArea;
                }
                NSLog(@"%@",city);
                if (city.length >1) {
                    currentCity = city;
                    currentCity = [currentCity substringWithRange:NSMakeRange(0, [currentCity length] - 1)];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATA_LOCATION_SUCCESS" object:nil];
                }
//                [self getWeathercompletion:^(BOOL success, WeartherHe *obj, NSError *error) {
//                    if(success)
//                    {
//                        NSLog(@"现在气温%@",obj.now.tmp);
//                    }
//                }];
            } else if ([placemarks count] == 0) {
//                [TSMessage showNotificationWithTitle:@"GPS故障"
//                                            subtitle:@"定位城市失败"
//                                                type:TSMessageNotificationTypeError];
            }
        } else {
//            [TSMessage showNotificationWithTitle:@"网络错误"
//                                        subtitle:@"请检查您的网络"
//                                            type:TSMessageNotificationTypeError];
        }
    }];
    [locationManager stopUpdatingLocation];
}

//获取天气
- (void)getWeathercompletion:(void(^)(BOOL success,WeartherHe * obj, NSError *error))completion
{
//    [[NSUserDefaults standardUserDefaults]  removeObjectForKey:@"WEATHER_OBJ"];
//    [[NSUserDefaults standardUserDefaults]  removeObjectForKey:@"WEATHER_TIME"];

    if (currentCity.length == 0||loading)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [defaults objectForKey:@"WEATHER_OBJ"];
        WeartherHe *hehe = (WeartherHe *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        if ([hehe isKindOfClass:[WeartherHe class]]) {
            completion(YES,hehe,nil);
            return;
        }
        completion(NO,nil,nil);
        return;
    }
    if (![self isUpdateWeather])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [defaults objectForKey:@"WEATHER_OBJ"];
        WeartherHe *hehe = (WeartherHe *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        if ([hehe isKindOfClass:[WeartherHe class]]) {
            completion(YES,hehe,nil);
            return;
        }
        completion(NO,nil,nil);
        return;
    }
    loading = YES;
    //https://free-api.heweather.com/v5/
    NSDictionary *para = @{@"city":currentCity,@"key":key,@"lang":@""};
    [HTTPTool requestCityWeatherWithURLString:@"https://free-api.heweather.com/v5/now" parameters:para success:^(id responseObject) {
        loading = NO;
        WeartherHe *hehe = (WeartherHe *)responseObject;
//        NSLog(@"%@",hehe.status);
        if ([hehe.status isEqualToString:@"ok"])
        {
            double interval = [[NSDate date ]timeIntervalSince1970];
            NSNumber *number = [NSNumber numberWithDouble:interval];
            NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:hehe];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:myEncodedObject forKey:@"WEATHER_OBJ"];
            [defaults setValue:number forKey:@"WEATHER_TIME"];
            [defaults synchronize];
            completion(YES,hehe,nil);
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"返回结果不正确" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:CustomErrorDomain code:0 userInfo:userInfo];
            completion(NO,hehe,error);
        }
        
    }failure:^(id responseObject) {
        loading = NO;
        WeartherHe *hehe = (WeartherHe *)responseObject;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"请求失败" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:0 userInfo:userInfo];
        completion(NO,hehe,error);
    }];
}

-(BOOL)isUpdateWeather
{
    NSNumber * lastDateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"WEATHER_TIME"];
    if (![lastDateNumber isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    double lastInterval = [lastDateNumber doubleValue];
    double nowInterval = [[NSDate date ]timeIntervalSince1970];
    if (nowInterval - lastInterval > 1800) {
        return YES;
    }
    return NO;
}

//获取日出日落
- (void)getWeatherSunriseCompletion:(void(^)(BOOL success,WeartherAstro * obj, NSError *error))completion
{
    if (currentCity.length == 0||loadingSunrise)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [defaults objectForKey:@"WEATHER_SUNRISE_OBJ"];
        WeartherAstro *astro = (WeartherAstro *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        if ([astro isKindOfClass:[WeartherAstro class]]) {
            completion(YES,astro,nil);
            return;
        }
        completion(NO,nil,nil);
        return;
    }
    if (![self isUpdateWeatherSunrise])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *myEncodedObject = [defaults objectForKey:@"WEATHER_SUNRISE_OBJ"];
        WeartherAstro *astro = (WeartherAstro *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        if ([astro isKindOfClass:[WeartherAstro class]]) {
            completion(YES,astro,nil);
            return;
        }
        completion(NO,nil,nil);
        return;
    }
    loadingSunrise = YES;
    
    NSDictionary *para = @{@"city":currentCity,@"key":key,@"lang":@""};
    [HTTPTool requestCityWeatherWithURLString:@"https://free-api.heweather.com/v5/forecast" parameters:para success:^(id responseObject) {
        loadingSunrise = NO;
        WeartherHe *hehe = (WeartherHe *)responseObject;
//        NSLog(@"%@",hehe.status);
        if ([hehe.status isEqualToString:@"ok"])
        {
            double interval = [[NSDate date ]timeIntervalSince1970];
            NSNumber *number = [NSNumber numberWithDouble:interval];
            WeartherDaily*model = hehe.daily_forecast[0];
            WeartherAstro *astro = model.astro;
            NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:astro];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:myEncodedObject forKey:@"WEATHER_SUNRISE_OBJ"];
            [defaults setValue:number forKey:@"WEATHER_SUNRISE_TIME"];
            [defaults synchronize];
            completion(YES,astro,nil);
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"返回结果不正确" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:CustomErrorDomain code:0 userInfo:userInfo];
            completion(NO,nil,error);
        }
        
    }failure:^(id responseObject) {
        loading = NO;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"请求失败" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:CustomErrorDomain code:0 userInfo:userInfo];
        completion(NO,nil,error);
    }];

}

-(BOOL)isUpdateWeatherSunrise
{
    NSNumber * lastDateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"WEATHER_SUNRISE_TIME"];
    if (![lastDateNumber isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    double lastInterval = [lastDateNumber doubleValue];
    double nowInterval = [[NSDate date ]timeIntervalSince1970];
    if (nowInterval - lastInterval > 21600) {
        return YES;
    }
    return NO;
}

#pragma mark -
-(void)presentAlertView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法位置信息" message:@"请开启位置限：设置->隐私->位置->康美小管家" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=privacy"]];
    }];
    [alertController addAction:sureAction];
    UIAlertAction *canleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:canleAction];
    UIApplication *appDelegate = [UIApplication sharedApplication];
    [appDelegate.delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end
