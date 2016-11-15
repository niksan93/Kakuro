//
//  SaveViewController.m
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 10.05.13.
//  Copyright (c) 2013 Alexandr Nikanorov. All rights reserved.
//

#import "SaveViewController.h"

@interface SaveViewController ()

@end

@implementation SaveViewController

@synthesize array;
@synthesize savingImage;
@synthesize saveDate;
@synthesize saveDictionary;

#pragma mark init methods
//Метод инициализации объекта класса
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"img.png"]]];
        imageViewOne = (UIImageView*)[self.view viewWithTag:1];
        imageViewTwo = (UIImageView*)[self.view viewWithTag:3];
        imageViewThree = (UIImageView*)[self.view viewWithTag:5];
        buttonToSaveOne = (UIButton*)[self.view viewWithTag:2];
        buttonToSaveTwo = (UIButton*)[self.view viewWithTag:4];
        buttonToSaveThree = (UIButton*)[self.view viewWithTag:6];
        //NSArray*
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString*
        documentFolder = [paths objectAtIndex:0];
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:[documentFolder stringByAppendingPathComponent:@"dictionary1"]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy";
        NSString* date = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSString* time = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        if (date != nil && time != nil)
            [buttonToSaveOne setTitle:[NSString stringWithFormat:@"%@\n%@", date, time] forState:UIControlStateNormal];
        dict = [NSDictionary dictionaryWithContentsOfFile:[documentFolder stringByAppendingPathComponent:@"dictionary2"]];
        dateFormatter.dateFormat = @"MM/dd/yy";
        date = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        dateFormatter.dateFormat = @"HH:mm:ss";
        time = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        if (date != nil && time != nil)
            [buttonToSaveTwo setTitle:[NSString stringWithFormat:@"%@\n%@", date, time] forState:UIControlStateNormal];
        dict = [NSDictionary dictionaryWithContentsOfFile:[documentFolder stringByAppendingPathComponent:@"dictionary3"]];
        dateFormatter.dateFormat = @"MM/dd/yy";
        date = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        dateFormatter.dateFormat = @"HH:mm:ss";
        time = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        [dateFormatter release];
        if (date != nil && time != nil)
            [buttonToSaveThree setTitle:[NSString stringWithFormat:@"%@\n%@", date, time] forState:UIControlStateNormal];
        imageViewOne.image = [UIImage imageWithContentsOfFile:[documentFolder stringByAppendingPathComponent:@"savedImage1.jpg"]];
        imageViewTwo.image = [UIImage imageWithContentsOfFile:[documentFolder stringByAppendingPathComponent:@"savedImage2.jpg"]];
        imageViewThree.image = [UIImage imageWithContentsOfFile:[documentFolder stringByAppendingPathComponent:@"savedImage3.jpg"]];
    }
    return self;
}
//метод инициализации объекта класса
-(id)initWithImage:(UIImage*)img dictionary:(NSDictionary*)dict array:(NSMutableArray*)arr popToRoot:(BOOL)bl {
    self = [super init];
    if (self) {
        // Custom initialization
        check = bl;
        savingImage = img;
        [savingImage retain];
        saveDictionary = dict;
        [saveDictionary retain];
        array = arr;
        [array retain];
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
        dateFormatter.dateFormat = @"MM/dd/yy";
        dateMM = [dateFormatter stringFromDate: [dict objectForKey:@"date"]];
        NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc]init]autorelease];
        timeFormatter.dateFormat = @"HH:mm:ss";
        dateHH = [timeFormatter stringFromDate: [dict objectForKey:@"date"]];
        [dateHH retain];
        [dateMM retain];
    }
    return self;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark button methods
