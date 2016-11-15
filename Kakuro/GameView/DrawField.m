//
//  DrawField.m
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 18.04.13.
//  Copyright (c) 2013 Alexandr Nikanorov. All rights reserved.
//

#import "DrawField.h"
#import "Brick.h"

@implementation DrawField

@synthesize arrGenerated;
@synthesize cellChosen;
@synthesize cellChosenX;
@synthesize cellChosenY;
@synthesize arrLength;
@synthesize getItemCountInRow;

#pragma mark initialize methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

#pragma mark
//освобождает память массива игрового поля
-(void)releasePuzzle {    
    [arrGenerated removeAllObjects];
}

#pragma mark drawRect
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//метод рисования игрового поля
- (void)drawRect:(CGRect)rect
{
    if (arrLength == 0) {//([arrGenerated count] == 0) {
        return;
    }
    NSString *value;
    //const char *str;
    //NSInteger len = sqrt([arrGenerated count]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(context, transform);
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 4);
//    paint puzzle
    for (NSInteger i = 0; i < arrLength+1; i++) {
//        paint horizontal lines
        CGContextMoveToPoint(context, 0, i*[getItemCountInRow doubleValue] + 1);
        CGContextAddLineToPoint(context, (arrLength)*[getItemCountInRow doubleValue], i*[getItemCountInRow doubleValue] + 1);
//        paint vertical lines
        CGContextMoveToPoint(context, i*[getItemCountInRow doubleValue], 0);
        CGContextAddLineToPoint(context, i*[getItemCountInRow doubleValue], (arrLength)*[getItemCountInRow doubleValue]);
    }
    for (NSInteger i = 0; i < arrLength; i++) {
        for (NSInteger j = 0; j < arrLength; j++) {
            Brick* brick = [arrGenerated  objectAtIndex:(i*arrLength+j)];
            switch (brick.bType) {
                case SumBrick:
                    if (brick.vert != 0) {
                        value = [NSString stringWithFormat:@"%ld", (long)[[arrGenerated  objectAtIndex:(i*arrLength+j)]vert]];
                        if (brick.vertSumMarkedGreen) {
                            [self drawVerticalSum:value withColor:[UIColor greenColor] atLine:i atColumn:j];
                        } else {
                            if (brick.vertSumMarkedRed) {
                                [self drawVerticalSum:value withColor:[UIColor redColor] atLine:i atColumn:j];
                            } else {
                                [self drawVerticalSum:value withColor:[UIColor blackColor] atLine:i atColumn:j];
                            }
                        }
                    }
                    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
                    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*(i+1));
                    if (brick.horiz != 0) {
                        value = [NSString stringWithFormat:@"%ld", (long)[[arrGenerated  objectAtIndex:(i*arrLength+j)]horiz]];
                        if (brick.horizSumMarkedGreen) {
                            [self drawHorizontalSum:value withColor:[UIColor greenColor] atLine:i atColumn:j];
                        }else {
                            if (brick.horizSumMarkedRed) {
                                [self drawHorizontalSum:value withColor:[UIColor redColor] atLine:i atColumn:j];
                            } else {
                                [self drawHorizontalSum:value withColor:[UIColor blackColor] atLine:i atColumn:j];
                            }
                        }
                    }
                    break;
                    
                case BlankBrick:
                    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
                    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*(i+1));
                    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*i);
                    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*(i+1));
                    break;
                    
                case ValBrick:
                    if (brick.valueBlank != 0) {
                        value = [NSString stringWithFormat:@"%ld", (long)[[arrGenerated  objectAtIndex:i*sqrt([arrGenerated count])+j]valueBlank]];
                        [value drawAtPoint:CGPointMake((4*[getItemCountInRow doubleValue])/10+[getItemCountInRow doubleValue]*j, (7*[getItemCountInRow doubleValue])/11+[getItemCountInRow doubleValue]*i) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16]}];
                    }
                    break;
                    
                case ZeroBrick:
                    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
                    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*(i+1));
                    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*i);
                    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*(i+1));
                    value = [NSString stringWithFormat:@"%ld", (long)[[self.arrGenerated objectAtIndex:i*sqrt([self.arrGenerated count])+j]valueBlank]];
                    [value drawAtPoint:CGPointMake(20+[getItemCountInRow doubleValue]*j, 40+[getItemCountInRow doubleValue]*i) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16]}];
                    break;
                default:
                    break;
            }
        }
    }
    CGContextStrokePath(context);
    
    [self highlighting:context];
}
//перерисовывает поле в параллельном потоку
-(void)reDraw {
    [self performSelectorInBackground:@selector(setNeedsDisplay) withObject:nil];
}

