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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle: {
            TextFieldCell *editCell = (TextFieldCell *)cell;
            editCell.textField.placeholder = @"入力";
            editCell.label.text = @"タイトル";
            editCell.textField.text = self.task.title;
            break;
        }
        case TaskPropertyMemo: {
            TextViewCell *editCell = (TextViewCell *)cell;
            editCell.label.font = [UIFont systemFontOfSize:17];
            editCell.label.text = @"メモ";
            editCell.textView.text = self.task.memo;
            break;
        }
        case TaskPropertyPriority: {
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = @"優先度";
            cell.detailTextLabel.text = TaskPriorityString(self.task.priority);
            break;
        }
        case TaskPropertyDueDate: {
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = @"予定日時";
            cell.detailTextLabel.text = [self.task dueDateAsString];
            break;
        }
        default:
            break;
    }
}

@end
