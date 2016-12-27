//
//  WFPlayer.m
//  WFPlayer
//
//  Created by babywolf on 16/12/27.
//  Copyright © 2016年 babywolf. All rights reserved.
//

#import "WFPlayer.h"

#define KScreenWidth [[UIScreen mainScreen]bounds].size.width
#define KScreenHeight [[UIScreen mainScreen]bounds].size.height

@implementation WFPlayer

- (instancetype)initWithFrame:(CGRect)frame URL:(NSString *)URL {
    if (self = [super initWithFrame:frame]) {
        NSURL *url = [NSURL fileURLWithPath:URL];
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        _moviePlayer.view.frame = self.bounds;
        [_moviePlayer play];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        // 必须关闭播放器view视图响应，否则导致tap手势不触发
        _moviePlayer.view.userInteractionEnabled = NO;
        [self addSubview:self.moviePlayer.view];
        [self addNotification];
    }
    [self createUI];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    return self;
}

-(void)tapAction {
    self.backView.hidden = !self.backView.hidden;
}

- (void)createUI {
    //  backView
    self.backView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.backView.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.backView.userInteractionEnabled = YES;
    [self addSubview:self.backView];
    
    //  PlayButton
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateSelected];
    self.playButton.frame = CGRectMake(15, KScreenHeight-46-20, 46, 46);
    [self.backView addSubview:self.playButton];
    
    //  startTime
    self.startTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame)+10, CGRectGetMidY(self.playButton.frame)-15/2.0, 35, 15)];
    self.startTime.text = @"00:00";
    self.startTime.font = [UIFont systemFontOfSize:12];
    //    self.startTime.backgroundColor = [UIColor redColor];
    self.startTime.textColor = [UIColor whiteColor];
    [self.backView addSubview:self.startTime];
    
    //slider
    self.progress =[[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_startTime.frame)+5, CGRectGetMinY(_startTime.frame), KScreenWidth-CGRectGetMaxX(_startTime.frame)-35-20, 15)];
    //  滑块左侧颜色
    self.progress.minimumTrackTintColor = [UIColor whiteColor];
    //  滑块右侧颜色
    self.progress.maximumTrackTintColor = [UIColor whiteColor];
    UIImage *thumbImage0 = [UIImage imageNamed:@"Oval 1"];
    [self.progress setThumbImage:thumbImage0 forState:UIControlStateNormal];
    [self.progress setThumbImage:thumbImage0 forState:UIControlStateSelected];
    [self.progress addTarget:self action:@selector(valueChange:other:) forControlEvents:UIControlEventValueChanged];
    self.progress.userInteractionEnabled = NO;
    [self.backView addSubview:self.progress];
    
    //  endTime
    self.endTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_progress.frame)+5, CGRectGetMinY(_progress.frame), 35, 15)];
    self.endTime.text = @"00:00";
    self.endTime.font = [UIFont systemFontOfSize:12];
    self.endTime.textColor = [UIColor whiteColor];
    [self.backView addSubview:self.endTime];
    
    //  backButton
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"Safari Back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.frame = CGRectMake(15, 15, 34, 34);
    [self.backView addSubview:self.backButton];
}

- (void)playAction:(UIButton *)sender {
    if (self.playButton.selected) {
        [self.moviePlayer play];
    }else {
        [self.moviePlayer pause];
    }
    self.playButton.selected = !self.playButton.selected;
}

- (void)valueChange:(UISlider *)progress other:(UIEvent *)event {
    
}

- (void)backAction {
    [self.moviePlayer pause];
    [self removeFromSuperview];
}

- (void)addNotification {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(DurationAvailable) name:MPMovieDurationAvailableNotification object:self.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

- (void)DurationAvailable {
    NSInteger minit = self.moviePlayer.duration / 60;
    NSInteger second = self.moviePlayer.duration - 60 * minit;
    self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

-(void)mediaPlayerPlaybackFinished {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playButton.selected = YES;
    });
}

- (void)refreshCurrentTime {
    NSInteger minit = self.moviePlayer.currentPlaybackTime / 60;
    NSInteger second = self.moviePlayer.currentPlaybackTime - 60 * minit;
    NSInteger endMinit = (self.moviePlayer.duration - self.moviePlayer.currentPlaybackTime) / 60;
    NSInteger endSecond = (self.moviePlayer.duration - self.moviePlayer.currentPlaybackTime) - 60 * endMinit;
    self.startTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)endMinit, (long)endSecond];
    
    self.progress.value = self.moviePlayer.currentPlaybackTime / self.moviePlayer.duration;
}

@end
