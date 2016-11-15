//
//  Brick.h
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 09.03.13.
//  Copyright (c) 2013 Alexandr Nikanorov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BlankBrick,
    SumBrick,
    ValBrick,
    ZeroBrick,
    NullBrick
}BrickType;

@interface Brick : NSObject <NSCoding>

@property (nonatomic, assign, readwrite) NSInteger Vertical;
@property (nonatomic, assign, readwrite) NSInteger Horizontal;
@property (nonatomic, assign, readwrite) NSInteger countVertical;
@property (nonatomic, assign, readwrite) NSInteger countHorizontal;
@property (assign, readwrite) NSInteger Value;
@property (copy, readwrite) NSMutableArray* arrayOuterNumbers;
@property (copy, readwrite) NSMutableArray* arrayInnerNumbers;
@property (assign, readwrite) BrickType bType;
@property (assign, readwrite) BOOL marked;
@property (assign, readwrite) BOOL horizSumMarkedGreen;
@property (assign, readwrite) BOOL vertSumMarkedGreen;
@property (assign, readwrite) BOOL horizSumMarkedRed;
@property (assign, readwrite) BOOL vertSumMarkedRed;
@property (assign, readwrite) BOOL verticalSumHighlighted;
@property (assign, readwrite) BOOL horizontalSumHighlighted;

-(id)initWithVertical:(NSInteger)vertic Horizontal:(NSInteger)horizont countHorizontal:(NSInteger)countHorizont countVertical:(NSInteger)countVertic Type:(BrickType)tp Value:(NSInteger)Val;
-(NSInteger) vert;
-(NSInteger) horiz;
-(NSInteger) countSpacesHoriz;
-(NSInteger) countSpacesVert;
-(NSInteger) valueBlank;
-(void)setValueBlank:(NSInteger)vl;

@end
