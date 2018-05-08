//
//  HTMLViewController.m
//  Fibonacci
//
//  Created by Apple on 2018/1/17.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "HTMLViewController.h"
#import "BATJSObject.h"
#import "WHAnimation.h"
#import "AppDelegate+BATShare.h"
#import "ShareCustom.h"
#import "BATPerson.h"

#import "BloodSugarViewController.h"
#import "BloodOxygenViewController.h"
#import "BloodPressureDetectioViewController.h"
#import "HeartRateDetectioViewController.h"
#import "VitalCapacityViewController.h"
#import "EyeTestViewController.h"
#import "BATLoginViewController.h"

@import WebKit;
@import JavaScriptCore;

@interface HTMLViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *myWebView;
@property (nonatomic,strong) JSContext *jsContext;
@property (nonatomic,strong) UIView *badNetView;
@property (nonatomic,strong) UIView *hudView;
@property (nonatomic, copy) NSString *startStr;
@property (nonatomic, copy) NSString *currentStr;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSInteger failCount;
@end

@implementation HTMLViewController

- (void)dealloc
{
    _jsContext = nil;
    [_hudView removeFromSuperview];
    _hudView = nil;
    [_badNetView removeFromSuperview];
    _badNetView = nil;
//    [_myWebView loadHTMLString:@"" baseURL:nil];
    _myWebView.delegate = nil;
    [_myWebView removeFromSuperview];
    _myWebView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_recordWebType) {
        _webType = EWebMyRecordType;
    }
    else if (_healthWebType)
    {
        _webType = EWebHealthRecordType;
    }
    [self deleteBackButton];
    [self initBackLastWebButton:@selector(backItemClick)];
    [self removeAllCached];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _gotoOutView = NO;
    if (_webType != EWebPsychTestType) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
    [self judgeLoginStation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self removeRepeatVC];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_webType != EWebPsychTestType) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!_gotoOutView)
    {
        if (_myWebView && _myWebView.loading){
            [_myWebView stopLoading];
        }
        if (_jsContext ) {
            _jsContext[@"HealthBAT"] = nil;
            _jsContext = nil;
        }
        [self removeAllCached];
        [_myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
        [_myWebView stopLoading];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self removeAllCached];
    // Dispose of any resources that can be recreated.
}


- (void)judgeLoginStation
{
    if (!LOGIN_STATION) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"本功能需要登录账户才可使用" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TalkingData trackEvent:@"2200001" label:@"我的>登录/注册"];
                    BATLoginViewController *heartTrendViewController = [[BATLoginViewController alloc] init];
                    heartTrendViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:heartTrendViewController animated:YES];
                });
            }];
            [alertController addAction:sureAction];
            UIAlertAction *canleAction = [UIAlertAction actionWithTitle:@"退出本页面" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }];
            [alertController addAction:canleAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    else
    {
        [self initWebViewData];
        [self initWebUrl];
    }
}

- (void)initWebViewData
{
    if (once) {
        return;
    }
    WEAK_SELF(self);
    [self.view addSubview:self.myWebView];
    [_myWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        if (_webType != EWebPsychTestType) {
            make.top.equalTo(self.view.mas_top).offset(-kStatusBarHeight);
        }
        else
        {
            make.top.equalTo(self.view.mas_top);
        }
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self.view addSubview: self.hudView];
    [self.view addSubview: self.badNetView];
}

- (void)initWebUrl
{
    if (once) {
        return;
    }
    once = YES;
    switch (_webType) {
        case EWebMyRecordType:
        case EWebHealthRecordType:
        {
            BATPerson *person = PERSON_INFO;
            NSString *appkey = @"e38ad4f48133c76ad8e6165ccc427211";
            NSString *appSecret = @"dbf2dcc52133c76ad8e61600eeafa583";
            NSString *timestamp = [KMTools getDateStringWithDate:[NSDate date] Format:@"yyyy-MM-dd HH:mm:ss"];//当前日期
            NSString *phone = person.Data.PhoneNumber;//手机号
            NSArray *array = @[appkey,appSecret,timestamp];
            array = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
            NSString *tmpSign = @"";
            for (NSString *string in array) {
                tmpSign = [tmpSign stringByAppendingString:string];
            }
            NSString *sign = [KMTools md5String:tmpSign];
            NSString *url = @"";
            if (_webType == EWebMyRecordType) {
                NSArray *urlArray = @[@"bloodPressure",@"bloodSugar",@"pulse",@"step",@"oxygen",@"vitalCapacity"];
                if (_recordWebType == 0) {
                    _recordWebType = ERecordWebTypeBloodPressure;
                }
                NSString * recordUrl = [urlArray objectAtIndex: _recordWebType-1];
                url = [NSString stringWithFormat:@"%@/?appkey=%@&timestamp=%@&sign=%@&phone=%@&src=5&redirect=/H5/src/index.html?src=5#/healthRecord/%@/5",KM_HEALTH360_URL,appkey,timestamp,sign,phone,recordUrl];
            }
            else
            {
                if (_healthWebType == EHealthWebTypeHome) {
                    url = [NSString stringWithFormat:@"%@/?appkey=%@&timestamp=%@&sign=%@&phone=%@&src=5&redirect=/H5/src/index.html?src=5#/healthRecordIndex/5",KM_HEALTH360_URL,appkey,timestamp,sign,phone];
                }
                else if (_healthWebType == EHealthWebTypeEvaluateReport)
                {
                    url = [NSString stringWithFormat:@"%@/?appkey=%@&timestamp=%@&sign=%@&phone=%@&src=5&redirect=/H5/src/index.html?src=5#/healthEvaluateReport/////5",KM_HEALTH360_URL,appkey,timestamp,sign,phone];
                }
                
            }
            _startStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
        }
            break;
        case EWebPsychTestType:
        {
            [self addRightButton:@selector(shareWeb) image:[UIImage imageNamed:@"nav_share_blue"]];
            _startStr = [NSString stringWithFormat:@"%@/App/TemplateList",WEB_URL];
        }
            break;
            
        default:
            break;
    }
    [self startLoadWeb:_startStr];
}

