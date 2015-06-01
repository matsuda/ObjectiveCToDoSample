//
//  TextFieldCell.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
