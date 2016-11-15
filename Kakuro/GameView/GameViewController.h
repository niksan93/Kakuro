//
//  GameViewController.h
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 15.11.12.
//  Copyright (c) 2012 Alexandr Nikanorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleGenerator.h"

@interface GameViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate> {
    UIScrollView* scrollView;
    UILabel* lblGenerate;
    UILabel* lblTimer;
    UILabel* lblDifficulty;
    UIButton* btnRefresh;
    NSDate* start;
    NSTimeInterval timeInterval;
    UITextView* txtView;
    UIButton* btnHideSumsHelp;
    UIView* viewPause;
    UIButton* btnPause;
    BOOL needPop;
    BOOL checkSim;
    UILabel* lblStatus;
}

@property (assign, readwrite) PuzzleGenerator* pGenerator;
@property (assign, readwrite) UIView* viewDraw;
@property (assign, readwrite) UIView* viewControl;
@property (assign, readwrite) UILabel* lblDim;
@property (assign, readwrite) NSInteger length;
@property (assign, readwrite) NSInteger prevValue;
@property (assign, readwrite) NSInteger Difficulty;

- (IBAction)btnShowMenu:(UIButton *)sender;
- (IBAction)refreshPuzzle:(UIButton *)sender;
- (IBAction)hideSumsHelp:(UIButton *)sender;
- (IBAction)menuButtonContinue:(UIButton *)sender;
- (IBAction)menuButtonSave:(UIButton *)sender;
- (IBAction)menuButtonLoad:(UIButton *)sender;
- (IBAction)menuButtonExit:(UIButton *)sender;

@end
