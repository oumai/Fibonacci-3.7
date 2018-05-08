//
//  PsychTestViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/9/19.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "PsychTestViewController.h"
#import "WHAnimation.h"
#import "AppDelegate+BATShare.h"
#import "ShareCustom.h"
@import WebKit;

@interface PsychTestViewController ()

@end

@implementation PsychTestViewController

- (void)dealloc
{
    [hudView removeFromSuperview];
    hudView = nil;
    myWebView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"中医体质";
    [self deleteBackButton];
    [self initBackLastWebButton:@selector(backItemClick)];
    [self addRightButton:@selector(shareWeb) image:[UIImage imageNamed:@"nav_share_blue"]];
//    [self initRefreshButton:@selector(refreshAction)];
    [self removeAllCached];
    [self initHUDView];
    
//    startStr = [NSString stringWithFormat:@"%@/App/TemplateList?token=%@&mid=%@",WEB_URL,LOCAL_TOKEN,[KMTools getPostUUID]]; //心理测试地址
    startStr = [NSString stringWithFormat:@"%@/App/TemplateIndex/18?token=%@&mid=%@",WEB_URL,LOCAL_TOKEN,[KMTools getPostUUID]]; // 中医体质地址

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self initWebAndUrl];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [HUDImageView stopAnimating];
    if (myWebView && myWebView.loading){
        [myWebView stopLoading];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeAllCached
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)initHUDView
{
    hudView = [[UIView alloc]init];
    [hudView.layer addSublayer: [WHAnimation replicatorLayer_Triangle:AppColor]];
    hudView.center = CGPointMake((MainScreenWidth-50)/2, MainScreenHeight/2-kStatusAndNavHeight);
    hudView.alpha = 0;
    [self.view addSubview:hudView];
    
    CGFloat imageW = 73.0;
    CGFloat imageH = 132.0;
    CGFloat labelH = 30.0;
    badNetView = [[UIView alloc] initWithFrame:CGRectMake((MainScreenWidth-imageH)/2, (MainScreenHeight-imageH)/2-kStatusAndNavHeight-labelH, imageH, imageH+labelH)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(badNetView.frame)-imageW)/2, 0, imageW, imageH)];
    imageView.image = [UIImage imageNamed:@"badnet"];
    [badNetView addSubview:imageView];
    
    UILabel *hudLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageH, imageH, labelH)];
    hudLabel.text = ErrorText;
    hudLabel.font = [UIFont fontWithName:AppFontHelvetica size:11];
    hudLabel.textAlignment = NSTextAlignmentCenter;
    hudLabel.numberOfLines = 2;
    [badNetView addSubview:hudLabel];
    badNetView.hidden = YES;
    [self.view addSubview:badNetView];
}

- (void)initWebAndUrl
{
    if (once) {
        return;
    }
    once = YES;
    NSMutableArray * skirtArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 5;i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"PsychTest0%d",i];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image != nil)
        {
            [skirtArray addObject:image];
        }
    }
    [self startLoadWeb:startStr];
}

-(void)startLoadWeb:(NSString *)url
{
    if (loading) {
        return;
    }
    badNetView.hidden = YES;
    NSURL *startURL = [NSURL URLWithString:url];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:startURL];
    [myWebView loadRequest:theRequest];
}

#pragma mark -
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showHUDView];
    badNetView.hidden = YES;
    loading = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self dismissHUDView];

    failCount = 0;
    loading = NO;
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView stringByEvaluatingJavaScriptFromString:injectionJSString];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self dismissHUDView];
    badNetView.hidden = NO;
    loading = NO;
    failCount ++;
    if (failCount<3) {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 *NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self startLoadWeb:currentStr];
        });
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    currentStr =request.URL.absoluteString;
//    NSLog(@"currentStr %@",currentStr);
    if ([request.URL.absoluteString containsString:@"newsDetail"])
    {
        return YES;

    }
    else
    {
        if (loading&&navigationType==UIWebViewNavigationTypeLinkClicked)
        {
            return NO;
        }
    }
//    if ([request.URL.absoluteString containsString:@"TemplateIndex"])
//    {
//        NSMutableString *str = [[NSMutableString alloc] initWithString: request.URL.absoluteString];
//        if (![request.URL.absoluteString containsString:@"?"])
//        {
//            [str appendString: [NSString stringWithFormat:@"?"]];
//        }
//        if (![request.URL.absoluteString containsString:@"token"])
//        {
//            [str appendString: [NSString stringWithFormat:@"token=%@", LOCAL_TOKEN]];
//        }
//        if (![request.URL.absoluteString containsString:@"mid="])
//        {
//            [str appendString: [NSString stringWithFormat:@"&mid%@", [KMTools getPostUUID]]];
//        }
//        NSURL *url =[NSURL URLWithString: str];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//                [webView loadRequest:request];
//
//            });
//        });
//        return NO;
//    }
    return YES;
}

#pragma mark - 返回按钮
-(void)backItemClick
{
    BOOL result = [startStr caseInsensitiveCompare:currentStr] == NSOrderedSame;
    if ([myWebView canGoBack]&&!result) {
        [myWebView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)shareWeb
{
    NSArray *strArray = [currentStr componentsSeparatedByString:@"?"];
    NSString *url = strArray[0];
    UIImage *shareImage = [UIImage imageNamed:@"share_icon"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[shareImage];
    NSString *theTitle=[myWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
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

- (void)refreshAction
{

    loading = NO;
    [self startLoadWeb:currentStr];
}

- (void)showHUDView
{
    [UIView animateWithDuration:0.3f animations:^{
        hudView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissHUDView
{
    [UIView animateWithDuration:0.3f animations:^{
        hudView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
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
