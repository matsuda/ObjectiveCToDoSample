//
//  PickerController.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerControllerDelegate;

@interface PickerController : UIViewController
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) id <PickerControllerDelegate> delegate;

- (void)presentPickerWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)dismissPickerWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@protocol PickerControllerDelegate <NSObject>

- (void)pickerControllerDidSelect:(PickerController *)controller;
- (void)pickerControllerDidCancel:(PickerController *)controller;

@end
