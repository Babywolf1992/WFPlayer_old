//
//  WFPlayer.m
//  WFPlayer
//
//  Created by babywolf on 16/12/27.
//  Copyright © 2016年 babywolf. All rights reserved.
//

#import "WFPlayer.h"
#import "SBJson.h"

#define KScreenWidth [[UIScreen mainScreen]bounds].size.width
#define KScreenHeight [[UIScreen mainScreen]bounds].size.height

@implementation WFPlayer

- (instancetype)initWithFrame:(CGRect)frame URL:(NSString *)urlString {
    if (self = [super initWithFrame:frame]) {
        NSURL *url = [NSURL URLWithString:urlString];
        _request = [[ASIHTTPRequest alloc] initWithURL:url];
        [_request setDelegate:self];
        [_request setDidFinishSelector:@selector(downloadFileDone:)];
        [_request setDidFailSelector:@selector(downloadFileFail:)];
        [_request startAsynchronous];
        [_request setDefaultResponseEncoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:_request forKey:@"request"];
        
        _downloadProcessTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(downloadFileProgress:) userInfo:dict repeats:YES];
        [self addNotification];
    }
    return self;
}

-(void)tapAction {
    _backView.hidden = !_backView.hidden;
}

- (void)createUI {
    
    _progresshud = [[MBProgressHUD alloc] initWithView:self];
    _progresshud.mode = MBProgressHUDModeDeterminate;
    _progresshud.progress = 0.0f;
    _progresshud.hidden = YES;
    [self addSubview:_progresshud];
    
    //  backView
    _backView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _backView.backgroundColor = [UIColor clearColor];
    _backView.userInteractionEnabled = YES;
    [self addSubview:_backView];
    
    //  PlayButton
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateSelected];
    _playButton.frame = CGRectMake(15, KScreenHeight-46-20, 46, 46);
    [_backView addSubview:_playButton];
    
    //  startTime
    _startTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame)+10, CGRectGetMidY(self.playButton.frame)-15/2.0, 35, 15)];
    _startTime.text = @"00:00";
    _startTime.font = [UIFont systemFontOfSize:12];
    //    self.startTime.backgroundColor = [UIColor redColor];
    _startTime.textColor = [UIColor whiteColor];
    [_backView addSubview:_startTime];
    
    //slider
    _progress =[[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_startTime.frame)+5, CGRectGetMinY(_startTime.frame), KScreenWidth-CGRectGetMaxX(_startTime.frame)-35-20, 15)];
    //  滑块左侧颜色
    _progress.minimumTrackTintColor = [UIColor whiteColor];
    //  滑块右侧颜色
    _progress.maximumTrackTintColor = [UIColor whiteColor];
    UIImage *thumbImage0 = [UIImage imageNamed:@"Oval 1"];
    [_progress setThumbImage:thumbImage0 forState:UIControlStateNormal];
    [_progress setThumbImage:thumbImage0 forState:UIControlStateSelected];
    [_progress addTarget:self action:@selector(valueChange:other:) forControlEvents:UIControlEventValueChanged];
    _progress.userInteractionEnabled = NO;
    [_backView addSubview:_progress];
    
    //  endTime
    _endTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_progress.frame)+5, CGRectGetMinY(_progress.frame), 35, 15)];
    self.endTime.text = @"00:00";
    self.endTime.font = [UIFont systemFontOfSize:12];
    self.endTime.textColor = [UIColor whiteColor];
    [_backView addSubview:self.endTime];
    
    //  backButton
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"Safari Back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    _backButton.frame = CGRectMake(15, 15, 34, 34);
    [_backView addSubview:_backButton];
    
    _playButton.selected = YES;
}

- (void)playAction:(UIButton *)sender {
    if (self.playButton.selected) {
        [_moviePlayer play];
    }else {
        [_moviePlayer pause];
    }
    self.playButton.selected = !self.playButton.selected;
}

- (void)showPlayer:(NSURL *)url {
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    _moviePlayer.view.frame = self.bounds;
    [_moviePlayer play];
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    // 必须关闭播放器view视图响应，否则导致tap手势不触发
    _moviePlayer.view.userInteractionEnabled = NO;
    //    [self addSubview:_moviePlayer.view];
    [self insertSubview:_moviePlayer.view atIndex:1];
    [_moviePlayer play];
    _playButton.selected = NO;
}

