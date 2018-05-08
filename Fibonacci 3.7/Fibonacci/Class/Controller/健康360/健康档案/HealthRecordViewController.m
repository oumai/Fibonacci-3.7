//
//  HealthRecordViewController.m
//  Fibonacci
//
//  Created by Apple on 2018/3/6.
//  Copyright © 2018年 woaiqiu947. All rights reserved.
//

#import "HealthRecordViewController.h"
#import "HeartBackgroundView.h"
#import "BATPerson.h"

@interface HealthRecordViewController ()<UIWebViewDelegate>
@property (nonatomic, strong)UIWebView *myWebView;
@end

#define OtherLabelWidth 55
@implementation HealthRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"健康档案";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self loadURL];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)loadURL {
    if (_myWebView) {
        return;
    }
    
    [self initHealthRecordPageLayout];
    
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
    
    NSString *url = [NSString stringWithFormat:@"%@/?appkey=%@&timestamp=%@&sign=%@&phone=%@&src=5&redirect=/H5/src/index.html?src=5#/healthRecordIndex/5",KM_HEALTH360_URL,appkey,timestamp,sign,phone];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initHealthRecordPageLayout
{
    [self.view addSubview: self.myWebView];
    [_myWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@-20);
        make.left.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //电商页面，联合登陆
    if ([request.URL.absoluteString containsString:@"http://m.km1818.com"]) {
        
        return NO;
    }
    NSLog(@"%@",request.URL.absoluteString);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    
}

#pragma mark -
- (UIWebView *)myWebView
{
    if (!_myWebView) {
        _myWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _myWebView.backgroundColor = BASE_BACKGROUND_COLOR;
        _myWebView.scrollView.backgroundColor = BASE_BACKGROUND_COLOR;
        _myWebView.delegate = self;
    }
    return _myWebView;
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
