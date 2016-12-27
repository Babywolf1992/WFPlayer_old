//
//  ViewController.m
//  WFPlayer
//
//  Created by babywolf on 16/12/27.
//  Copyright © 2016年 babywolf. All rights reserved.
//

#import "ViewController.h"
#import "WFPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"WeChatSight1" ofType:@"mp4"];
    WFPlayer *player = [[WFPlayer alloc] initWithFrame:[UIScreen mainScreen].bounds URL:urlStr];
    [self.view addSubview:player];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
