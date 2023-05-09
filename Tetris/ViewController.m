//
//  ViewController.m
//  Tetris
//
//  Created by 郭明亮 on 2022/4/7.
//

#import "ViewController.h"
#import "GameScene.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GameScene *scene = [[GameScene alloc]initWithSize:self.view.bounds.size];
    scene.backgroundColor = UIColor.whiteColor;
    scene.scaleMode = SKSceneScaleModeAspectFill;
    SKView *skView = [[SKView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:skView];
    [skView presentScene:scene];
}


@end
