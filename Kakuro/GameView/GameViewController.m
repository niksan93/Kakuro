//
//  GameViewController.m
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 15.11.12.
//  Copyright (c) 2012 Alexandr Nikanorov. All rights reserved.
//

#import "GameViewController.h"
#import "SaveViewController.h"
#import "LoadViewController.h"
#import "Brick.h"
#import "DrawField.h"
#import "ControlView.h"
#include <QuartzCore/QuartzCore.h>

@interface GameViewController ()

@end

@implementation GameViewController
@synthesize pGenerator;
@synthesize viewDraw;
@synthesize viewControl;
@synthesize lblDim;
@synthesize definesPresentationContext;
@synthesize length;
@synthesize prevValue;
@synthesize Difficulty;

static double threadSafe = 0.0;
static double interval = 0.0;

#pragma mark initialization

//initialization method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCellValueNotification:) name:@"numberToCell" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCellChosenNotification:) name:@"cellChosen" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSumChosenNotification:) name:@"sumChosen" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadingNotification:) name:@"loadGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadingCreatedNotification:) name:@"loadCreatedGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveResumeNotification:) name:@"resumeGame" object:nil];
    }
    return self;
}

#pragma mark Notifications
//Методы центра уведомлений

//Продолжает игру
-(void) receiveResumeNotification:(NSNotification*) notification {
    [self menuButtonContinue:nil];
}
//Метод получает уведомление о том, что нужно загружается созданное только что пользователем поле
- (void) receiveLoadingCreatedNotification:(NSNotification *) notification {
    viewPause.hidden = YES;
    viewControl.userInteractionEnabled = YES;
    viewDraw.userInteractionEnabled = YES;
    btnHideSumsHelp.enabled = YES;
    btnRefresh.enabled = YES;
    interval = 0.0;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentFolder = [paths objectAtIndex:0];
    NSMutableArray* arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"created_array"]];
    NSInteger len = sqrt([[NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"created_array"]] count]);
    [((DrawField*)viewDraw).arrGenerated removeAllObjects];
    ((DrawField*)viewDraw).arrGenerated = arr;
    ((DrawField*)viewDraw).arrLength = len;
    ((DrawField*)viewDraw).getItemCountInRow= [NSNumber numberWithDouble:((DrawField*)viewDraw).frame.size.width/len];
    ((DrawField*)viewDraw).cellChosenY = 0;
    ((DrawField*)viewDraw).cellChosenX = 0;
    ((DrawField*)viewDraw).cellChosen = NO;
    lblDim.text = [NSString stringWithFormat:@"%ld:%ld", (long)len, (long)len];
    dispatch_queue_t timerQueue = dispatch_queue_create("timing", NULL);
    threadSafe += 0.1;
    @synchronized(self) {
        dispatch_async(timerQueue, ^{
            start = [NSDate date];
            double a1 = 0;
            a1 = threadSafe;
            while (a1 == threadSafe) {
                timeInterval = [start timeIntervalSinceNow];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTimeInterval real = timeInterval + interval;
                    NSLog(@"%@", [NSString stringWithFormat:@"Time: %ld:%ld min", (long)((NSInteger)-real)/60, (long)((NSInteger)-real)%60]);
                    lblTimer.text = [NSString stringWithFormat:@"Time: %ld:%ld min", (long)((NSInteger)-real)/60, (long)((NSInteger)-real)%60];
                });
                [NSThread sleepForTimeInterval:1];
            }
        });
    }
    dispatch_release(timerQueue);
    [((DrawField*)viewDraw) reDraw];
    btnPause.enabled = YES;
}
//Метод получает уведомление о том, что нужно загрузить одну из сохраненных игр
- (void) receiveLoadingNotification:(NSNotification *) notification {
    viewPause.hidden = YES;
    viewControl.userInteractionEnabled = YES;
    viewDraw.userInteractionEnabled = YES;
    btnHideSumsHelp.enabled = YES;
    btnRefresh.enabled = YES;
    NSDictionary* dict = notification.userInfo;
    NSDictionary* dictio = [dict objectForKey:@"dict"];
    txtView.text = @"";
    txtView.hidden = YES;
    btnHideSumsHelp.hidden = YES;
    interval = [[dictio objectForKey:@"timeInterval"]doubleValue];
    NSMutableArray* arr = nil;
    Difficulty = [[dictio objectForKey:@"difficulty"]integerValue];
    switch (Difficulty) {
        case 1:
            lblDifficulty.text = @"Easy";
            break;
        case 2:
            lblDifficulty.text = @"Medium";
            break;
        case 3:
            lblDifficulty.text = @"Hard";
            break;
        case 4:
            lblDifficulty.text = @"Insane";
            break;
        default:
            lblDifficulty.text = @"Created";
            break;
    }
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentFolder = [paths objectAtIndex:0];
    NSInteger len = 0;
    switch ([[dict objectForKey:@"array"]integerValue]) {
        case 1:
             arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"array1"]];
            len = sqrt([[NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"array1"]]count]);
            break;
        case 2:
            arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"array2"]];
            len = sqrt([[NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"array2"]]count]);
            break;
        case 3:
            arr = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"array3"]];
            len = sqrt([[NSKeyedUnarchiver unarchiveObjectWithFile:[documentFolder stringByAppendingPathComponent:@"array3"]]count]);
            break;
        default:
            break;
    }
    [((DrawField*)viewDraw).arrGenerated removeAllObjects];
    ((DrawField*)viewDraw).arrGenerated = arr;
    ((DrawField*)viewDraw).arrLength = len;
    ((DrawField*)viewDraw).getItemCountInRow= [NSNumber numberWithDouble:((DrawField*)viewDraw).frame.size.width/len];
    ((DrawField*)viewDraw).cellChosenY = 0;
    ((DrawField*)viewDraw).cellChosenX = 0;
    ((DrawField*)viewDraw).cellChosen = NO;
    lblDim.text = [NSString stringWithFormat:@"%ld:%ld", (long)len, (long)len];
    dispatch_queue_t timerQueue = dispatch_queue_create("timing", NULL);
    threadSafe += 0.1;
    @synchronized(self) {
        dispatch_async(timerQueue, ^{
            start = [NSDate date];
            double a1 = 0;
            a1 = threadSafe;
            while (a1 == threadSafe) {
                timeInterval = [start timeIntervalSinceNow];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTimeInterval real = timeInterval + interval;
                    NSString* hours = @"";
                    NSString* minutes = @"";
                    NSString* seconds = @"";
                    if ((long)((NSInteger)-real)/60 >= 60) {
                        if (((long)((NSInteger)-real)/60)/60 < 10)
                            hours = [NSString stringWithFormat:@"0%ld", ((long)((NSInteger)-real)/60)/60];
                        else
                            hours = [NSString stringWithFormat:@"%ld", ((long)((NSInteger)-real)/60)/60];
                    }
                    if ((long)((NSInteger)-real)/60 < 10)
                        minutes = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-real)/60];
                    else
                        minutes = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-real)/60];
                    if ((long)((NSInteger)-real)%60 < 10)
                        seconds = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-real)%60];
                    else
                        seconds = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-real)%60];
                    if ((long)((NSInteger)-real)/60 >= 60)
                        lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@:%@", hours, minutes, seconds];
                    else
                        lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@", minutes, seconds];
                });
                [NSThread sleepForTimeInterval:1];
            }
        });
    }
    dispatch_release(timerQueue);
    [((DrawField*)viewDraw) reDraw];
    btnPause.enabled = YES;
    if ([self checkIfPuzzleIsFilled]) {
        if ([self checkIfPuzzleIsSolved]) {
            for (NSInteger i = 1; i < length; i++) {
                for (NSInteger j = 1; j < length; j++) {
                    ((DrawField*)viewDraw).cellChosenY = i;
                    ((DrawField*)viewDraw).cellChosenX = j;
                    checkSim = NO;
                    [self checkForHorizontalSimilarities:[[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank]];
                    if (checkSim)
                        return;
                    [self checkForVerticalSimilarities:[[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank]];
                    if (checkSim)
                        return;
                }
            }
            threadSafe += 0.1;
            lblStatus.text = @"Solved";
        }
    }
}
//Метод получает уведомление о том, что пользователь выбрал клетку, и отображает цифровой контроллер
//проверяет, решено ли поля (задача)
- (void) receiveCellChosenNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"cellChosen"]) {
        ((ControlView*)viewControl).hidden = NO;
    }
}
//Метод получает уведомление о том, что пользователь выбрали цифру для клетки, и записывает 
- (void) receiveCellValueNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"numberToCell"]) {
        NSDictionary* dict = notification.userInfo;
        NSInteger yCoord = [[dict objectForKey:@"cellY"]integerValue];
        NSInteger xCoord = [[dict objectForKey:@"cellX"]integerValue];
        if (((DrawField*)viewDraw).cellChosen) {
            if (yCoord < 3) {
                NSInteger value = xCoord+yCoord*3;
                prevValue = [[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank];
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = NO;
                if ([self checkForHorizontalSum:value] && [self checkForVerticalSum:value] && [self checkForHorizontalSimilarities:value] && [self checkForVerticalSimilarities:value]) {
                    BOOL check = [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]marked];
                    Brick* br = [[Brick alloc]initWithVertical:0 Horizontal:0 countHorizontal:0 countVertical:0 Type:ValBrick Value:value];
                    if (check) {
                        br.marked = YES;
                    }
                    [((DrawField*)viewDraw).arrGenerated  replaceObjectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX) withObject:br];
                    [br release];
                    [self checkForHorizontalSum:value];
                    [self checkForVerticalSum:value];
                }
            }
            if ((yCoord == 3) && (xCoord == 2)) {
                prevValue = [[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank];
                [self checkForHorizontalSimilarities:0];
                [self checkForVerticalSimilarities:0];
                Brick* br = [[Brick alloc]initWithVertical:0 Horizontal:0 countHorizontal:0 countVertical:0 Type:ValBrick Value:0];
                [((DrawField*)viewDraw).arrGenerated  replaceObjectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX) withObject:br];
                [br release];
                [self checkForHorizontalSum:0];
                [self checkForVerticalSum:0];
            }
            ((DrawField*)viewDraw).cellChosenY = 0;
            ((DrawField*)viewDraw).cellChosenX = 0;
            ((DrawField*)viewDraw).cellChosen = NO;
            ((ControlView*)viewControl).hidden = YES;
            [((DrawField*)viewDraw) reDraw];
            if ([self checkIfPuzzleIsFilled]) {
                if ([self checkIfPuzzleIsSolved]) {
                    for (NSInteger i = 1; i < length; i++) {
                        for (NSInteger j = 1; j < length; j++) {
                            ((DrawField*)viewDraw).cellChosenY = i;
                            ((DrawField*)viewDraw).cellChosenX = j;
                            checkSim = NO;
                            [self checkForHorizontalSimilarities:[[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank]];
                            if (checkSim)
                                return;
                            [self checkForVerticalSimilarities:[[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank]];
                            if (checkSim)
                                return;
                        }
                    }
                    threadSafe += 0.1;
                    /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You have solved the puzzle in %ld:%ld min!", (long)((NSInteger)-timeInterval)/60, (long)((NSInteger)-timeInterval)%60] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];*/
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You have solved the puzzle in %ld:%ld min!", (long)((NSInteger)-timeInterval)/60, (long)((NSInteger)-timeInterval)%60] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    lblStatus.text = @"Solved";
                    threadSafe += 0.1;
                    interval = timeInterval + interval;
                }
            }
        }
    }
}
//Метод получает уведомление о том, что нужно вывести подсказку по слагаемым для выбранной пользователем суммы
- (void) receiveSumChosenNotification:(NSNotification *) notification {
    NSDictionary* dict = notification.userInfo;
    NSInteger cellSum = [[dict objectForKey:@"cellSum"]integerValue];
    NSInteger cellCount = [[dict objectForKey:@"cellCount"]integerValue];
    NSMutableArray* arr = [self partitioningIntoSummandsCellSumL:cellSum cellCount:cellCount];
    NSMutableString* str = [NSMutableString stringWithFormat:@"Summands for number: %ld\n for %ld cells:\n", (long)cellSum, (long)cellCount];
    NSMutableArray* array;
    for (NSInteger i = 0; i < [arr count]; i++) {
        array = [arr objectAtIndex:i];
        [str appendString:@" "];
        for (NSInteger j = 0; j < cellCount; j++) {
            [str appendFormat:@"%ld ", (long)[[array objectAtIndex:j]integerValue]];
        }
        [str appendFormat:@";\n"];
    }
    NSString* st = str;
    txtView.text = st;
    txtView.hidden = NO;
    btnHideSumsHelp.hidden = NO;
}
//метод разбиения числа на определенное количество слагаемых
-(NSMutableArray*)partitioningIntoSummandsCellSumL:(NSInteger)cellSum cellCount:(NSInteger)cellCount {
    NSMutableArray* arr = [[[NSMutableArray alloc]init]autorelease];
    NSMutableArray* contArr = [[NSMutableArray alloc]init];
    NSInteger sum = 0, ii = 1;
    for (NSInteger i = 0; i < cellCount; i++) {
        for (NSInteger j = ii; j <= 9; j++) {
            sum += j;
            if (sum == cellSum && i == cellCount -1) {
                [contArr addObject:[NSNumber numberWithInteger:j]];
                [arr addObject:contArr];
                [contArr release];
                contArr = [[NSMutableArray alloc]init];
                NSMutableArray* supArr = [arr objectAtIndex:[arr count] - 1];
                for (NSInteger n = 0; n < [supArr count] - 1; n++) {
                    [contArr addObject:[supArr objectAtIndex:n]];
                 }
                if (j != 9) {
                    i--;
                    ii = [[supArr objectAtIndex:[supArr count]-1]integerValue] + 1;
                    sum -= [[supArr objectAtIndex:[supArr count]-1]integerValue];
                } else {
                    i -= 2;
                    ii = [[supArr objectAtIndex:[supArr count]-2]integerValue] + 1;
                    sum -= [[supArr objectAtIndex:[supArr count]-1]integerValue];
                    sum -= [[supArr objectAtIndex:[supArr count]-2]integerValue];
                    [contArr removeObjectAtIndex:[contArr count] - 1];
                }
                break;
            }
            if (sum >= cellSum) {
                if (i == 0) {
                    if (contArr != nil) {
                        [contArr release];
                    }
                    return arr;
                }
                if (j == 9) {
                    ii = [[contArr objectAtIndex:[contArr count] - 1]integerValue] + 1;
                    sum -= j;
                    sum -= [[contArr objectAtIndex:[contArr count] - 1]integerValue];
                    [contArr removeObjectAtIndex:[contArr count] - 1];
                    i -= 2;
                    break;
                }
                sum -= j;
                ii = j + 1;
                i--;
                break;
            }
            if (sum < cellSum && j == 9) {
                if (i == 0) {
                    if (contArr != nil) {
                        [contArr release];
                    }
                    return arr;
                }
                ii = [[contArr objectAtIndex:[contArr count] - 1]integerValue] + 1;
                sum -= j;
                sum -= [[contArr objectAtIndex:[contArr count] - 1]integerValue];
                [contArr removeObjectAtIndex:[contArr count] - 1];
                i -= 2;
                break;
            }
            if (sum < cellSum && j < 9 && i == cellCount - 1) {
                sum -= j;
            }
            if (sum < cellSum &&  i < cellCount - 1) {
                [contArr addObject:[NSNumber numberWithInteger:j]];
                ii = j + 1;
                break;
            }
        }
    }
    if (contArr != nil) {
        [contArr release];
    }
    return arr;
}

