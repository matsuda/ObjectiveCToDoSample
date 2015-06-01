//
//  UITableView+Extensions.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extensions)

- (void)xxx_selectRowAtFirstRespondingView:(UIView *)current;
- (NSIndexPath *)xxx_indexPathAtFirstRespondingView:(UIView *)current;
- (void)xxx_flashRowAtIndexPath:(NSIndexPath *)indexPath;

@end
