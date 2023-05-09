//
//  BlockModel.h
//  Tetris
//
//  Created by 郭明亮 on 2022/4/7.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ShapeDireciton) {
    ShapeDireciton_Left = 0,
    ShapeDireciton_Up,
    ShapeDireciton_Right,
    ShapeDireciton_Down,
};

typedef NS_ENUM(NSUInteger, ShapeType) {
    /// 长方形
    ShapeType_Rectangle = 0,
    /// 正方形
    ShapeType_Square,    
    /// 锥形
    ShapeType_Taper,
    /// 三角形
    ShapeType_Rriangle,
    /// 反三角形
    ShapeType_ReverserRriangle,
    /// N形
    ShapeType_N,
    /// 反N形
    ShapeTYpe_ReverseN
};

@interface BlockModel : NSObject

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, strong, nullable) SKShapeNode *node;

@end

@interface ShapeModel : NSObject

@property (nonatomic, assign) ShapeDireciton direction;
@property (nonatomic, assign) ShapeType type;
@property (nonatomic, strong) NSArray<BlockModel *> *blocks;

+ (instancetype)createRandomShape;

- (NSInteger)minColumn;
- (NSInteger)maxColumn;
- (NSInteger)maxRow;

@end

NS_ASSUME_NONNULL_END