#pragma mark UIAlertController methods

-(void)refreshGameThroughAlert {
    threadSafe += 0.1;
    [((DrawField*)viewDraw) releasePuzzle];
    [pGenerator release];
    ((ControlView*)viewControl).hidden = YES;
    [((DrawField*)viewDraw) reDraw];
    
    lblGenerate.hidden = NO;
    lblDim.hidden = YES;
    UIActivityIndicatorView* activ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activ.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 24, 24);
    [self.view addSubview:activ];
    activ.hidesWhenStopped = YES;
    [activ startAnimating];
    btnRefresh.enabled = NO;
    dispatch_queue_t downloadQueue = dispatch_queue_create("creating", NULL);
    dispatch_async(downloadQueue, ^{
        // do our long running process here
        pGenerator = [[PuzzleGenerator alloc]initWithLength:length*length];
        pGenerator.Difficulty = Difficulty;
        ((DrawField*)viewDraw).arrGenerated = [pGenerator generate];
        ((DrawField*)viewDraw).cellChosenY = 0;
        ((DrawField*)viewDraw).cellChosenX = 0;
        ((DrawField*)viewDraw).cellChosen = NO;
        for (NSInteger i = 0; i < [((DrawField*)viewDraw).arrGenerated count]; i++) {
            if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i]bType] == ValBrick) {
                Brick* br = [[Brick alloc]initWithVertical:0 Horizontal:0 countHorizontal:0 countVertical:0 Type:ValBrick Value:0];
                [((DrawField*)viewDraw).arrGenerated replaceObjectAtIndex:i withObject:br];
                [br release];
            }
        }
        ((DrawField*)viewDraw).arrLength = length;
        ((DrawField*)viewDraw).getItemCountInRow= [NSNumber numberWithDouble:((DrawField*)viewDraw).frame.size.width/length];
        scrollView = (UIScrollView*)[self.view viewWithTag:3];
        scrollView.delegate = self;
        [((DrawField*)viewDraw) reDraw];
        
        dispatch_queue_t timerQueue = dispatch_queue_create("timing", NULL);
        dispatch_async(timerQueue, ^{
            start = [NSDate date];
            double a1 = 0;
            a1 = threadSafe;
            while (a1 == threadSafe) {
                timeInterval = [start timeIntervalSinceNow];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* hours = @"";
                    NSString* minutes = @"";
                    NSString* seconds = @"";
                    if ((long)((NSInteger)-timeInterval)/60 >= 60) {
                        if (((long)((NSInteger)-timeInterval)/60)/60 < 10)
                            hours = [NSString stringWithFormat:@"0%ld", ((long)((NSInteger)-timeInterval)/60)/60];
                        else
                            hours = [NSString stringWithFormat:@"%ld", ((long)((NSInteger)-timeInterval)/60)/60];
                    }
                    if ((long)((NSInteger)-timeInterval)/60 < 10)
                        minutes = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-timeInterval)/60];
                    else
                        minutes = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-timeInterval)/60];
                    if ((long)((NSInteger)-timeInterval)%60 < 10)
                        seconds = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-timeInterval)%60];
                    else
                        seconds = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-timeInterval)%60];
                    if ((long)((NSInteger)-timeInterval)/60 >= 60)
                        lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@:%@", hours, minutes, seconds];
                    else
                        lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@", minutes, seconds];
                });
                [NSThread sleepForTimeInterval:1];
            }
        });
        dispatch_release(timerQueue);
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            lblDim.text = [NSString stringWithFormat:@"%ld:%ld", (long)length, (long)length];
            [activ stopAnimating];
            btnRefresh.enabled = YES;
            lblGenerate.hidden = YES;
            lblDim.hidden = NO;
        });
        
    });
    dispatch_release(downloadQueue);
}

