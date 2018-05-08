//
//  ScanViewController.m
//  车主app
//
//  Created by 郭鹏飞 on 15/5/4.
//  Copyright (c) 2015年 沃特智联. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    UIImageView * imageView;
}

@property (strong, nonatomic)AVCaptureDevice *device;
@property (strong, nonatomic)AVCaptureDeviceInput *input;
@property (strong, nonatomic)AVCaptureMetadataOutput *output;
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanViewController

- (void) dealloc {
    
    [_session stopRunning];
    _session = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (!_session)
    {
        [self initViewData];
        [self checkAVAuthorizationStatus];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_session startRunning];
    [timer fire];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_session stopRunning];
    [timer invalidate];
}

-(void)animation1
{
    if (upOrdown == NO)
    {
        num ++;
        _line.frame = CGRectMake(_line.frame.origin.x, imageView.frame.origin.y + 2 * num, _line.frame.size.width, _line.frame.size.height);
        if (2 * num > MainScreenWidth/2) {
            upOrdown = YES;
        }
    }
    else
    {
        num --;
        _line.frame = CGRectMake(_line.frame.origin.x, imageView.frame.origin.y + 2 * num, _line.frame.size.width, _line.frame.size.height);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

- (void)checkAVAuthorizationStatus
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        [self setupCamera];
    } else {
        //您没有授权App访问相机权限
    }
}

- (void)setupCamera
{
    // Device
    if (_device) {
        return;
    }
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("QRQueue", NULL);
    [_output setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    // Session
    _session = [[AVCaptureSession alloc]init];

    [_session setSessionPreset:AVCaptureSessionPreset1280x720];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    // Preview
    _preview =[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = CGRectMake(0, 0, MainScreenWidth, self.view.frame.size.height);
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    UIView * maskView = [[UIButton alloc] init];
    [maskView setFrame:CGRectMake(0, 0, MainScreenWidth, self.view.frame.size.height)];
    [maskView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [self.view addSubview:maskView];
    
    //create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:maskView.frame];
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(MainScreenWidth/4, 110, MainScreenWidth/2, MainScreenWidth/2)
                                                 cornerRadius:0] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [maskView.layer setMask:shapeLayer];
    
//    _output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];

    CGSize size = self.view.bounds.size;
    CGRect cropRect = CGRectMake((MainScreenWidth - 228) / 2, 110, 228, 228);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1280./720.;  //使用了720p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1280. / 720.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                  cropRect.origin.x/size.width,
                                                  cropRect.size.height/fixHeight,
                                                  cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = size.height * 720. / 1280.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                  (cropRect.origin.x + fixPadding)/fixWidth,
                                                  cropRect.size.height/size.height,
                                                  cropRect.size.width/fixWidth);
    }
}

- (void)initViewData
{
    if (imageView) {
        return;
    }
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(MainScreenWidth/4, 110, MainScreenWidth/2, MainScreenWidth/2)];
    imageView.image = [UIImage imageNamed:@"twodimen_scan"];
//    imageView.backgroundColor = [UIColor clearColor];
    imageView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.7].CGColor;
    imageView.layer.borderWidth = 0.5;
    [self.view addSubview:imageView];
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+ 10, MainScreenWidth, 20)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.font = [UIFont systemFontOfSize:12];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.text = @"将二维码图像置于框内，即可自动扫描";
    [self.view addSubview:labIntroudction];
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(imageView.frame), CGRectGetMinY(imageView.frame), MainScreenWidth/2, 6)];
    _line.backgroundColor = AppColor;
    [self.view addSubview:_line];
    upOrdown = NO;
    num =0;
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
//    [self playSound];
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    if (stringValue.length > 0)
    {
        [_session stopRunning];
        [timer invalidate];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 *NSEC_PER_SEC));
        dispatch_time_t time2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 *NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
            dispatch_after(time2, dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
    NSLog(@"stringValue %@",stringValue);
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_session startRunning];
    [timer fire];
}

@end
