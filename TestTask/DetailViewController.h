//
//  DetailViewController.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) Task *task;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

