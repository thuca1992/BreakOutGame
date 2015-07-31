//
//  ViewController.m
//  BreakOutGame
//
//  Created by Nguyen Thanh Tung on 7/30/15.
//  Copyright (c) 2015 Nguyen Thanh Tung. All rights reserved.
//

#import "ViewController.h"
#import "Brick.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController{
    CGFloat numberBrickColumn;
    CGFloat numberBrickRow;
    CGFloat marginTop;
    CGFloat marginBottom;
    CGFloat marginLeft;
    CGFloat distanceBetweenBricks;
    CGFloat ballRadius;
    CGFloat brickWidth;
    CGFloat brickHeight;
    int score;
    CGFloat barX;
    CGFloat barY;
    CGFloat barWidth;
    CGFloat barHeight;
    
    NSMutableArray *arrBricks;
    
    UIView *bar;
    UIImageView *ball;
    
    CGSize mainViewSize;
    
    CGPoint delta;
    
    NSTimer *timer;
    AVAudioPlayer *audioPlayer;
    bool isStart;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setData];
    [self setBackground];
    [self addPanGesture];
    [self createBricks];
    [self drawBar];
    [self drawBall];
    [self setUpAudioPlayer];
}

- (void)setData {
    numberBrickColumn = 8;
    numberBrickRow = 4;
    marginTop = 60;
    marginBottom = 60;
    marginLeft = 10;
    ballRadius = 12;
    score = 0;
    distanceBetweenBricks = 4;
    mainViewSize = self.view.bounds.size;
    brickHeight = 20;
    arrBricks = [[NSMutableArray alloc] init];
    barWidth = 100;
    barHeight = 15;
    barX = mainViewSize.width/2 - barWidth/2;
    barY = mainViewSize.height - marginBottom;
    delta = CGPointMake(1.0,1.0);
    isStart = false;
    
}

- (void)createBricks {
    for (int i = 0 ; i < numberBrickRow; i++) {
        for (int j = 0; j < numberBrickColumn; j++) {
            brickWidth = (mainViewSize.width - marginLeft*2 - (numberBrickColumn - 1) * distanceBetweenBricks) / numberBrickColumn;
            CGFloat x = j * brickWidth + marginLeft + j * distanceBetweenBricks;
            CGFloat y = marginTop + i * brickHeight + i * distanceBetweenBricks;
            [self drawBrick:x andY:y];
        }
    }
}

- (void)drawBrick: (CGFloat) x andY: (CGFloat) y {
    UIView *brickView = [[UIView alloc] initWithFrame:CGRectMake(x, y, brickWidth, brickHeight)];
    [self borderAndRoundBrick:brickView];
    int breakingTimesLeft = [self setBrickColor:brickView];
    Brick *brick = [[Brick alloc]init:brickView and:breakingTimesLeft];
    [arrBricks addObject:brick];
    [self.view addSubview:brickView];
}

- (void)drawBar {
    bar = [[UIView alloc] initWithFrame:CGRectMake(barX, barY, barWidth, barHeight)];
    bar.backgroundColor = [UIColor lightGrayColor];
    bar.layer.cornerRadius = 8;
    [self.view addSubview:bar];
}

- (void)drawBall {
    ball = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ball.png"]];
    ball.center = CGPointMake(mainViewSize.width/2, mainViewSize.height - barHeight/2 - marginBottom - ballRadius/2);
    
    [self.view addSubview:ball];
}

- (void)handleCollision {
     ball.center = CGPointMake(ball.center.x + delta.x, ball.center.y + delta.y);
    
    [self didBallCollideWall];
    
    [self didBallCollideBrick];
    
    [self didBallCollideBar];
    
    [self didGameOver];
    
}
- (void)didBallCollideWall {
    if(ball.center.x > mainViewSize.width || ball.center.x < 0){
        delta.x = -delta.x;
        [self playSong];

    }
    if(ball.center.y > mainViewSize.height || ball.center.y < 0){
        delta.y = -delta.y;
        [self playSong];

    }
    
}

