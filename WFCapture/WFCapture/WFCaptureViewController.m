//
//  ViewController.m
//  WFCapture
//
//  Created by babywolf on 17/1/5.
//  Copyright © 2017年 babywolf. All rights reserved.
//

#import "WFCaptureViewController.h"
#import "WKMovieRecorder.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface WFCaptureViewController ()

@property (nonatomic, strong) UIView *btnView;

@property (nonatomic, strong) UIView *preview;

//indicator
@property (nonatomic, strong) CALayer *processLayer;

@property (nonatomic, assign, getter=isScale) BOOL scale;

@property (nonatomic, strong) WKMovieRecorder *recorder;

@end

@implementation WFCaptureViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupRecorder];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [_recorder startSession];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.recorder finishCapture];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)setupUI
{
    _preview = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_preview];
    
    _btnView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2, kScreenHeight-80-100, 80, 80)];
    [_btnView.layer setMasksToBounds:YES];
    _btnView.layer.cornerRadius = 40;
    _btnView.layer.borderWidth = 10;
    _btnView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    _btnView.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    [self.view addSubview:_btnView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_btnView addGestureRecognizer:longPress];
    
}

- (void)longPress:(UIGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.recorder startCapture];
            
//            [self.statusLabel.superview bringSubviewToFront:strongSelf.statusLabel];
            
//            [self showStatusLabelWithBackgroundColor:[UIColor clearColor] textColor:[UIColor greenColor] state:YES];
            
#warning 动画播放
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self.recorder stopCapture];
            [self endRecord];
            NSLog(@"拍摄结束");
        }
            break;
        default:
            break;
    }
}

#pragma mark - setupRecorder
- (void)setupRecorder
{
    _recorder = [[WKMovieRecorder alloc] initWithMaxDuration:10.f];
    
    CGFloat width = 320.f;
    CGFloat Height = width / 4 * 3;
    _recorder.cropSize = CGSizeMake(width, Height);
    __weak typeof(self)weakSelf = self;
    
    [_recorder setAuthorizationResultBlock:^(BOOL success){
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"这里就省略没有权限的处理了");
            });
        }
    }];
    
    [_recorder prepareCaptureWithBlock:^{
        
        //1.video preview
        AVCaptureVideoPreviewLayer* preview = [_recorder getPreviewLayer];
        preview.backgroundColor = [UIColor blackColor].CGColor;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [preview removeFromSuperlayer];
        preview.frame = self.view.bounds;
        
        [self.preview.layer addSublayer:preview];
    }];
    
    [_recorder setFinishBlock:^(NSDictionary *info, WKRecorderFinishedReason reason){
        switch (reason) {
            case WKRecorderFinishedReasonNormal:
            case WKRecorderFinishedReasonBeyondMaxDuration:{//正常结束
                
//                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                WCSPreviewViewController *previewVC = [sb instantiateViewControllerWithIdentifier:@"WCSPreviewViewController"];
//                previewVC.movieInfo = info;
//                
//                [weakSelf.navigationController pushViewController:previewVC animated:YES];
                
                break;
                
            }
            case WKRecorderFinishedReasonCancle:{//重置
                
                
                break;
            }
                
            default:
                break;
        }
        NSLog(@"随便你要干什么");
    }];
    
    [_recorder setFocusAreaDidChangedBlock:^{//焦点改变
        
    }];
    
//    [_longPressButton setStateChangeBlock:^(WKState state){
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        switch (state) {
//            case WKStateBegin: {
//                
//                [strongSelf.recorder startCapture];
//                
//                [strongSelf.statusLabel.superview bringSubviewToFront:strongSelf.statusLabel];
//                
//                [strongSelf showStatusLabelWithBackgroundColor:[UIColor clearColor] textColor:[UIColor greenColor] state:YES];
//                
//                if (!strongSelf.processLayer) {
//                    strongSelf.processLayer = [CALayer layer];
//                    strongSelf.processLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(strongSelf.preview.bounds), 5);
//                    strongSelf.processLayer.position = CGPointMake(CGRectGetMidX(strongSelf.preview.bounds), CGRectGetHeight(strongSelf.preview.bounds) - 2.5);
//                    strongSelf.processLayer.backgroundColor = [UIColor greenColor].CGColor;
//                }
//                [strongSelf addAnimation];
//                
//                [strongSelf.preview.layer addSublayer:strongSelf.processLayer];
//                
//                
//                [strongSelf.longPressButton disappearAnimation];
//                
//                break;
//            }
//            case WKStateIn: {
//                [strongSelf showStatusLabelWithBackgroundColor:[UIColor clearColor] textColor:[UIColor greenColor] state:YES];
//                
//                break;
//            }
//            case WKStateOut: {
//                
//                [strongSelf showStatusLabelWithBackgroundColor:[UIColor redColor] textColor:[UIColor whiteColor] state:NO];
//                break;
//            }
//            case WKStateCancle: {
//                [strongSelf.recorder cancleCaputre];
//                [strongSelf endRecord];
//                break;
//            }
//            case WKStateFinish: {
//                [strongSelf.recorder stopCapture];
//                [strongSelf endRecord];
//                break;
//            }
//        }
//    }];
}

#pragma mark - Orientation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        AVCaptureVideoPreviewLayer *previewLayer = [_recorder getPreviewLayer];
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
        
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
        if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
            initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
        }
        
        [_recorder videoConnection].videoOrientation = initialVideoOrientation;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_DEPRECATED_IOS(2_0,8_0, "Implement viewWillTransitionToSize:withTransitionCoordinator: instead") __TVOS_PROHIBITED
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        AVCaptureVideoPreviewLayer *previewLayer = [_recorder getPreviewLayer];
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
        
        UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
        if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
            initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
        }
        
        [_recorder videoConnection].videoOrientation = initialVideoOrientation;
    }
}

//双击 焦距调整
- (void)tapGR:(UITapGestureRecognizer *)tapGes
{
    
    
    CGFloat scaleFactor = self.isScale ? 1 : 2.f;
    
    self.scale = !self.isScale;
    
    [_recorder setScaleFactor:scaleFactor];
    
}

- (void)addAnimation
{
    _processLayer.hidden = NO;
    _processLayer.backgroundColor = [UIColor cyanColor].CGColor;
    
    CABasicAnimation *scaleXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleXAnimation.duration = 10.f;
    scaleXAnimation.fromValue = @(1.f);
    scaleXAnimation.toValue = @(0.f);
    
    [_processLayer addAnimation:scaleXAnimation forKey:@"scaleXAnimation"];
}

- (void)showStatusLabelWithBackgroundColor:(UIColor *)color textColor:(UIColor *)textColor state:(BOOL)isIn
{
//    _statusLabel.backgroundColor = color;
//    _statusLabel.textColor = textColor;
//    _statusLabel.hidden = NO;
//    
//    _statusLabel.text = isIn ? @"上移取消" : @"松手取消";
}

- (void)endRecord
{
//    [_processLayer removeAllAnimations];
//    _processLayer.hidden = YES;
//    _statusLabel.hidden = YES;
//    [self.longPressButton appearAnimation];
}


@end