- (void)valueChange:(UISlider *)progress other:(UIEvent *)event {
    
}

- (void)backAction {
    [_moviePlayer pause];
    [self removeFromSuperview];
}

- (void)addNotification {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(DurationAvailable) name:MPMovieDurationAvailableNotification object:_moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
}

- (void)DurationAvailable {
    NSInteger minit = _moviePlayer.duration / 60;
    NSInteger second = _moviePlayer.duration - 60 * minit;
    self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

-(void)mediaPlayerPlaybackFinished {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playButton.selected = YES;
    });
}

- (void)refreshCurrentTime {
    NSInteger minit = _moviePlayer.currentPlaybackTime / 60;
    NSInteger second = _moviePlayer.currentPlaybackTime - 60 * minit;
    NSInteger endMinit = (_moviePlayer.duration - _moviePlayer.currentPlaybackTime) / 60;
    NSInteger endSecond = (_moviePlayer.duration - _moviePlayer.currentPlaybackTime) - 60 * endMinit;
    self.startTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)endMinit, (long)endSecond];
    
    _progress.value = _moviePlayer.currentPlaybackTime / _moviePlayer.duration;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.userInteractionEnabled = YES;
    
    [self createUI];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
}

- (void)downloadFileDone:(ASIHTTPRequest *)requestFile {
    if (_downloadProcessTimer!=nil)
    {
        [_downloadProcessTimer invalidate];
    }
    _progresshud.hidden = YES;
    
    NSDictionary* dict = requestFile.responseString.JSONValue;
    if (dict && [[NSString stringWithFormat:@"%@",dict[@"status"]] isEqualToString:@"-2"]) {
        UIAlertView *msgalert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Read error", nil)
                                                           message:dict[@"msg"]
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                 otherButtonTitles:nil];
        [msgalert show];
        return;
    }
    
    NSData* data = [requestFile responseData];
    //下载文件数据不存在
    if (!data)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *msgalert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Read error", nil)
                                                               message:NSLocalizedString(@"CheckConnectSet", nil)
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                     otherButtonTitles:nil];
            [msgalert show];
        });
        return;//////////////////////////
    }
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    //获取文件路径，并写入到文件中
    NSString *urlstring = [requestFile.url absoluteString];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [docsDirectory stringByAppendingPathComponent:@"test.mp4"];
    
    
    /**
     *  先移除 有时候有重名的情况
     */
    NSError*error;
    if ([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:&error];
        
    }
    if (error)
    {
        NSLog(@"error=%@",error.description);
    }
    
    [data writeToFile:filePath atomically:YES];
    NSLog(@"downloadFileDone+filePath:%@",filePath);
    
    //判断文件写入是否成功
    if([fileManager fileExistsAtPath:filePath])
    {
        //        bool result = [self isFirstResponder];
        //        if (!result) {
        //            return;
        //        }
        [self showPlayer:[NSURL fileURLWithPath:filePath]];
    }
}

- (void)downloadFileFail:(ASIHTTPRequest *)requestFile {
    if (_downloadProcessTimer!=nil)
    {
        [_downloadProcessTimer invalidate];
    }
    _progresshud.hidden = YES;
    
    NSError *error = [requestFile error];
    NSLog(@"downloadFileFailed:%@",error.description);
    
    if ([error code] != NSURLErrorCancelled)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *msgalert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load error", nil)
                                                               message:NSLocalizedString(@"CheckConnectSet", nil)
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                     otherButtonTitles:nil];
            [msgalert show];
        });
    }
}

//下载进度
- (void)downloadFileProgress:(NSTimer *)timer
{
    NSDictionary *dict = [timer userInfo];
    ASIHTTPRequest *requestFile = [dict objectForKey:@"request"];
    float progress = (requestFile.totalBytesRead*1.0)/(requestFile.contentLength*1.0);
    if (progress <= 1.0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _progresshud.hidden = NO;
            [_progresshud show:YES];
            _progresshud.progress = progress;
        });
    }
}

@end
