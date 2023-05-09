//
//  GameScene.m
//  Tetris
//
//  Created by 郭明亮 on 2022/4/6.
//

#import "GameScene.h"
#import "BlockModel.h"

NSInteger const row = 20;
NSInteger const column = 10;
CGFloat const boxWidth = 30;
CGFloat const width = (column*boxWidth);
CGFloat const height = (row*boxWidth);
#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height

#define LineShowSaveKey @"LineShowSaveKey"

@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *gameView;
@property (nonatomic, assign) CGFloat lastTime;
@property (nonatomic, strong) ShapeModel *currentShape;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isGameOver;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, assign) CGFloat timeSpace;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, strong) SKLabelNode *startLabel;
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) SKSpriteNode *showNode;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    self.dataArray = [NSMutableArray array];
    self.timeSpace = 0.6;
    
    for (NSInteger i = 0; i < row; i++) {
        NSMutableArray *rowArray = [NSMutableArray array];
        for (NSInteger j = 0; j < column; j++) {
            [rowArray addObject:[BlockModel new]];
        }
        [self.dataArray addObject:rowArray];
    }
    
    self.gameView = [[SKSpriteNode alloc]initWithColor:UIColor.blackColor size:CGSizeMake(width, height)];
    self.gameView.position = CGPointMake(SCREEN_WIDTH/2.0-width/2.0, SCREEN_HEIGHT/2.0+height/2.0);
    self.gameView.anchorPoint = CGPointMake(0, 1);
    [self addChild:self.gameView];
    
    [self addLine];
    
    self.scoreLabel = [SKLabelNode labelNodeWithText:@"0"];
    self.scoreLabel.fontSize = 25;
    self.scoreLabel.fontColor = UIColor.blackColor;
    self.scoreLabel.position = CGPointMake(SCREEN_WIDTH/2.0, self.gameView.position.y+20);
    [self addChild:self.scoreLabel];
    
    self.startLabel = [SKLabelNode labelNodeWithText:@"开始"];
    self.startLabel.fontColor = UIColor.blueColor;
    self.startLabel.fontSize = 25;
    self.startLabel.position = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT-self.gameView.position.y-40);
    [self addChild:self.startLabel];
    
    BOOL showLine = [NSUserDefaults.standardUserDefaults boolForKey:LineShowSaveKey];
    SKTexture *texture = [SKTexture textureWithImageNamed:showLine ? @"zhr_login_psd_open" : @"zhr_login_psd_close"];
    self.showNode = [SKSpriteNode spriteNodeWithTexture:texture];
    self.showNode.position = CGPointMake(SCREEN_WIDTH/2.0-width/2.0+11, SCREEN_HEIGHT-self.gameView.position.y-40+8);
    self.showNode.size = CGSizeMake(22, 22);
    self.showNode.name = showLine ? @"show" : @"hide";
    [self addChild:self.showNode];
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(tapView:)];
    [view addGestureRecognizer:tap];
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]init];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftSwipe addTarget:self action:@selector(swipeLeft)];
    [view addGestureRecognizer:leftSwipe];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]init];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [rightSwipe addTarget:self action:@selector(swipeRight)];
    [view addGestureRecognizer:rightSwipe];
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc]init];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [downSwipe addTarget:self action:@selector(swipeDown)];
    [view addGestureRecognizer:downSwipe];
}

- (void)resetGame {
    for (NSArray *array in self.dataArray) {
        for (BlockModel *model in array) {
            [model.node removeAllActions];
            [model.node removeFromParent];
            model.node = nil;
        }
    }
    for (SKNode *node in self.gameView.children) {
        [node removeAllActions];
        [node removeFromParent];
    }
    self.isGameOver = NO;
    self.scoreLabel.text = @"0";
    self.startLabel.text = @"暂停";
    self.timeSpace = 0.6;
    [self addLine];
    [self addBlock];
}

- (void)addLine {
    BOOL showLine = [NSUserDefaults.standardUserDefaults boolForKey:LineShowSaveKey];
    self.lineArray = [NSMutableArray array];
    for (NSInteger i = 1; i < column; i++) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1] size:CGSizeMake(0.5, height)];
        line.position = CGPointMake(i*boxWidth, -height/2.0);
        line.hidden = !showLine;
        [self.gameView addChild:line];
        [self.lineArray addObject:line];
    }
    for (NSInteger i = 1; i < row; i++) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1] size:CGSizeMake(width, 0.5)];
        line.position = CGPointMake(width/2.0, -i*boxWidth);
        line.hidden = !showLine;
        [self.gameView addChild:line];
        [self.lineArray addObject:line];
    }
}

- (void)addBlock {
    self.currentShape = [ShapeModel createRandomShape];
    for (BlockModel *model in self.currentShape.blocks) {
        model.node.position = [self positionAtRow:model.row column:model.column];
        [self.gameView addChild:model.node];
    }
}

