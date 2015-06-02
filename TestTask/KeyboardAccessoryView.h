//
//  KeyboardAccessoryView.h
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KeyboardAccessoryViewDelegate;

@interface KeyboardAccessoryView : UIView

@property (weak, nonatomic) id <KeyboardAccessoryViewDelegate> delegate;

+ (instancetype)getInstance;

@end

@protocol KeyboardAccessoryViewDelegate <NSObject>

- (void)keyboardAccessoryView:(KeyboardAccessoryView *)view didTapDone:(UIBarButtonItem *)button;
- (void)keyboardAccessoryView:(KeyboardAccessoryView *)view didTapClose:(UIBarButtonItem *)button;

@end
