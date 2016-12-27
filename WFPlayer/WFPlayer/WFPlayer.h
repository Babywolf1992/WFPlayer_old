//
//  WFPlayer.h
//  WFPlayer
//
//  Created by babywolf on 16/12/27.
//  Copyright © 2016年 babywolf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface WFPlayer : UIView

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *startTime;
@property (nonatomic, strong) UILabel *endTime;
@property (nonatomic, strong) UISlider *progress;
@property (nonatomic, strong) UISlider *volume;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *timaImage;
@property (nonatomic, strong) UILabel *timeLabel;

- (instancetype)initWithFrame:(CGRect)frame URL:(NSString *)URL;
@end
