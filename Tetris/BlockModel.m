//
//  BlockModel.m
//  Tetris
//
//  Created by 郭明亮 on 2022/4/7.
//

#import "BlockModel.h"

extern CGFloat const boxWidth;

@implementation BlockModel

@end

@implementation ShapeModel

+ (instancetype)createRandomShape {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, boxWidth, boxWidth)];
    NSArray *array = @[@[@[@(0), @(3)], @[@(0), @(4)], @[@(0), @(5)], @[@(0), @(6)]],
                       @[@[@(0), @(4)], @[@(0), @(5)], @[@(1), @(4)], @[@(1), @(5)]],
                       @[@[@(0), @(4)], @[@(1), @(3)], @[@(1), @(4)], @[@(1), @(5)]],
                       @[@[@(0), @(5)], @[@(1), @(3)], @[@(1), @(4)], @[@(1), @(5)]],
                       @[@[@(0), @(3)], @[@(1), @(3)], @[@(1), @(4)], @[@(1), @(5)]],
                       @[@[@(0), @(5)], @[@(1), @(4)], @[@(1), @(5)], @[@(2), @(4)]],
                       @[@[@(0), @(4)], @[@(1), @(4)], @[@(1), @(5)], @[@(2), @(5)]]];
    NSArray *colorArray = @[UIColor.orangeColor, UIColor.redColor, UIColor.blueColor, UIColor.purpleColor, UIColor.magentaColor, UIColor.cyanColor, UIColor.greenColor];
    NSMutableArray *blockArray = [NSMutableArray array];
    NSInteger index = arc4random()%array.count;
    
    for (NSArray *nums in array[index]) {
        BlockModel *model = [[BlockModel alloc]init];
        model.row = [nums.firstObject integerValue];
        model.column = [nums.lastObject integerValue];
        model.node = [SKShapeNode shapeNodeWithPath:path.CGPath];
        model.node.fillColor = colorArray[index];
        [blockArray addObject:model];
    }
    
    ShapeModel *shape = [[ShapeModel alloc]init];
    shape.blocks = blockArray;
    shape.type = index;
    return shape;
}

- (NSInteger)minColumn {
    NSInteger min = self.blocks.firstObject.column;
    for (BlockModel *model in self.blocks) {
        if (model.column < min) {
            min = model.column;
        }
    }
    return min;
}

- (NSInteger)maxColumn {
    NSInteger max = self.blocks.firstObject.column;
    for (BlockModel *model in self.blocks) {
        if (model.column > max) {
            max = model.column;
        }
    }
    return max;
}

- (NSInteger)maxRow {
    NSInteger max = self.blocks.firstObject.row;
    for (BlockModel *model in self.blocks) {
        if (model.row > max) {
            max = model.row;
        }
    }
    return max;
}

@end