#pragma mark UIAlertViewDelegate
//метод делегата UIAlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            threadSafe += 0.1;
            [((DrawField*)viewDraw) releasePuzzle];
            [pGenerator release];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            threadSafe += 0.1;
            [((DrawField*)viewDraw) releasePuzzle];
            [pGenerator release];
            ((ControlView*)viewControl).hidden = YES;
            [((DrawField*)viewDraw) reDraw];
            
            lblGenerate.hidden = NO;
            lblDim.hidden = YES;
            UIActivityIndicatorView* activ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activ.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 24, 24);
            [self.view addSubview:activ];
            activ.hidesWhenStopped = YES;
            [activ startAnimating];
            btnRefresh.enabled = NO;
            dispatch_queue_t downloadQueue = dispatch_queue_create("creating", NULL);
            dispatch_async(downloadQueue, ^{
                // do our long running process here
                pGenerator = [[PuzzleGenerator alloc]initWithLength:length*length];
                pGenerator.Difficulty = Difficulty;
                ((DrawField*)viewDraw).arrGenerated = [pGenerator generate];
                ((DrawField*)viewDraw).cellChosenY = 0;
                ((DrawField*)viewDraw).cellChosenX = 0;
                ((DrawField*)viewDraw).cellChosen = NO;
                for (NSInteger i = 0; i < [((DrawField*)viewDraw).arrGenerated count]; i++) {
                    if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i]bType] == ValBrick) {
                        Brick* br = [[Brick alloc]initWithVertical:0 Horizontal:0 countHorizontal:0 countVertical:0 Type:ValBrick Value:0];
                        [((DrawField*)viewDraw).arrGenerated replaceObjectAtIndex:i withObject:br];
                        [br release];
                    }
                }
                ((DrawField*)viewDraw).arrLength = length;
                ((DrawField*)viewDraw).getItemCountInRow= [NSNumber numberWithDouble:((DrawField*)viewDraw).frame.size.width/length];
                scrollView = (UIScrollView*)[self.view viewWithTag:3];
                scrollView.delegate = self;
                [((DrawField*)viewDraw) reDraw];
                
                dispatch_queue_t timerQueue = dispatch_queue_create("timing", NULL);
                dispatch_async(timerQueue, ^{
                    start = [NSDate date];
                    double a1 = 0;
                    a1 = threadSafe;
                    while (a1 == threadSafe) {
                        timeInterval = [start timeIntervalSinceNow];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString* hours = @"";
                            NSString* minutes = @"";
                            NSString* seconds = @"";
                            if ((long)((NSInteger)-timeInterval)/60 >= 60) {
                                if (((long)((NSInteger)-timeInterval)/60)/60 < 10)
                                    hours = [NSString stringWithFormat:@"0%ld", ((long)((NSInteger)-timeInterval)/60)/60];
                                else
                                    hours = [NSString stringWithFormat:@"%ld", ((long)((NSInteger)-timeInterval)/60)/60];
                            }
                            if ((long)((NSInteger)-timeInterval)/60 < 10)
                                minutes = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-timeInterval)/60];
                            else
                                minutes = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-timeInterval)/60];
                            if ((long)((NSInteger)-timeInterval)%60 < 10)
                                seconds = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-timeInterval)%60];
                            else
                                seconds = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-timeInterval)%60];
                            if ((long)((NSInteger)-timeInterval)/60 >= 60)
                                lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@:%@", hours, minutes, seconds];
                            else
                                lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@", minutes, seconds];
                        });
                        [NSThread sleepForTimeInterval:1];
                    }
                });
                dispatch_release(timerQueue);
                
                // do any UI stuff on the main UI thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    lblDim.text = [NSString stringWithFormat:@"%ld:%ld", (long)length, (long)length];
                    [activ stopAnimating];
                    btnRefresh.enabled = YES;
                    lblGenerate.hidden = YES;
                    lblDim.hidden = NO;
                });
                
            });
            dispatch_release(downloadQueue);
        }
    }
}

