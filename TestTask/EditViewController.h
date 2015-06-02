//
//  EditViewController.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@protocol EditViewControllerDelegate;

@interface EditViewController : UIViewController

@property (weak, nonatomic) id <EditViewControllerDelegate> delegate;
@property (strong, nonatomic) Task *task;

@end

@protocol EditViewControllerDelegate <NSObject>

- (void)editViewController:(EditViewController *)controller didFinishSaveWithTask:(Task *)task;

@end