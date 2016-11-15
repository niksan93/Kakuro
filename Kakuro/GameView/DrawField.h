//
//  DrawField.h
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 18.04.13.
//  Copyright (c) 2013 Alexandr Nikanorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleGenerator.h"
#import "GameViewController.h"

@interface DrawField : UIView <UIGestureRecognizerDelegate> {
    NSInteger highLightedI;
    NSInteger highLightedJ;
}

@property (retain, readwrite) NSMutableArray* arrGenerated;
@property (assign, readwrite) BOOL cellChosen;
@property (assign, readwrite) NSInteger cellChosenX;
@property (assign, readwrite) NSInteger cellChosenY;
@property (assign, readwrite) NSInteger arrLength;
@property (retain, readwrite) NSNumber* getItemCountInRow;

-(void)reDraw;
-(void)releasePuzzle;

@end