#pragma mark button methods
//методы кнопок
//метод кнопки показывает меню паузы
- (IBAction)btnShowMenu:(UIButton *)sender {
    //viewPause.hidden = NO;
    viewControl.userInteractionEnabled = NO;
    viewDraw.userInteractionEnabled = NO;
    btnHideSumsHelp.enabled = NO;
    btnRefresh.enabled = NO;
    threadSafe += 0.1;
    interval = timeInterval + interval;
    btnPause.enabled = NO;
    
    UIAlertController* menu = [UIAlertController alertControllerWithTitle:@"Pause" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:@"Resume" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self menuButtonContinue:nil];}];
    [menu addAction:alertAction];
    alertAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self menuButtonSave:nil];}];
    [menu addAction:alertAction];
    alertAction = [UIAlertAction actionWithTitle:@"Load" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self menuButtonLoad:nil];}];
    [menu addAction:alertAction];
    alertAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self menuButtonExit:nil];}];
    [menu addAction:alertAction];
    [self presentViewController:menu animated:YES completion:nil];
}
//метод кнопки генерации нового игрового поля
- (IBAction)refreshPuzzle:(UIButton *)sender {
    /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Are you sure you want to generate a new puzzle?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    alert.tag = 2;
    [alert release];*/
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Are you sure you want to generate a new puzzle?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction* act) {
        [self refreshGameThroughAlert];
    }];
    [alert addAction:action];
    action = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction* act) {}];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
