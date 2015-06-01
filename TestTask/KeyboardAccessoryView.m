//
//  KeyboardAccessoryView.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "KeyboardAccessoryView.h"

@interface KeyboardAccessoryView ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@end

@implementation KeyboardAccessoryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)tapDone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(keyboardAccessoryView:didTapDone:)]) {
        [self.delegate keyboardAccessoryView:self didTapDone:self.doneButton];
    }
}

- (IBAction)tapClose:(id)sender {
    if ([self.delegate respondsToSelector:@selector(keyboardAccessoryView:didTapClose:)]) {
        [self.delegate keyboardAccessoryView:self didTapClose:self.cancelButton];
    }
}

+ (instancetype)getInstance
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
    return [[nib instantiateWithOwner:nil options:nil] firstObject];
}

@end


@implementation UIViewController (KeyboardAccessoryView)

- (KeyboardAccessoryView *)keyboardAccessorView
{
    KeyboardAccessoryView *view = [KeyboardAccessoryView getInstance];
    view.delegate = self;
    return view;
}

- (void)keyboardAccessoryView:(KeyboardAccessoryView *)view didTapDone:(UIBarButtonItem *)button
{
    [self.view endEditing:YES];
}

- (void)keyboardAccessoryView:(KeyboardAccessoryView *)view didTapClose:(UIBarButtonItem *)button
{
    [self.view endEditing:YES];
}

@end