- (CGPoint)positionAtRow:(NSInteger)row column:(NSInteger)column {
    return CGPointMake(column*boxWidth, -row*boxWidth-boxWidth);
}

- (void)startButtonClick {
    if ([self.startLabel.text isEqualToString:@"开始"]) {
        self.startLabel.text = @"暂停";
        [self addBlock];
    }else if ([self.startLabel.text isEqualToString:@"暂停"]) {
        self.isPause = YES;
        self.startLabel.text = @"继续";
    }else {
        self.isPause = NO;
        self.startLabel.text = @"暂停";
    }
}

- (void)showButtonClick {
    if ([self.showNode.name isEqualToString:@"show"]) {
        self.showNode.name = @"hide";
        self.showNode.texture = [SKTexture textureWithImageNamed:@"zhr_login_psd_close"];
        for (SKSpriteNode *node in self.lineArray) {
            node.hidden = YES;
        }
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:LineShowSaveKey];
    }else {
        self.showNode.name = @"show";
        self.showNode.texture = [SKTexture textureWithImageNamed:@"zhr_login_psd_open"];
        for (SKSpriteNode *node in self.lineArray) {
            node.hidden = NO;
        }
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:LineShowSaveKey];
    }
}

- (void)tapView:(UIGestureRecognizer *)ges {
    CGPoint point = [ges locationInView:self.view];
    CGPoint buttonPoint = [self convertPointToView:self.startLabel.position];
    if (fabs(point.x-buttonPoint.x) < 30 && fabs(point.y-(buttonPoint.y-10)) < 20) {
        [self startButtonClick];
        return;
    }
    buttonPoint = [self convertPointToView:self.showNode.position];
    if (fabs(point.x-buttonPoint.x) < 20 && fabs(point.y-(buttonPoint.y-10)) < 20) {
        [self showButtonClick];
        return;
    }
    if (self.isPause) return;
    if (self.currentShape.type == ShapeType_Square) return;
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (BlockModel *model in self.currentShape.blocks) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:@[@(model.row), @(model.column)]];
        [tempArray addObject:array];
    }

    for (NSInteger i = 0; i < tempArray.count; i++) {
        NSMutableArray *blockArray = tempArray[i];
        NSInteger tempRow = [blockArray.firstObject integerValue];
        NSInteger tempColumn = [blockArray.lastObject integerValue];
        if (self.currentShape.type == ShapeType_Rectangle) {
            if (self.currentShape.direction == ShapeDireciton_Left ||
                self.currentShape.direction == ShapeDireciton_Right) {
                tempColumn = self.currentShape.blocks[1].column;
                tempRow += (i-1);
            }else {
                tempRow = self.currentShape.blocks[1].row;
                tempColumn += (i-1);
            }
        }else if (self.currentShape.type == ShapeType_Taper){
            if (i == 2) {
                continue;
            }
            if (self.currentShape.direction == ShapeDireciton_Left) {
                if (i == 0) {
                    tempRow++;
                    tempColumn++;
                }else if (i == 1) {
                    tempRow--;
                    tempColumn++;
                }else {
                    tempRow++;
                    tempColumn--;
                }
            }else if (self.currentShape.direction == ShapeDireciton_Up) {
                if (i == 0) {
                    tempRow++;
                    tempColumn--;
                }else if (i == 1) {
                    tempRow++;
                    tempColumn++;
                }else {
                    tempRow--;
                    tempColumn--;
                }
            }else if (self.currentShape.direction == ShapeDireciton_Right) {
                if (i == 0) {
                    tempRow--;
                    tempColumn--;
                }else if (i == 1) {
                    tempRow++;
                    tempColumn--;
                }else {
                    tempRow--;
                    tempColumn++;
                }
            }else {
                if (i == 0) {
                    tempRow--;
                    tempColumn++;
                }else if (i == 1) {
                    tempRow--;
                    tempColumn--;
                }else {
                    tempRow++;
                    tempColumn++;
                }
            }
        }else if (self.currentShape.type == ShapeType_Rriangle) {
            if (i == 2) {
                continue;
            }
            if (self.currentShape.direction == ShapeDireciton_Left) {
                if (i == 0) {
                    tempRow += 2;
                }else if (i == 1) {
                    tempRow--;
                    tempColumn++;
                }else if (i == 3) {
                    tempRow++;
                    tempColumn--;
                }
            }else if (self.currentShape.direction == ShapeDireciton_Up){
                if (i == 0) {
                    tempColumn -= 2;
                }else if (i == 1) {
                    tempRow++;
                    tempColumn++;
                }else if (i == 3) {
                    tempRow--;
                    tempColumn--;
                }
            }else if (self.currentShape.direction == ShapeDireciton_Right) {
                if (i == 0) {
                    tempRow -= 2;
                }else if (i == 1) {
                    tempRow++;
                    tempColumn--;
                }else if (i == 3) {
                    tempRow--;
                    tempColumn++;
                }
            }else {
                if (i == 0) {
                    tempColumn += 2;
                }else if (i == 1) {
                    tempRow--;
                    tempColumn--;
                }else if (i == 3) {
                    tempRow++;
                    tempColumn++;
                }
            }
        }else if (self.currentShape.type == ShapeType_ReverserRriangle) {
            if (i == 1) {
                continue;
            }
            if (self.currentShape.direction == ShapeDireciton_Left) {
                if (i == 0) {
                    tempRow++;
                    tempColumn++;
                }else if (i == 2) {
                    tempRow++;
                    tempColumn--;
                }else {
                    tempRow += 2;
                    tempColumn -= 2;
                }
            }else if (self.currentShape.direction == ShapeDireciton_Up) {
                if (i == 0) {
                    tempRow ++;
                    tempColumn--;
                }else if (i == 2) {
                    tempRow--;
                    tempColumn--;
                }else {
                    tempRow -= 2;
                    tempColumn -= 2;
                }
            }else if (self.currentShape.direction == ShapeDireciton_Right) {
                if (i == 0) {
                    tempRow--;
                    tempColumn--;
                }else if (i == 2) {
                    tempRow--;
                    tempColumn++;
                }else {
                    tempRow -= 2;
                    tempColumn += 2;
                }
            }else {
                if (i == 0) {
                    tempRow--;
                    tempColumn++;
                }else if (i == 2) {
                    tempRow++;
                    tempColumn++;
                }else {
                    tempRow += 2;
                    tempColumn += 2;
                }
            }
        }else if (self.currentShape.type == ShapeType_N) {
            if (i == 1) {
                continue;
            }
            if (self.currentShape.direction == ShapeDireciton_Left ||
                self.currentShape.direction == ShapeDireciton_Right) {
                if (i == 0) {
                    tempRow += 2;
                }else if (i == 2) {
                    tempRow++;
                    tempColumn--;
                }else {
                    tempRow--;
                    tempColumn--;
                }
            }else {
                if (i == 0) {
                    tempRow -= 2;
                }else if (i == 2) {
                    tempRow--;
                    tempColumn++;
                }else {
                    tempRow++;
                    tempColumn++;
                }
            }
        }else if (self.currentShape.type == ShapeTYpe_ReverseN) {
            if (i == 1) {
                continue;
            }
            if (self.currentShape.direction == ShapeDireciton_Left ||
                self.currentShape.direction == ShapeDireciton_Right) {
                if (i == 0) {
                    tempRow++;
                    tempColumn++;
                }else if (i == 2) {
                    tempRow++;
                    tempColumn--;
                }else {
                    tempColumn-=2;
                }
            }else {
                if (i == 0) {
                    tempRow--;
                    tempColumn--;
                }else if (i == 2) {
                    tempRow--;
                    tempColumn++;
                }else {
                    tempColumn+=2;
                }
            }
        }
        blockArray[0] = @(tempRow);
        blockArray[1] = @(tempColumn);
    }
    
    NSInteger minColumn = column;
    NSInteger minRow = row;
    NSInteger maxColumn = 0;
    NSInteger maxRow = 0;
    for (NSArray *array in tempArray) {
        NSInteger row = [array.firstObject integerValue];
        NSInteger column = [array.lastObject integerValue];
        if (column < minColumn) {
            minColumn = column;
        }
        if (row < minRow) {
            minRow = row;
        }
        if (column > maxColumn) {
            maxColumn = column;
        }
        if (row > maxRow) {
            maxRow = row;
        }
    }

    while (minColumn < 0) {
        for (NSMutableArray *array in tempArray) {
            array[1] = @([array[1] integerValue] + 1);
        }
        minColumn++;
    }
    
    while (minRow < 0) {
        for (NSMutableArray *array in tempArray) {
            array[0] = @([array[0] integerValue] + 1);
        }
        minRow++;
    }
    
    while (maxColumn > column-1) {
        for (NSMutableArray *array in tempArray) {
            array[1] = @([array[1] integerValue] - 1);
        }
        maxColumn--;
    }
    
    while (maxRow > row-1) {
        for (NSMutableArray *array in tempArray) {
            array[0] = @([array[0] integerValue] - 1);
        }
        maxRow--;
    }
    
    BOOL canRoation = YES;
    for (NSArray *array in tempArray) {
        NSInteger row = [array.firstObject integerValue];
        NSInteger column = [array.lastObject integerValue];
        BlockModel *block = self.dataArray[row][column];
        if (block.node) {
            canRoation = NO;
        }
    }
    if (!canRoation) {
        return;
    }
    
    for (NSInteger i = 0; i < tempArray.count; i++) {
        BlockModel *model = self.currentShape.blocks[i];
        model.row = [tempArray[i][0] integerValue];
        model.column = [tempArray[i][1] integerValue];
        SKAction *action = [SKAction moveTo:[self positionAtRow:model.row column:model.column] duration:0];
        [model.node runAction:action];
    }
    
    self.currentShape.direction ++;
    if (self.currentShape.direction > 3) {
        self.currentShape.direction = ShapeDireciton_Left;
    }
}

