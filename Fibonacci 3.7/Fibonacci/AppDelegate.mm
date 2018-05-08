//
//  AppDelegate.m
//  Fibonacci
//
//  Created by shipeiyuan on 16/8/19.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KMDataManager.h"
#import "BATLoginViewController.h"
#import "HTTPTool+BATDomainAPI.h"//获取域名
#import "AppDelegate+BATShare.h"
#import "AppDelegate+BATVersion.h"
#import "AppDelegate+BATInitXunfeiSDK.h"
#import "AppDelegate+NotificationCategory.h"
#import "BATNewDrKangViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize rootViewController = _rootViewController;
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    _rootViewController = [RootViewController new];
    _rootViewController.delegate =self;
    self.window.rootViewController = _rootViewController;
    [HTTPTool getDomain];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"ImageResolutionHeight"]) {
        [KMTools saveDeviceInfo];
    }
    [[KMDataManager sharedDatabaseInstance] updateDataBase];
    //获取最新的域名
    
    //初始化shareSDK
    [self bat_initShare];
    [self bat_initXunfeiSDK];
    // App ID: 在 App Analytics 创建应用后，进入数据报表页中，在“系统设置”-“编辑应用”页面里查看App ID。
    // 渠道 ID: 是渠道标识符，可通过不同渠道单独追踪数据。
    [TalkingData setVersionWithCode:[KMTools getVersionNumber] name:[KMTools getAppDisplayName]];
    [TalkingData sessionStarted:@"C2AC7C6674CC48C894DB37DDEAB93531" withChannelId:@"app store"];
    [KMTools updateAppStoreVersion];
    //监控网络状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.jkbat.com"];
    [reach startNotifier];
    return YES;
}

- (void)bat_setXcodeColorsConfigration {
    //开启使用 XcodeColors
    setenv("XcodeColors", "YES", 0);
    //检测
    char *xcode_colors = getenv("XcodeColors");
    if (xcode_colors && (strcmp(xcode_colors, "YES") == 0))
    {
        // XcodeColors is installed and enabled!
        NSLog(@"XcodeColors is installed and enabled");
    }
    //开启DDLog 颜色
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    //配置DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    
    NSLog(@"NSLog");
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
    
    DDLogError(@"%@",NSHomeDirectory());
}

- (void)reachabilityChanged:(NSNotification *)noti {
    
    BOOL isNetwork = YES;
    
    Reachability *reachability = [noti object];
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    switch (netStatus) {
        case NotReachable:
            DDLogDebug(@"无网络");
            isNetwork = NO;
            [[NSUserDefaults standardUserDefaults] setBool:isNetwork forKey:@"netStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_NOT_NET_STATION" object:nil];
            
            break;
        case ReachableViaWiFi:
            DDLogDebug(@"wifi网络");
            isNetwork = YES;
            [[NSUserDefaults standardUserDefaults] setBool:isNetwork forKey:@"netStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case ReachableViaWWAN:
            DDLogDebug(@"移动网络");
            isNetwork = YES;
            [[NSUserDefaults standardUserDefaults] setBool:isNetwork forKey:@"netStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        default:
            break;
    }
}

/** 创建shortcutItems */
- (void)configShortCutItems {
    NSMutableArray *shortcutItems = [NSMutableArray array];
    UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove];
    UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeFavorite];
    UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"1" localizedTitle:@"心率测量" localizedSubtitle:nil icon:icon1 userInfo:nil];
    UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"2" localizedTitle:@"血压测量" localizedSubtitle:nil icon:icon2 userInfo:nil];
    [shortcutItems addObject:item1];
    [shortcutItems addObject:item2];
    [[UIApplication sharedApplication] setShortcutItems:shortcutItems];
}

/** 处理shortcutItem */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    switch (shortcutItem.type.integerValue) {
        case 1:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"touchGotoVc" object:self userInfo:@{@"type":@"1"}];
        }
            break;
        case 2:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"touchGotoVc" object:self userInfo:@{@"type":@"2"}];
        }   break;
        default:
            break;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *VC =nav.topViewController;
    if (![VC isKindOfClass:[BATNewDrKangViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setValue:KEY_KANG_SELECTTABBAR forKey:KEY_KANG_SELECTTABBAR];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return YES;
}
@end
