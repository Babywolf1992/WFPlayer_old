//
//  ViewController.m
//  WFPlayer
//
//  Created by babywolf on 16/12/27.
//  Copyright © 2016年 babywolf. All rights reserved.
//

#import "ViewController.h"
#import "WFPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //网络资源
    NSString *urlStr= @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
//    NSString *urlstring = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url=[NSURL URLWithString:urlStr];
    
    //本地文件资源
//    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"WeChatSight1" ofType:@"mp4"];
//    NSURL *url=[NSURL fileURLWithPath:urlStr];
    
    
    WFPlayer *player = [[WFPlayer alloc] initWithFrame:[UIScreen mainScreen].bounds URL:urlStr];
    [self.view addSubview:player];


    
    
    
//    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
//    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//    playerLayer.frame = self.view.bounds;
//    [self.view.layer addSublayer:playerLayer];
//    [player play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