-(void)startLoadWeb:(NSString *)url
{
    if (_loading) {
        return;
    }
    _badNetView.hidden = YES;
    NSURL *startUR = [NSURL URLWithString:url];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL: startUR];
    [_myWebView loadRequest:theRequest];
}

#pragma mark -
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showHUDView];
    _loading = YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //防止内存泄漏
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    //本地webkit硬盘图片的缓存；
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    //静止webkit离线缓存
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，，原文没有提到。
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissHUDView];
    _failCount = 0;
    _loading = NO;
    
    switch (_webType) {
        case EWebMyRecordType:
        case EWebHealthRecordType:
        {
            _jsContext = [_myWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            BATJSObject *testJO=[BATJSObject new];
            _jsContext[@"HealthBAT"] = testJO;
            __weak HTMLViewController *weakSelf = self;
            [testJO setGoToDrKangBlock:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            
            //血氧
            [testJO setGotoBloodOxygenBlock:^{
                weakSelf.gotoOutView = YES;
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                BloodOxygenViewController *bloodOxygenView = [sboard instantiateViewControllerWithIdentifier:@"BloodOxygenViewController"];
                bloodOxygenView.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:bloodOxygenView animated:YES];
            }];
            
            //血压
            [testJO setGotoBloodPressureBlock:^{
                weakSelf.gotoOutView = YES;
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                BloodPressureDetectioViewController *bloodPressureDetectioViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodPressureDetectioViewController"];
                bloodPressureDetectioViewController.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:bloodPressureDetectioViewController animated:YES];
            }];
            
            //血糖
            [testJO setGotoBloodSugarBlock:^{
                weakSelf.gotoOutView = YES;
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                BloodSugarViewController *bloodSugarViewController = [sboard instantiateViewControllerWithIdentifier:@"BloodSugarViewController"];
                [weakSelf.navigationController pushViewController:bloodSugarViewController animated:YES];
            }];
            
            //肺活量
            [testJO setGotovitalCapacityBlock:^{
                weakSelf.gotoOutView = YES;
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                VitalCapacityViewController *vitalCapacityViewController = [sboard instantiateViewControllerWithIdentifier:@"VitalCapacityViewController"];
                [weakSelf.navigationController pushViewController:vitalCapacityViewController animated:YES];
            }];
            
            //视力
            [testJO setGotoVisionBlock:^{
                weakSelf.gotoOutView = YES;
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                EyeTestViewController *eyeTestViewController = [sboard instantiateViewControllerWithIdentifier:@"EyeTestViewController"];
                [weakSelf.navigationController pushViewController:eyeTestViewController animated:YES];
            }];
            
            //心率
            [testJO setGotoheartRateBlock:^{
                weakSelf.gotoOutView = YES;
                UIStoryboard *sboard = [KMTools getStoryboardInstance];
                HeartRateDetectioViewController *workGradeViewController = [sboard instantiateViewControllerWithIdentifier:@"HeartRateDetectioViewController"];
                workGradeViewController.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:workGradeViewController animated:YES];
            }];

        }
            break;
        case EWebPsychTestType:
        {
            
        }
            break;
            
            
        default:
            break;
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self dismissHUDView];
    _badNetView.hidden = NO;
    _loading = NO;
    _failCount ++;
    if (_failCount<3) {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 *NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self startLoadWeb: _currentStr];
        });
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (_currentStr.length) {
        _currentStr = nil;
    }
    _currentStr = request.URL.absoluteString;
    NSLog(@"%@",_currentStr);
    if (_loading&&navigationType==UIWebViewNavigationTypeLinkClicked)
    {
        return NO;
    }
    switch (_webType)
    {
        case EWebMyRecordType:
        {
            return YES;
        }
            break;
        case EWebHealthRecordType:
        {
            return YES;
        }
            break;
        case EWebPsychTestType:
        {
            if ([request.URL.absoluteString containsString:@"TemplateIndex"])
            {
                if (![request.URL.absoluteString containsString:[KMTools getPostUUID]]) {
                    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@?token=%@&mid=%@",request.URL.absoluteString,LOCAL_TOKEN,[KMTools getPostUUID]]];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                            [webView loadRequest:request];
                        });
                    });
                    return NO;
                }
            }
        }
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - 返回按钮
-(void)backItemClick
{
    BOOL result = [_startStr caseInsensitiveCompare:_currentStr] == NSOrderedSame;
    if ([_myWebView canGoBack]&&!result) {
        [_myWebView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)shareWeb
{
    NSArray *strArray = [_currentStr componentsSeparatedByString:@"?"];
    NSString *url = strArray[0];
    UIImage *shareImage = [UIImage imageNamed:@"share_icon"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[shareImage];
    NSString *theTitle=[_myWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (imageArray)
    {
        [shareParams SSDKSetupShareParamsByText:url
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:theTitle
                                           type:SSDKContentTypeAuto];
    }
    [ShareCustom shareWithContent:shareParams];
}

- (void)showHUDView
{
    [UIView animateWithDuration:0.3f animations:^{
        _hudView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissHUDView
{
    [UIView animateWithDuration:0.3f animations:^{
        _hudView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -
- (void)removeRepeatVC
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
//    NSMutableArray *repeatVCArray = [NSMutableArray new];
    UIViewController *repeatVC;
    for (UIViewController *elem in marr ) {
        if ([elem isKindOfClass:[HTMLViewController class]]) {
            if (!repeatVC) {
                repeatVC = elem;
            }
            else
            {
                HTMLViewController * vc = (HTMLViewController *)repeatVC;
                vc.gotoOutView = NO;
                [marr removeObject:repeatVC];
            }
        }
    }
    self.navigationController.viewControllers = marr;
}

- (void)removeAllCached
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSSet *websiteDataTypes= [NSSet setWithArray:@[
                                                       WKWebsiteDataTypeDiskCache,
                                                       //WKWebsiteDataTypeOfflineWebApplication
                                                       WKWebsiteDataTypeMemoryCache,
                                                       //WKWebsiteDataTypeLocal
                                                       WKWebsiteDataTypeCookies,
                                                       //WKWebsiteDataTypeSessionStorage,
                                                       //WKWebsiteDataTypeIndexedDBDatabases,
                                                       //WKWebsiteDataTypeWebSQLDatabases
                                                       ]];
        
        // All kinds of data
        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
    } else {
        //先删除cookie
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        
        NSString *libraryDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
                                          stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSString *webKitFolderInCachesfs = [NSString
                                            stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
        /* iOS7.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
        NSString *cookiesFolderPath = [libraryDir stringByAppendingString:@"/Cookies"];
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&error];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
}

#pragma mark -
- (UIWebView *)myWebView
{
    if (!_myWebView) {
        _myWebView = [[UIWebView alloc] init];
        _myWebView.delegate = self;
    }
    return _myWebView;
}

- (UIView *)hudView
{
    if (!_hudView) {
        _hudView = [[UIView alloc]init];
        [_hudView.layer addSublayer: [WHAnimation replicatorLayer_Triangle:AppColor]];
        _hudView.center = CGPointMake((MainScreenWidth-50)/2, MainScreenHeight/2-50);
        _hudView.alpha = 0;
    }
    return _hudView;
}

- (UIView *)badNetView
{
    if (!_badNetView) {
        CGFloat imageW = 73.0;
        CGFloat imageH = 132.0;
        CGFloat labelH = 30.0;
        _badNetView = [[UIView alloc] initWithFrame:CGRectMake((MainScreenWidth-imageH)/2, (MainScreenHeight-imageH)/2-kStatusAndNavHeight-labelH, imageH, imageH+labelH)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_badNetView.frame)-imageW)/2, 0, imageW, imageH)];
        imageView.image = [UIImage imageNamed:@"badnet"];
        [_badNetView addSubview:imageView];
        UILabel *hudLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageH, imageH, labelH)];
        hudLabel.text = ErrorText;
        hudLabel.font = [UIFont fontWithName:AppFontHelvetica size:11];
        hudLabel.textAlignment = NSTextAlignmentCenter;
        hudLabel.numberOfLines = 2;
        [_badNetView addSubview:hudLabel];
        _badNetView.hidden = YES;
    }
    return _badNetView;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