- (void)swipeLeft {
    if (self.isPause) return;
    if (self.currentShape.minColumn <= 0) {
        return;
    }
    for (BlockModel *model in self.currentShape.blocks) {
        model.column--;
        SKAction *action = [SKAction moveTo:[self positionAtRow:model.row column:model.column] duration:0];
        [model.node runAction:action];
    }
}

- (void)swipeRight {
    if (self.isPause) return;
    if (self.currentShape.maxColumn >= column-1) {
        return;
    }
    for (BlockModel *model in self.currentShape.blocks) {
        model.column++;
        SKAction *action = [SKAction moveTo:[self positionAtRow:model.row column:model.column] duration:0];
        [model.node runAction:action];
    }
}

- (void)swipeDown {
    if (self.isPause) return;
    while (![self shouldStop]) {
        for (BlockModel *model in self.currentShape.blocks) {
            if (model.row < row-1) {
                model.row ++;
            }
        }
    }
    for (BlockModel *model in self.currentShape.blocks) {
        SKAction *action = [SKAction moveTo:[self positionAtRow:model.row column:model.column] duration:0];
        [model.node runAction:action];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    if (self.isGameOver) return;
    if (!self.currentShape) return;
    if (self.isPause) return;
    if ((currentTime-self.lastTime) < self.timeSpace) return;
    self.lastTime = currentTime;
    if ([self shouldStop]) {
        for (BlockModel *model in self.currentShape.blocks) {
            if (model.row >= 0 && model.row < row) {
                self.dataArray[model.row][model.column] = model;
            }
        }
        [self checkCanRemove];
        self.currentShape = nil;
        [self addBlock];
    }else {
        for (BlockModel *model in self.currentShape.blocks) {
            if (model.row < row-1) {
                model.row ++;
                SKAction *action = [SKAction moveTo:[self positionAtRow:model.row column:model.column] duration:0];
                [model.node runAction:action];
            }
        }
    }
}

- (BOOL)shouldStop {
    BOOL isStop = NO;
    for (BlockModel *model in self.currentShape.blocks) {
        if (model.row+1 >= row) {
            isStop = YES;
            break;
        }
        BlockModel *block = self.dataArray[model.row+1][model.column];
        if (block.node) {
            isStop = YES;
            if (block.row <= 2) {
                self.isGameOver = YES;
                [self gameOver];
            }
            break;
        }
    }
    return isStop;
}

- (void)gameOver {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"游戏结束" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self resetGame];
    }];
    [alert addAction:action];
    [UIApplication.sharedApplication.delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)checkCanRemove {
    NSMutableArray *removeArray = [NSMutableArray array];
    for (NSArray *array in self.dataArray) {
        BOOL isAll = YES;
        for (BlockModel *model in array) {
            if (!model.node) {
                isAll = NO;
                break;
            }
        }
        if (isAll) {
            [removeArray addObject:array];
        }
    }
    if (removeArray.count > 0) {
        for (NSArray *array in removeArray) {
            for (BlockModel *model in array) {
                [model.node removeAllActions];
                [model.node removeFromParent];
                model.node = nil;
            }
            NSInteger index = [self.dataArray indexOfObject:array];
            for (NSInteger i = index; i > 0; i--) {
                NSMutableArray *array = self.dataArray[i];
                for (BlockModel *model in array) {
                    model.row ++;
                    SKAction *action = [SKAction moveTo:[self positionAtRow:model.row column:model.column] duration:0];
                    [model.node runAction:action];
                }
            }
        }

        NSInteger lastScore = [self.scoreLabel.text integerValue];
        NSInteger score = lastScore + (removeArray.count * 10);
        self.scoreLabel.text = [NSString stringWithFormat:@"%ld", score];
        if (lastScore / 100 != score / 100) {
            self.timeSpace -= 0.01;
        }
        
        [self.dataArray removeObjectsInArray:removeArray];
        for (NSInteger i = 0; i < removeArray.count; i++) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSInteger j = 0; j < column; j++) {
                [array addObject:[BlockModel new]];
            }
            [self.dataArray insertObject:array atIndex:0];
        }
    }
}

@end