//draw horizontal sum in the sum brick
-(void)drawVerticalSum:(NSString*)value withColor:(UIColor*)color atLine:(NSInteger)i atColumn:(NSInteger)j {
    [value drawAtPoint:CGPointMake([getItemCountInRow doubleValue]/5+[getItemCountInRow doubleValue]*j, (9*[getItemCountInRow doubleValue])/15+[getItemCountInRow doubleValue]*i) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16], NSForegroundColorAttributeName:color}];
}

//draw vertical sum in the sum brick
-(void)drawHorizontalSum:(NSString*)value withColor:(UIColor*)color atLine:(NSInteger)i atColumn:(NSInteger)j {
    [value drawAtPoint:CGPointMake([getItemCountInRow doubleValue]/1.7+[getItemCountInRow doubleValue]*j, (2*[getItemCountInRow doubleValue])/10+[getItemCountInRow doubleValue]*i) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:16], NSForegroundColorAttributeName:color}];
}

//highlighting cells
-(void)highlighting:(CGContextRef)context {
    //отмечает часть клетки с суммой желтым цветом чтобы показать возможные суммы для этого числа
    //если клетка выбрана (пока палец не отпущен от экрана)
    for (NSInteger i = 0; i < arrLength; i++) {
        for (NSInteger j = 0; j < arrLength; j++) {
            Brick* brick = [arrGenerated  objectAtIndex:(i*arrLength+j)];
            if (brick.bType == SumBrick) {
                if (brick.verticalSumHighlighted) {
                    [self highlightVerticalSum:context atLine:i atColumn:j];
                    break;
                }
                if (brick.horizontalSumHighlighted) {
                    [self highlightHorizontalSum:context atLine:i atColumn:j];
                    break;
                }
            }
            //отмечает красной рамкой повторяющиеся цифры
            if (brick.marked) {
                [self highlightSamenumBricksRed:context atLine:i atColumn:j];
            }
        }
    }
    //отмечает клетку желтой рамкой, если она выбрана
    if (cellChosen) {
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
        CGContextSetLineWidth(context, 4);
        CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*cellChosenX, [getItemCountInRow doubleValue]*cellChosenY);
        CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(cellChosenX+1), [getItemCountInRow doubleValue]*cellChosenY);
        CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(cellChosenX+1), [getItemCountInRow doubleValue]*(cellChosenY+1));
        CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*cellChosenX, [getItemCountInRow doubleValue]*(cellChosenY+1));
        CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*cellChosenX, [getItemCountInRow doubleValue]*cellChosenY);
        CGContextStrokePath(context);
    }
}

//highlight vertical sum to see the possible sums for this number
-(void)highlightVerticalSum:(CGContextRef)context atLine:(NSInteger)i atColumn:(NSInteger)j {
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*(i+1));
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*(i+1));
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
    CGContextStrokePath(context);
}

//highlight vertical sum to see the possible sums for this number
-(void)highlightHorizontalSum:(CGContextRef)context atLine:(NSInteger)i atColumn:(NSInteger)j {
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*j+1, [getItemCountInRow doubleValue]*i+1);
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*(i+1));
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*i+1);
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j+1, [getItemCountInRow doubleValue]*i+1);
    CGContextStrokePath(context);
}

-(void)highlightSamenumBricksRed:(CGContextRef)context atLine:(NSInteger)i atColumn:(NSInteger)j {
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 4);
    CGContextMoveToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*i);
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*(j+1), [getItemCountInRow doubleValue]*(i+1));
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*(i+1));
    CGContextAddLineToPoint(context, [getItemCountInRow doubleValue]*j, [getItemCountInRow doubleValue]*i);
    CGContextStrokePath(context);
}

