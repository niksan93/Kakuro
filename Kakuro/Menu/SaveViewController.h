//
//  SaveViewController.h
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 10.05.13.
//  Copyright (c) 2013 Alexandr Nikanorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveViewController : UIViewController <UIAlertViewDelegate> {
    UIImageView* imageViewOne;
    UIImageView* imageViewTwo;
    UIImageView* imageViewThree;
    UIButton* buttonToSaveOne;
    UIButton* buttonToSaveTwo;
    UIButton* buttonToSaveThree;
    
    NSString* dateMM;
    NSString* dateHH;
    BOOL check;
    
    NSData *imgData;
    NSString  *jpgPath;
    NSArray* paths;
    NSString* documentFolder;
}

@property (assign, readwrite) NSDictionary* saveDictionary;
@property (assign, readwrite) NSMutableArray* array;
@property (assign, readwrite) UIImage* savingImage;
@property (assign, readwrite) NSDate* saveDate;

- (IBAction)backToGame:(UIButton *)sender;
-(id)initWithImage:(UIImage*)img dictionary:(NSDictionary*)dict array:(NSMutableArray*)arr popToRoot:(BOOL)bl;
- (IBAction)firstSave:(UIButton *)sender;
- (IBAction)secondSave:(UIButton *)sender;
- (IBAction)thirdSave:(UIButton *)sender;

@end