- (void)didBallCollideBrick {
    for (int i = 0; i < arrBricks.count; i++) {
        Brick *brick = [arrBricks objectAtIndex:i];
        UIView *brickView = brick.brickView;
      
        bool isCollisionBetweenBrickAndBall = [self detectCollisionBetweenTwoViews:brickView andViewB:ball];
        if (isCollisionBetweenBrickAndBall) {
            [self playSong];
            score++;
            [self changeBallSpeed];
            brick.breakingTimesLeft--;
            if (brick.breakingTimesLeft == 0) {
                [brickView removeFromSuperview];
                [arrBricks removeObjectAtIndex:i];
            }
            else {
                brickView.alpha /=2;
            }
            delta.y = -delta.y;
            break;
        }
    }
}

- (void)didBallCollideBar{
    bool isCollisionBetweenBarAndBall = [self detectCollisionBetweenTwoViews:bar andViewB:ball];
    if (isCollisionBetweenBarAndBall) {
        [self playSong];
        delta.y = -delta.y;
    }
}


- (bool)detectCollisionBetweenTwoViews: (UIView*) viewA andViewB: (UIView*) viewB {
    CGRect boundsA = [viewA convertRect:viewA.bounds toView:nil];
    CGRect boundsB = [viewB convertRect:viewB.bounds toView:nil];
    return CGRectIntersectsRect(boundsA, boundsB);
}

- (void)startGame {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.003       target:self selector:@selector(handleCollision) userInfo:nil repeats:true];
}

- (void)didGameOver {
    if(ball.center.y > mainViewSize.height - marginBottom + bar.bounds.size.height + ballRadius){
        [timer invalidate];
        [self showDialog];
    }
}

- (void)addPanGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.view addGestureRecognizer:panGesture];
}

-(void)onPan:(UIPanGestureRecognizer*)recognizer
{
    if(!isStart){
        [self startGame];
        isStart = true;
    }

    CGPoint movement = [recognizer translationInView:recognizer.view];
    CGFloat newBarPositionX = bar.center.x + movement.x;
    if(movement.x < 0){
        if (newBarPositionX < 0 ) {
            newBarPositionX = 0;
        }
        bar.center = CGPointMake(newBarPositionX, bar.center.y);
    }
    if(movement.x > 0){
        if (newBarPositionX > mainViewSize.width ) {
            newBarPositionX = mainViewSize.width;
        }
        bar.center = CGPointMake(bar.center.x + movement.x, bar.center.y);
    }
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}

- (void)borderAndRoundBrick: (UIView*) brickView {
    brickView.layer.borderWidth = 0.5f;
    brickView.layer.cornerRadius = 5;
}

- (int)setBrickColor: (UIView*) brickView {
    int randomNumber = arc4random_uniform(3)+1;
    if (randomNumber == 1){
        brickView.backgroundColor = [UIColor greenColor];
    } else if (randomNumber == 2) {
        brickView.backgroundColor = [UIColor blueColor];
    } else {
        brickView.backgroundColor = [UIColor redColor];
    }
    return randomNumber;
}

- (void)setBackground {
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background_wallpaper.jpg"]];
 
    [self.view addSubview:image];
}

- (void) setUpAudioPlayer {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"pingpong" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                         error:&error];
    [audioPlayer prepareToPlay];

}
- (void) playSong {
    [audioPlayer play];
}

- (void)showDialog {
    
    NSString *message = [NSString stringWithFormat: @"Your score: %d", score];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Game Over"
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             //[self resetData];
                             //[self startGame];
                             
                         }];

    
    [alert addAction:ok];
     [self presentViewController:alert animated:YES completion:nil];
}

- (void)changeBallSpeed {
    if(delta.x < 0){
        delta.x-=0.05;
    }
    else{
        delta.x+=0.05;
    }
    if(delta.y < 0){
        delta.y-=0.05;
    }
    else{
        delta.y+=0.05;
    }
}

- (void)resetData {
     score = 0;
    delta = CGPointMake(1.0,1.0);
    bar.center = CGPointMake(barX, barY);
    arrBricks = [[NSMutableArray alloc] init];
    ball.center = CGPointMake(mainViewSize.width/2, mainViewSize.height - barHeight/2 - marginBottom - ballRadius/2);
    [self createBricks];

}
@end