#pragma mark UIGestureRecognizerDelegate
//методы делегата UIGestureRecognizerDelegate
//отслеживает касание экрана подсвечивает сумму, если пользователь выбирает ее
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet* alltouches = [event allTouches];
    UITouch* touch = [[alltouches allObjects] objectAtIndex:0];
    CGPoint touchLoc = [touch locationInView:self];
    NSInteger cellX = 0, cellY = 0;
    ((Brick*)([arrGenerated objectAtIndex:(highLightedI*arrLength+highLightedJ)])).horizontalSumHighlighted = NO;
    ((Brick*)([arrGenerated objectAtIndex:(highLightedI*arrLength+highLightedJ)])).verticalSumHighlighted = NO;
    if (touchLoc.x < (arrLength)*[getItemCountInRow doubleValue]) {
        for (NSInteger i = 0; i < arrLength; i++) {
            if (((touchLoc.x > (i*[getItemCountInRow doubleValue])) && (touchLoc.x < ((i+1)*[getItemCountInRow doubleValue])))) {
                cellX = i;
                break;
            }
        }
        for (NSInteger i = 0; i < arrLength; i++) {
            if ((touchLoc.y > (i*[getItemCountInRow doubleValue])) && (touchLoc.y < ((i+1)*[getItemCountInRow doubleValue]))) {
                cellY = i;
                Brick* brickAtCellXCellY = [arrGenerated objectAtIndex:(cellY*arrLength+cellX)];
                if (brickAtCellXCellY.bType == SumBrick) {
                    if (brickAtCellXCellY.horiz > 0) {
                        if (touchLoc.y > cellY*[getItemCountInRow doubleValue] && touchLoc.x < (cellX+1)*[getItemCountInRow doubleValue]) {
                            NSInteger m = cellY*[getItemCountInRow doubleValue];
                            for (NSInteger n = cellX*[getItemCountInRow doubleValue]; n < (cellX + 1)*[getItemCountInRow doubleValue]; n++) {
                                if (touchLoc.x > n && touchLoc.y == m) {
                                   brickAtCellXCellY.horizontalSumHighlighted = YES;
                                    highLightedI = cellY;
                                    highLightedJ = cellX;
                                    [self reDraw];
                                    return;
                                }
                                m++;
                            }
                        }
                    }
                    if (brickAtCellXCellY.vert > 0) {
                        if (touchLoc.y < (cellY+1)*[getItemCountInRow doubleValue] && touchLoc.x > cellX*[getItemCountInRow doubleValue]) {
                            NSInteger m = cellY*[getItemCountInRow doubleValue];
                            for (NSInteger n = cellX*[getItemCountInRow doubleValue]; n < (cellX + 1)*[getItemCountInRow doubleValue]; n++) {
                                if (touchLoc.x < n && touchLoc.y == m) {
                                    brickAtCellXCellY.verticalSumHighlighted = YES;
                                    highLightedI = cellY;
                                    highLightedJ = cellX;
                                    [self reDraw];
                                    return;
                                }
                                m++;
                            }
                        }
                    }
                }
                break;
            }
        }
    }
}
//отслеживает движение пальца по экрану, подсвечивает суммы
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet* alltouches = [event allTouches];
    UITouch* touch = [[alltouches allObjects] objectAtIndex:0];
    CGPoint touchLoc = [touch locationInView:self];
    NSInteger cellX = 0, cellY = 0;
    ((Brick*)([arrGenerated objectAtIndex:(highLightedI*arrLength+highLightedJ)])).horizontalSumHighlighted = NO;
    ((Brick*)([arrGenerated objectAtIndex:(highLightedI*arrLength+highLightedJ)])).verticalSumHighlighted = NO;
    if (touchLoc.x < (arrLength)*[getItemCountInRow doubleValue]) {
        for (NSInteger i = 0; i < arrLength; i++) {
            if (((touchLoc.x > (i*[getItemCountInRow doubleValue])) && (touchLoc.x < ((i+1)*[getItemCountInRow doubleValue])))) {
                cellX = i;
                break;
            }
        }
        for (NSInteger i = 0; i < arrLength; i++) {
            if ((touchLoc.y > (i*[getItemCountInRow doubleValue])) && (touchLoc.y < ((i+1)*[getItemCountInRow doubleValue]))) {
                cellY = i;
                if ([[arrGenerated objectAtIndex:(cellY*arrLength+cellX)]bType] == SumBrick) {
                    if ([[arrGenerated objectAtIndex:(cellY*arrLength+cellX)]horiz] > 0) {
                        if (touchLoc.y > cellY*[getItemCountInRow doubleValue] && touchLoc.x < (cellX+1)*[getItemCountInRow doubleValue]) {
                            NSInteger m = cellY*[getItemCountInRow doubleValue];
                            for (NSInteger n = cellX*[getItemCountInRow doubleValue]; n < (cellX + 1)*[getItemCountInRow doubleValue]; n++) {
                                if (touchLoc.x > n && touchLoc.y == m) {
                                    ((Brick*)([arrGenerated objectAtIndex:(cellY*arrLength+cellX)])).horizontalSumHighlighted = YES;
                                    highLightedI = cellY;
                                    highLightedJ = cellX;
                                    [self reDraw];
                                    return;
                                }
                                m++;
                            }
                        }
                    }
                    if ([[arrGenerated objectAtIndex:(cellY*arrLength+cellX)]vert] > 0) {
                        if (touchLoc.y < (cellY+1)*[getItemCountInRow doubleValue] && touchLoc.x > cellX*[getItemCountInRow doubleValue]) {
                            NSInteger m = cellY*[getItemCountInRow doubleValue];
                            for (NSInteger n = cellX*[getItemCountInRow doubleValue]; n < (cellX + 1)*[getItemCountInRow doubleValue]; n++) {
                                if (touchLoc.x == n && touchLoc.y > m) {
                                    ((Brick*)([arrGenerated objectAtIndex:(cellY*arrLength+cellX)])).verticalSumHighlighted = YES;
                                    highLightedI = cellY;
                                    highLightedJ = cellX;
                                    [self reDraw];
                                    return;
                                }
                                m++;
                            }
                        }
                    }
                }
                break;
            }
        }
    }
}
//отслеживает окончание касания экрана
//выделяет цифровые клетки / передает информацию о том, что нужно показать подсказку по выбранной сумме
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    ((Brick*)([arrGenerated objectAtIndex:(highLightedI*arrLength+highLightedJ)])).horizontalSumHighlighted = NO;
    ((Brick*)([arrGenerated objectAtIndex:(highLightedI*arrLength+highLightedJ)])).verticalSumHighlighted = NO;
    highLightedI = 0;
    highLightedJ = 0;
    [self reDraw];
    NSSet* alltouches = [event allTouches];
    UITouch* touch = [[alltouches allObjects] objectAtIndex:0];
    CGPoint touchLoc = [touch locationInView:self];
    NSInteger savedX, savedY;
    if (cellChosen) {
        savedX = cellChosenX;
        savedY = cellChosenY;
    } else {
        savedX = 0;
        savedY = 0;
    }
    if (touchLoc.x < (arrLength)*[getItemCountInRow doubleValue]) {
        cellChosenX = 0;
        cellChosenY = 0;
        for (NSInteger i = 0; i < arrLength; i++) {
            if (((touchLoc.x > (i*[getItemCountInRow doubleValue])) && (touchLoc.x < ((i+1)*[getItemCountInRow doubleValue])))) {
                cellChosenX = i;
                break;
            }
        }
        for (NSInteger i = 0; i < arrLength; i++) {
            if ((touchLoc.y > (i*[getItemCountInRow doubleValue])) && (touchLoc.y < ((i+1)*[getItemCountInRow doubleValue]))) {
                cellChosenY = i;
                if ((cellChosenX > 0) && ([[arrGenerated objectAtIndex:(cellChosenY*arrLength+cellChosenX)]bType] == ValBrick)) {
                    cellChosen = YES;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"cellChosen" object:nil];
                    [self reDraw];
                } else {
                    NSInteger nsX = cellChosenX, nsY = cellChosenY;
                    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:3], @"cellY", [NSNumber numberWithInteger:1], @"cellX", nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"numberToCell" object:nil userInfo:dict];
                    if ([[arrGenerated objectAtIndex:(nsY*arrLength+nsX)]bType] == SumBrick) {
                        if ([[arrGenerated objectAtIndex:(nsY*arrLength+nsX)]horiz] > 0) {
                            if (touchLoc.y > nsY*[getItemCountInRow doubleValue] && touchLoc.x < (nsX+1)*[getItemCountInRow doubleValue]) {
                                NSInteger m = nsY*[getItemCountInRow doubleValue];
                                for (NSInteger n = nsX*[getItemCountInRow doubleValue]; n < (nsX + 1)*[getItemCountInRow doubleValue]; n++) {
                                    if (touchLoc.x > n && touchLoc.y == m) {
                                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:((Brick*)([arrGenerated objectAtIndex:(nsY*arrLength+nsX)])).Horizontal], @"cellSum", [NSNumber numberWithInteger:((Brick*)([arrGenerated objectAtIndex:(nsY*arrLength+nsX)])).countHorizontal], @"cellCount", nil];
                                        [[NSNotificationCenter defaultCenter]postNotificationName:@"sumChosen" object:nil userInfo:dict];
                                        return;
                                    }
                                    m++;
                                }
                            }
                        }
                        if ([[arrGenerated objectAtIndex:(nsY*arrLength+nsX)]vert] > 0) {
                            if (touchLoc.y < (nsY+1)*[getItemCountInRow doubleValue] && touchLoc.x > nsX*[getItemCountInRow doubleValue]) {
                                NSInteger m = nsY*[getItemCountInRow doubleValue];
                                for (NSInteger n = nsX*[getItemCountInRow doubleValue]; n < (nsX + 1)*[getItemCountInRow doubleValue]; n++) {
                                    if (touchLoc.x == n && touchLoc.y > m) {
                                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:((Brick*)([arrGenerated objectAtIndex:(nsY*arrLength+nsX)])).Vertical], @"cellSum", [NSNumber numberWithInteger:((Brick*)([arrGenerated objectAtIndex:(nsY*arrLength+nsX)])).countSpacesVert], @"cellCount", nil];
                                        [[NSNotificationCenter defaultCenter]postNotificationName:@"sumChosen" object:nil userInfo:dict];
                                        return;
                                    }
                                    m++;
                                }
                            }
                        }
                    }
                    cellChosenX = 0;
                    cellChosenY = 0;
                }
                break;
            }
        }
        if ((cellChosenX == savedX) && (cellChosenY == savedY)) {
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:3], @"cellY", [NSNumber numberWithInteger:1], @"cellX", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"numberToCell" object:nil userInfo:dict];
        }
    }
}

@end