//метод кнопки скрывает подсказку по слагаемым
- (IBAction)hideSumsHelp:(UIButton *)sender {
    txtView.hidden = YES;
    btnHideSumsHelp.hidden = YES;
}
//метод кнопки меню паузы, продолжает игру
- (IBAction)menuButtonContinue:(UIButton *)sender {
    btnPause.enabled = YES;
    viewPause.hidden = YES;
    viewControl.userInteractionEnabled = YES;
    viewDraw.userInteractionEnabled = YES;
    btnHideSumsHelp.enabled = YES;
    btnRefresh.enabled = YES;
    dispatch_queue_t timerQueue = dispatch_queue_create("timing", NULL);
    @synchronized(self) {
        dispatch_async(timerQueue, ^{
            start = [NSDate date];
            double a1 = 0;
            a1 = threadSafe;
            while (a1 == threadSafe) {
                timeInterval = [start timeIntervalSinceNow];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSTimeInterval real = timeInterval + interval;
                    NSString* hours = @"";
                    NSString* minutes = @"";
                    NSString* seconds = @"";
                    if ((long)((NSInteger)-real)/60 >= 60) {
                        if (((long)((NSInteger)-real)/60)/60 < 10)
                            hours = [NSString stringWithFormat:@"0%ld", ((long)((NSInteger)-real)/60)/60];
                        else
                            hours = [NSString stringWithFormat:@"%ld", ((long)((NSInteger)-real)/60)/60];
                    }
                    if ((long)((NSInteger)-real)/60 < 10)
                        minutes = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-real)/60];
                    else
                        minutes = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-real)/60];
                    if ((long)((NSInteger)-real)%60 < 10)
                        seconds = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-real)%60];
                    else
                        seconds = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-real)%60];
                    if ((long)((NSInteger)-real)/60 >= 60)
                        lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@:%@", hours, minutes, seconds];
                    else
                        lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@", minutes, seconds];

                });
                [NSThread sleepForTimeInterval:1];
            }
        });
    }
    dispatch_release(timerQueue);
}
//метод кнопки меню паузы, открывает экран сохранения
- (IBAction)menuButtonSave:(UIButton *)sender {
    CGRect rect = [viewDraw bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [viewDraw.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    double dd = interval;
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:dd], @"timeInterval", [NSDate date], @"date", [NSNumber numberWithInteger:Difficulty], @"difficulty", nil];
    SaveViewController* sViewController = [[SaveViewController alloc]initWithImage:capturedImage dictionary:dict array:((DrawField*)viewDraw).arrGenerated popToRoot:NO];
    [self.navigationController pushViewController:sViewController animated:YES];
    [sViewController release];
}
//метод кнопки меню паузы, открывает экран загрузки
- (IBAction)menuButtonLoad:(UIButton *)sender {
    LoadViewController* lViewController = [[LoadViewController alloc]initFromGame:YES];
    [self.navigationController pushViewController:lViewController animated:YES];
    [lViewController release];
}
//метод кнопки меню паузы, выходит в главное меню
- (IBAction)menuButtonExit:(UIButton *)sender {
    /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Are you sure you want to exit game?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    alert.tag = 1;
    [alert release];*/
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Are you sure you want to stop solving this puzzle?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction* act) {
        [self menuButtonContinue:nil];
    }];
    [alert addAction:action];
    action = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction* act) {
        threadSafe += 0.1;
        [((DrawField*)viewDraw) releasePuzzle];
        [pGenerator release];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark view methods
//вызывается при загрузки изображения (перед выполнения функций в метод инициализации)
//задает данные для новой игры, генерирует поле
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"img.png"]]];
    lblTimer = (UILabel*)[self.view viewWithTag:7];
    lblGenerate = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-65, self.view.frame.size.height/2-60, 170, 100)];
    lblGenerate.text = @"Generating puzzle...";
    lblGenerate.hidden = YES;
    [self.view addSubview:lblGenerate];
    lblDim = (UILabel*)[self.view viewWithTag:5];
    lblDifficulty = (UILabel*)[self.view viewWithTag:25];
    btnRefresh = (UIButton*)[self.view viewWithTag:6];
    txtView = (UITextView*)[self.view viewWithTag:30];
    btnHideSumsHelp = (UIButton*)[self.view viewWithTag:31];
    txtView.hidden = YES;
    btnHideSumsHelp.hidden = YES;
    viewDraw = (UIView*)[self.view viewWithTag:2];
    viewControl = (UIView*)[self.view viewWithTag:4];
    viewPause = (UIView*)[self.view viewWithTag:32];
    btnPause = (UIButton*)[self.view viewWithTag:60];
    lblStatus = (UILabel*)[self.view viewWithTag:61];
    [viewPause setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"img.png"]]];
    viewPause.hidden = YES;
    switch (Difficulty) {
        case 1:
            lblDifficulty.text = @"Easy";
            break;
        case 2:
            lblDifficulty.text = @"Medium";
            break;
        case 3:
            lblDifficulty.text = @"Hard";
            break;
        case 4:
            lblDifficulty.text = @"Insane";
            break;
        default:
            lblDifficulty.text = @"Created";
            break;
    }
    if (Difficulty != 0) {
        lblGenerate.hidden = NO;
        lblDim.hidden = YES;
        UIActivityIndicatorView* activ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activ.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 24, 24);
        [self.view addSubview:activ];
        activ.hidesWhenStopped = YES;
        [activ startAnimating];
        btnRefresh.enabled = NO;
        dispatch_queue_t downloadQueue = dispatch_queue_create("creating", NULL);
        dispatch_async(downloadQueue, ^{
            
            // do our long running process here
            pGenerator = [[PuzzleGenerator alloc]initWithLength:length*length];
            pGenerator.Difficulty = Difficulty;
            ((DrawField*)viewDraw).arrGenerated = [pGenerator generate];
            ((DrawField*)viewDraw).cellChosenY = 0;
            ((DrawField*)viewDraw).cellChosenX = 0;
            ((DrawField*)viewDraw).cellChosen = NO;
            NSInteger arrCount = [((DrawField*)viewDraw).arrGenerated count];
            for (NSInteger i = 0; i < arrCount; i++) {
                if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i]bType] == ValBrick) {
                    Brick* br = [[Brick alloc]initWithVertical:0 Horizontal:0 countHorizontal:0 countVertical:0 Type:ValBrick Value:0];
                    [((DrawField*)viewDraw).arrGenerated replaceObjectAtIndex:i withObject:br];
                    [br release];
                }
            }
            ((DrawField*)viewDraw).arrLength = length;
            ((DrawField*)viewDraw).getItemCountInRow= [NSNumber numberWithDouble:((DrawField*)viewDraw).frame.size.width/length];
            lblDim.text = [NSString stringWithFormat:@"%ld:%ld", (long)length, (long)length];
            scrollView = (UIScrollView*)[self.view viewWithTag:3];
            scrollView.delegate = self;
            [((DrawField*)viewDraw) reDraw];
            
            dispatch_queue_t timerQueue = dispatch_queue_create("timing", NULL);
            dispatch_async(timerQueue, ^{
                start = [NSDate date];
                double a1 = 0;
                a1 = threadSafe;
                while (a1 == threadSafe) {
                    timeInterval = [start timeIntervalSinceNow];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString* hours = @"";
                        NSString* minutes = @"";
                        NSString* seconds = @"";
                        if ((long)((NSInteger)-timeInterval)/60 >= 60) {
                            if (((long)((NSInteger)-timeInterval)/60)/60 < 10)
                                hours = [NSString stringWithFormat:@"0%ld", ((long)((NSInteger)-timeInterval)/60)/60];
                            else
                                hours = [NSString stringWithFormat:@"%ld", ((long)((NSInteger)-timeInterval)/60)/60];
                        }
                        if ((long)((NSInteger)-timeInterval)/60 < 10)
                            minutes = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-timeInterval)/60];
                        else
                            minutes = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-timeInterval)/60];
                        if ((long)((NSInteger)-timeInterval)%60 < 10)
                            seconds = [NSString stringWithFormat:@"0%ld", (long)((NSInteger)-timeInterval)%60];
                        else
                            seconds = [NSString stringWithFormat:@"%ld", (long)((NSInteger)-timeInterval)%60];
                        if ((long)((NSInteger)-timeInterval)/60 >= 60)
                            lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@:%@", hours, minutes, seconds];
                        else
                            lblTimer.text = [NSString stringWithFormat:@"Time: %@:%@", minutes, seconds];
                    });
                    [NSThread sleepForTimeInterval:1];
                }
            });
            dispatch_release(timerQueue);
            
            // do any UI stuff on the main UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [activ stopAnimating];
                btnRefresh.enabled = YES;
                lblGenerate.hidden = YES;
                lblDim.hidden = NO;
            });
            
        });
        dispatch_release(downloadQueue);
        lblDim.text = [NSString stringWithFormat:@"%ld:%ld", (long)length, (long)length];
        scrollView = (UIScrollView*)[self.view viewWithTag:3];
        scrollView.delegate = self;
        [self performSelector:@selector(adjustViewContent) withObject:nil afterDelay:0.1];
    }
}
//приводит размер контента scrollview к размерами view игровго поля
-(void)adjustViewContent {
    scrollView.contentSize = viewDraw.frame.size;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

/*-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"numberToCell" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cellChosen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sumChosen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadGame" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadCreatedGame" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resumeGame" object:nil];
}*/

#pragma mark checking methods
//метод проверки, заполнено ли игровое поле
-(BOOL)checkIfPuzzleIsFilled {
    for (NSInteger i = 1; i < length; i++) {
        for (NSInteger j = 1; j < length; j++) {
            if (([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]bType] == ValBrick) && ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]valueBlank] == 0)) {
                return NO;
            }
        }
    }
    return YES;
}
//метод проверки, решено ли поле (задача)
-(BOOL)checkIfPuzzleIsSolved {
    for (NSInteger i = 0; i < length; i++) {
        for (NSInteger j = 0; j < length; j++) {
            if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]bType] == SumBrick) {
                if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]horiz] > 0) {
                    NSInteger sum = 0;
                    for (NSInteger n = j + 1; n < (j + 1 + [[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]countHorizontal]); n++) {
                        sum += [[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+n]valueBlank];
                    }
                    if (sum != [[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]horiz]) {
                        return NO;
                    }
                }
                if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]vert] > 0) {
                    NSInteger sum = 0;
                    for (NSInteger n = i + 1; n < (i + 1 + [[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]countVertical]); n++) {
                        sum += [[((DrawField*)viewDraw).arrGenerated objectAtIndex:n*length+j]valueBlank];
                    }
                    if (sum != [[((DrawField*)viewDraw).arrGenerated objectAtIndex:i*length+j]vert]) {
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}
//метод проверки на совпадение суммы введенных пользователем цифр и заданной суммы в строке
-(BOOL)checkForHorizontalSum:(NSInteger)value {
    BOOL checkFilled = YES;
    for (NSInteger i = ((DrawField*)viewDraw).cellChosenX-1; i >=0; i--) {
        if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]bType] == SumBrick) {
            for (NSInteger j = i + 1; j < 1 + i + [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]countHorizontal]; j++) {
                if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+j)]valueBlank] == 0) {
                    checkFilled = NO;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).horizSumMarkedRed = NO;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).horizSumMarkedGreen = NO;
                    [((DrawField*)viewDraw) reDraw];
                    break;
                }
            }
            if (checkFilled) {
                NSInteger sum = 0;
                for (NSInteger j = i + 1; j < 1 + i + [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]countHorizontal]; j++) {
                    sum += [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+j)]valueBlank];
                }
                if (sum != [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]horiz]) {
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).horizSumMarkedRed = YES;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).horizSumMarkedGreen = NO;
                } else {
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).horizSumMarkedGreen = YES;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).horizSumMarkedRed = NO;
                }
                [((DrawField*)viewDraw) reDraw];
            }
            break;
        }
    }
    return YES;
}
//метод проверки на совпадение суммы введенных пользователем цифр и заданной суммы в столбце
-(BOOL)checkForVerticalSum:(NSInteger)value {
    BOOL checkFilled = YES;
    for (NSInteger i = ((DrawField*)viewDraw).cellChosenY-1; i >=0; i--) {
        if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]bType] == SumBrick) {
            for (NSInteger j = i + 1; j < 1 + i + [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]countVertical]; j++) {
                if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(j*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank] == 0) {
                    checkFilled = NO;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).vertSumMarkedRed = NO;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).vertSumMarkedGreen = NO;
                    [((DrawField*)viewDraw) reDraw];
                    break;
                }
            }
            if (checkFilled) {
                NSInteger sum = 0;
                for (NSInteger j = i + 1; j < 1 + i + [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]countVertical]; j++) {
                    sum += [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(j*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank];
                }
                if (sum != [[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]vert]) {
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).vertSumMarkedRed = YES;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).vertSumMarkedGreen = NO;
                } else {
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).vertSumMarkedGreen = YES;
                    ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).vertSumMarkedRed = NO;
                }
                [((DrawField*)viewDraw) reDraw];
            }
            break;
        }
    }
    return YES;
}
//метод проверки, есть ли между двумя нецифровыми клетками в строках повторяющиеся цифры, если так, то они отмечаются красной рамкой
-(BOOL)checkForHorizontalSimilarities:(NSInteger)value {
    NSInteger count = 0;
    NSInteger indX = 0;
    for (NSInteger i = ((DrawField*)viewDraw).cellChosenX-1; i >=0; i--) {
        if ([[((DrawField*)viewDraw).arrGenerated objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]bType] == SumBrick) {
            break;
        } else {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]valueBlank] == value) && (value != 0)) {
                NSLog(@"row %ld", (long)i);
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).marked = YES;
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = YES;
                checkSim = YES;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]valueBlank] == prevValue) {
                indX = i;
                count++;
            }
        }
    }
    for (NSInteger i = ((DrawField*)viewDraw).cellChosenX+1; i < ((DrawField*)viewDraw).arrLength; i++) {
        if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]bType] == SumBrick) || ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]bType] == BlankBrick)) {
            break;
        } else {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]valueBlank] == value) && (value != 0)) {
                NSLog(@"col %ld", (long)i);
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]).marked = YES;
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = YES;
                checkSim = YES;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+i)]valueBlank] == prevValue) {
                indX = i;
                count++;
            }
        }
    }
    if (count <= 1) {
        NSInteger count2 = 0;
        for (NSInteger i = ((DrawField*)viewDraw).cellChosenY - 1; i >=0; i--) {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+indX)]bType] == SumBrick) || ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+indX)]bType] == BlankBrick)) {
                break;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+indX)]valueBlank] == prevValue) {
                count2++;
            }
        }
        for (NSInteger i = ((DrawField*)viewDraw).cellChosenY + 1; i < length; i++) {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+indX)]bType] == SumBrick) || ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+indX)]bType] == BlankBrick)) {
                break;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+indX)]valueBlank] == prevValue) {
                count2++;
            }
        }
        if (count2 == 0) {
            ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+indX)]).marked = NO;
        }
    }
    return YES;
}
//метод проверки, есть ли между двумя нецифровыми клетками в столбцах повторяющиеся цифры, если так, то они отмечаются красной рамкой
-(BOOL)checkForVerticalSimilarities:(NSInteger)value {
    NSInteger count = 0;
    NSInteger indY = 0;
    for (NSInteger i = ((DrawField*)viewDraw).cellChosenY-1; i >=0; i--) {
        if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]bType] == SumBrick) {
            break;
        } else {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank] == value) && (value != 0)) {
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = YES;
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = YES;
                checkSim = YES;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank] == prevValue) {
                indY = i;
                count++;
            }
        }
    }
    for (NSInteger i = ((DrawField*)viewDraw).cellChosenY+1; i < ((DrawField*)viewDraw).arrLength; i++) {
        if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]bType] == SumBrick) || ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]bType] == BlankBrick)) {
            break;
        } else {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank] == value) && (value != 0)) {
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = YES;
                ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(((DrawField*)viewDraw).cellChosenY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = YES;
                checkSim = YES;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(i*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]valueBlank] == prevValue) {
                indY = i;
                count++;
            }
        }
    }
    if (count <= 1) {
        NSInteger count2 = 0;
        for (NSInteger j = ((DrawField*)viewDraw).cellChosenX - 1; j >=0; j--) {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+j)]bType] == SumBrick) || ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+j)]bType] == BlankBrick)) {
                break;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+j)]valueBlank] == prevValue) {
                count2++;
            }
        }
        for (NSInteger j = ((DrawField*)viewDraw).cellChosenX + 1; j < length; j++) {
            if (([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+j)]bType] == SumBrick) || ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+j)]bType] == BlankBrick)) {
                break;
            }
            if ([[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+j)]valueBlank] == prevValue) {
                count2++;
            }
        }
        if (count2 == 0) {
            ((Brick*)[((DrawField*)viewDraw).arrGenerated  objectAtIndex:(indY*((DrawField*)viewDraw).arrLength+((DrawField*)viewDraw).cellChosenX)]).marked = NO;
        }
    }
    return YES;
}

#pragma mark

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"numberToCell" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cellChosen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sumChosen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadGame" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loadCreatedGame" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resumeGame" object:nil];
}
@end