//Метод кнопки первого сохранения (загружает сохраненную игру / говорит что сохранения нет / предлагает перезаписать сохранение)
- (IBAction)firstSave:(UIButton *)sender {
    if ([buttonToSaveOne.titleLabel.text isEqualToString:@"No save"]) {
        [imageViewOne setImage:savingImage];
        [buttonToSaveOne setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
        //NSData *
        imgData = UIImageJPEGRepresentation(savingImage, 1);
        //NSString *
        jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage1.jpg"];
        [imgData writeToFile:jpgPath atomically:YES];
        //NSArray*
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString*
        documentFolder = [paths objectAtIndex:0];
        [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary1"] atomically:YES];
        [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array1"]];
        if (check)
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    } else {
        /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Are you sure you want to override this save?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag = 1;
        [alert show];
        [alert release];*/
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Are you sure you want to overwrite this save?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        action = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction* act) {
            [self overwrite1Save];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//Метод кнопки второго сохранения (загружает сохраненную игру / говорит что сохранения нет / предлагает перезаписать сохранение)
- (IBAction)secondSave:(UIButton *)sender {
    if ([buttonToSaveTwo.titleLabel.text isEqualToString:@"No save"]) {
        [imageViewTwo setImage:savingImage];
        [buttonToSaveTwo setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
        //NSData *
        imgData = UIImageJPEGRepresentation(savingImage, 1);
        //NSString  *
        jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage2.jpg"];
        [imgData writeToFile:jpgPath atomically:YES];
        //NSArray*
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString*
        documentFolder = [paths objectAtIndex:0];
        [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary2"] atomically:YES];
        [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array2"]];
        if (check)
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    } else {
        /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Are you sure you want to override this save?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag = 2;
        [alert show];
        [alert release];*/
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Are you sure you want to overwrite this save?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        action = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction* act) {
            [self overwrite2Save];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//Метод кнопки третьего сохранения (загружает сохраненную игру / говорит что сохранения нет / предлагает перезаписать сохранение)
- (IBAction)thirdSave:(UIButton *)sender {
    if ([buttonToSaveThree.titleLabel.text isEqualToString:@"No save"]) {
        [imageViewThree setImage:savingImage];
        [buttonToSaveThree setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
        //NSData *
        imgData = UIImageJPEGRepresentation(savingImage, 1);
        //NSString *
        jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage3.jpg"];
        [imgData writeToFile:jpgPath atomically:YES];
        //NSArray*
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString*
        documentFolder = [paths objectAtIndex:0];
        [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary3"] atomically:YES];
        [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array3"]];
        if (check)
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    } else {
        /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Are you sure you want to overwrite this save?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag = 3;
        [alert show];
        [alert release];*/
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Are you sure you want to overwrite this save?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        action = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction* act) {
            [self overwrite3Save];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)overwrite1Save {
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentFolder = [paths objectAtIndex:0];
    [imageViewOne setImage:savingImage];
    [buttonToSaveOne setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
    imgData = UIImageJPEGRepresentation(savingImage, 1);
    jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage1.jpg"];
    [imgData writeToFile:jpgPath atomically:YES];
    [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary1"] atomically:YES];
    [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array1"]];
    if (check)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)overwrite2Save {
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentFolder = [paths objectAtIndex:0];
    [imageViewTwo setImage:savingImage];
    [buttonToSaveTwo setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
    imgData = UIImageJPEGRepresentation(savingImage, 1);
    jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage2.jpg"];
    [imgData writeToFile:jpgPath atomically:YES];
    [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary2"] atomically:YES];
    [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array2"]];
    if (check)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)overwrite3Save {
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentFolder = [paths objectAtIndex:0];
    [imageViewThree setImage:savingImage];
    [buttonToSaveThree setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
    imgData = UIImageJPEGRepresentation(savingImage, 1);
    jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage3.jpg"];
    [imgData writeToFile:jpgPath atomically:YES];
    [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary3"] atomically:YES];
    [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array3"]];
    if (check)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIAlertViewDelegate
//метод делегата UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //NSData *imgData;
        //NSString  *jpgPath;
        //NSArray*
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString*
        documentFolder = [paths objectAtIndex:0];
        switch (alertView.tag) {
            case 1:
                [imageViewOne setImage:savingImage];
                [buttonToSaveOne setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
                imgData = UIImageJPEGRepresentation(savingImage, 1);
                jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage1.jpg"];
                [imgData writeToFile:jpgPath atomically:YES];
                [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary1"] atomically:YES];
                [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array1"]];
                if (check)
                    [self.navigationController popToRootViewControllerAnimated:YES];
                else
                    [self.navigationController popViewControllerAnimated:YES];
                break;
            case 2:
                [imageViewTwo setImage:savingImage];
                [buttonToSaveTwo setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
                imgData = UIImageJPEGRepresentation(savingImage, 1);
                jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage2.jpg"];
                [imgData writeToFile:jpgPath atomically:YES];
                [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary2"] atomically:YES];
                [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array2"]];
                if (check)
                    [self.navigationController popToRootViewControllerAnimated:YES];
                else
                    [self.navigationController popViewControllerAnimated:YES];
                break;
            case 3:
                [imageViewThree setImage:savingImage];
                [buttonToSaveThree setTitle:[NSString stringWithFormat:@"%@\n%@", dateMM, dateHH] forState:UIControlStateNormal];
                imgData = UIImageJPEGRepresentation(savingImage, 1);
                jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage3.jpg"];
                [imgData writeToFile:jpgPath atomically:YES];
                [saveDictionary writeToFile:[documentFolder stringByAppendingPathComponent:@"dictionary3"] atomically:YES];
                [NSKeyedArchiver archiveRootObject:array toFile:[documentFolder stringByAppendingPathComponent:@"array3"]];
                if (check)
                    [self.navigationController popToRootViewControllerAnimated:YES];
                else
                    [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark button methods
//метод кнопки возвращает в главное меню
- (IBAction)backToGame:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"resumeGame" object:nil userInfo:nil];
}

@end
