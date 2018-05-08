//
//  QRCodeViewController.m
//  Fibonacci
//
//  Created by woaiqiu947 on 16/10/9.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "QRCodeViewController.h"
#import "QRCodeGenerator.h"
#import "WXWaveView.h"

@interface QRCodeViewController ()

@property(nonatomic,strong)UILabel *hudLabel;
@property(nonatomic,strong)UIImageView *codeView;
@property(nonatomic,strong)UIImageView *codeBGView;
@property(nonatomic,strong)WXWaveView *waveView;
@property(nonatomic,strong)UIView *waveBGView;

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end

@implementation QRCodeViewController
-(void)dealloc
{
    _waveView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";

    if (_type) {
        [self initAVkit];
    }
    else
    {
        [self initPagesFrame];
        CGFloat waveY = CGRectGetMinY(_waveBGView.frame)-5.8;
        _waveView = [WXWaveView addToView:self.view withFrame:CGRectMake(0, waveY, MainScreenWidth, 6)];
        _waveView.waveColor = AppColor;
        [self initQRCodeImage];
    }

    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (_waveView) {
        [_waveView wave];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_waveView stop];
}

- (void)initAVkit
{

}

- (void)initQRCodeImage
{
    CGFloat w = 115;
    UIImage *image = [QRCodeGenerator qrImageForString:SHARE_URL imageSize:w];
    self.codeView.image = image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initPagesFrame
{
    WEAK_SELF(self);
    
    [self.view addSubview:self.hudLabel];
    [self.hudLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(40);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(MainScreenWidth);
    }];
    
    [self.view addSubview:self.codeBGView];
    [self.codeBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.hudLabel.mas_bottom).offset(30);
        make.height.mas_equalTo(190);
        make.width.mas_equalTo(125);
    }];
    
    [self.codeBGView addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        STRONG_SELF(self);
        make.left.equalTo(self.codeBGView.mas_left).offset(5);
        make.bottom.equalTo(self.codeBGView.mas_bottom);
    }];
    
    [self.view addSubview:self.waveBGView];

}


-(UILabel*)hudLabel
{
    if (!_hudLabel) {
        _hudLabel = [[UILabel alloc] init];
        _hudLabel.font = [UIFont fontWithName:AppFontHelvetica size:14];
        _hudLabel.textColor = RGB(51, 51, 51);
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.text = @"扫一扫二维码，下载康美小管家";
    }
    return _hudLabel;
}

-(UIImageView *)codeBGView
{
    if (!_codeBGView) {
        _codeBGView = [[UIImageView alloc]init];
//        _codeBGView.backgroundColor = AppColor;
        _codeBGView.image = [UIImage imageNamed:@"me_qrcode_bg"];
    }
    return _codeBGView;
}

-(UIImageView *)codeView
{
    if (!_codeView) {
        _codeView = [[UIImageView alloc]init];
    }
    return _codeView;
}

-(UIView*)waveBGView
{
    if (!_waveBGView) {
        _waveBGView = [[UIView alloc] initWithFrame:CGRectMake(0, MainScreenHeight*0.6, MainScreenWidth, MainScreenHeight/3)];
        _waveBGView.backgroundColor = AppColor;
    }
    return _waveBGView;
}
@end
