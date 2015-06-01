//
//  EditViewController.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "EditViewController.h"
#import "TextFieldCell.h"
#import "TextViewCell.h"
#import "Task.h"
#import "UITableView+Extensions.h"
#import "KeyboardAccessoryView.h"

static NSString *TextFieldCellIdentifier = @"TextFieldCell";
static NSString *TextViewCellIdentifier = @"TextViewCell";

@interface EditViewController ()
<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.presentingViewController) {
        self.title = @"ToDo作成";
    } else {
        self.title = @"ToDo編集";
    }
    [self prepareTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapSubmit:(id)sender {
    [self.view endEditing:YES];
    NSMutableArray *messages = [NSMutableArray array];
    if (![self.task.title length]) {
        [messages addObject:@"タイトルを入力してください。"];
    }
    if ([messages count] > 0) {
        NSString *message = [messages componentsJoinedByString:@"\n"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"入力エラー" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    [self.delegate editViewController:self didFinishWithSave:YES];
    [self dismiss];
}

- (IBAction)tapCancel:(id)sender {
    [self.view endEditing:YES];
    [self.delegate editViewController:self didFinishWithSave:NO];
    [self dismiss];
}

- (void)dismiss
{
    if (self.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)prepareTableView
{
    self.tableView.rowHeight = 44;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TextFieldCell class]) bundle:nil] forCellReuseIdentifier:TextFieldCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TextViewCell class]) bundle:nil] forCellReuseIdentifier:TextViewCellIdentifier];
}

- (UIView *)inputAccessoryView
{
    return [self keyboardAccessorView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    switch (indexPath.row) {
        case TaskPropertyMemo:
            height = 180;
            break;
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case TaskPropertyTitle:
            cell = [self tableView:tableView textFieldCellForRowAtIndexPath:indexPath];
            break;
        case TaskPropertyMemo:
            cell = [self tableView:tableView textViewCellForRowAtIndexPath:indexPath];
            break;
        default:
            cell = [self tableView:tableView defaultCellForRowAtIndexPath:indexPath];
            break;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView defaultCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView textFieldCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier];
    cell.textField.delegate = self;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView textViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewCell *cell = (TextViewCell *)[tableView dequeueReusableCellWithIdentifier:TextViewCellIdentifier];
    cell.textView.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle: {
            TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
            break;
        }
        case TaskPropertyMemo: {
            TextViewCell *cell = (TextViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textView becomeFirstResponder];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle: {
            TextFieldCell *editCell = (TextFieldCell *)cell;
            editCell.textField.placeholder = @"入力";
            editCell.label.text = TaskPropertyString(indexPath.row);
            editCell.textField.text = self.task.title;
            break;
        }
        case TaskPropertyMemo: {
            TextViewCell *editCell = (TextViewCell *)cell;
            editCell.label.font = [UIFont systemFontOfSize:17];
            editCell.label.text = TaskPropertyString(indexPath.row);
            editCell.textView.text = self.task.memo;
            break;
        }
        case TaskPropertyPriority: {
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = TaskPropertyString(indexPath.row);
            cell.detailTextLabel.text = TaskPriorityString(self.task.priority);
            break;
        }
        case TaskPropertyDueDate: {
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = TaskPropertyString(indexPath.row);
            cell.detailTextLabel.text = [self.task dueDateAsString];
            break;
        }
        default:
            break;
    }
}

- (void)assignText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle:
            self.task.title = text;
            break;
        case TaskPropertyMemo:
            self.task.memo = text;
            break;
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView xxx_indexPathAtFirstRespondingView:textField];
    if (indexPath) {
        [self.tableView xxx_flashRowAtIndexPath:indexPath];
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView xxx_indexPathAtFirstRespondingView:textField];
    if (indexPath) {
        [self assignText:textField.text atIndexPath:indexPath];
    }
}

#pragma mark - UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [self.tableView xxx_indexPathAtFirstRespondingView:textView];
    if (indexPath) {
        [self.tableView xxx_flashRowAtIndexPath:indexPath];
    }
    return true;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [self.tableView xxx_indexPathAtFirstRespondingView:textView];
    if (indexPath) {
        [self assignText:textView.text atIndexPath:indexPath];
    }
}

@end
