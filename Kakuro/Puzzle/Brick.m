//
//  Brick.m
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 09.03.13.
//  Copyright (c) 2013 Alexandr Nikanorov. All rights reserved.
//

#import "Brick.h"

@implementation Brick

@synthesize Vertical;
@synthesize Horizontal;
@synthesize countHorizontal;
@synthesize countVertical;
@synthesize Value;
@synthesize arrayOuterNumbers;
@synthesize arrayInnerNumbers;
@synthesize bType;
@synthesize marked;
@synthesize horizSumMarkedGreen;
@synthesize vertSumMarkedGreen;
@synthesize horizSumMarkedRed;
@synthesize vertSumMarkedRed;
@synthesize verticalSumHighlighted;
@synthesize horizontalSumHighlighted;
//метод инициализации объекта класса
-(id)initWithVertical:(NSInteger)vertic Horizontal:(NSInteger)horizont countHorizontal:(NSInteger)countHorizont countVertical:(NSInteger)countVertic Type:(BrickType)tp Value:(NSInteger)Val {
    self = [super init];
    if (self) {
        self.Vertical = vertic;
        self.Horizontal = horizont;
        self.countHorizontal = countHorizont;
        self.countVertical = countVertic;
        self.Value = Val;
        self.bType = tp;
        arrayInnerNumbers = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
        arrayOuterNumbers = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
    }
    return self;
}
//геттер для свойства Vertical
-(NSInteger) vert {
    return Vertical;
}
//геттер для свойства Horizontal
-(NSInteger) horiz {
    return Horizontal;
}
//геттер для свойства countHorizontal
-(NSInteger) countSpacesHoriz {
    return countHorizontal;
}
//геттер для свойства countVertical
-(NSInteger) countSpacesVert {
    return countVertical;
}
//геттер для свойства Value
-(NSInteger)valueBlank {
    return Value;
}
//сеттер для свойства Value
-(void)setValueBlank:(NSInteger)vl {
    Value = vl;
}

#pragma mark NSCoding Protocol
//метод кодирования объекта
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:[self Vertical] forKey:@"Vertical"];
    [encoder encodeInteger:[self Horizontal] forKey:@"Horizontal"];
    [encoder encodeInteger:[self countVertical] forKey:@"countVertical"];
    [encoder encodeInteger:[self countHorizontal] forKey:@"countHorizontal"];
    [encoder encodeInteger:[self Value] forKey:@"Value"];
    [encoder encodeObject:[self arrayOuterNumbers] forKey:@"arrayOuterNumbers"];
    [encoder encodeObject:[self arrayInnerNumbers] forKey:@"arrayInnerNumbers"];
    [encoder encodeInt:[self bType] forKey:@"bType"];
    [encoder encodeBool:[self marked] forKey:@"marked"];
    [encoder encodeBool:[self horizSumMarkedGreen] forKey:@"horizSumMarkedGreen"];
    [encoder encodeBool:[self vertSumMarkedGreen] forKey:@"vertSumMarkedGreen"];
    [encoder encodeBool:[self horizSumMarkedRed] forKey:@"horizSumMarkedRed"];
    [encoder encodeBool:[self vertSumMarkedRed] forKey:@"vertSumMarkedRed"];
    [encoder encodeBool:[self verticalSumHighlighted] forKey:@"verticalSumHighlighted"];
    [encoder encodeBool:[self horizontalSumHighlighted] forKey:@"horizontalSumHighlighted"];
}
//метод декодирования объекта
- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        [self setVertical:[decoder decodeIntegerForKey:@"Vertical"]];
        [self setHorizontal:[decoder decodeIntegerForKey:@"Horizontal"]];
        [self setCountVertical:[decoder decodeIntegerForKey:@"countVertical"]];
        [self setCountHorizontal:[decoder decodeIntegerForKey:@"countHorizontal"]];
        [self setValue:[decoder decodeIntegerForKey:@"Value"]];
        [self setArrayOuterNumbers:[decoder decodeObjectForKey:@"arrayOuterNumbers"]];
        [self setArrayInnerNumbers:[decoder decodeObjectForKey:@"arrayInnerNumbers"]];
        [self setBType:[decoder decodeIntForKey:@"bType"]];
        [self setMarked:[decoder decodeBoolForKey:@"marked"]];
        [self setHorizSumMarkedGreen:[decoder decodeBoolForKey:@"horizSumMarkedGreen"]];
        [self setVertSumMarkedGreen:[decoder decodeBoolForKey:@"vertSumMarkedGreen"]];
        [self setHorizSumMarkedRed:[decoder decodeBoolForKey:@"horizSumMarkedRed"]];
        [self setVertSumMarkedRed:[decoder decodeBoolForKey:@"vertSumMarkedRed"]];
        [self setVerticalSumHighlighted:[decoder decodeBoolForKey:@"verticalSumHighlighted"]];
        [self setHorizontalSumHighlighted:[decoder decodeBoolForKey:@"horizontalSumHighlighted"]];
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
}

@end