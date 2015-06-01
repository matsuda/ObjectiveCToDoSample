//
//  DatePickerController.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerControllerDelegate;

@interface DatePickerController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id <DatePickerControllerDelegate> delegate;

- (void)presentPickerWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)dismissPickerWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@protocol DatePickerControllerDelegate <NSObject>

- (void)datePickerControllerDidSelect:(DatePickerController *)controller;
- (void)datePickerControllerDidCancel:(DatePickerController *)controller;

@end
