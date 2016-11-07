//
//  CreateTaskVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "CreateTaskVC.h"

@interface CreateTaskVC ()

@property (nonatomic, strong) UIPickerView *typePicker;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) UIPickerView *hourPicker;
@property (nonatomic, strong) NSNumber *selectedDuration;
@property (nonatomic, strong) UITextField *selectedTextField;

@end

@implementation CreateTaskVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.types = [[NSArray alloc] initWithObjects:@"Venta", @"Logística", @"Seguridad", @"Educación", nil];
    
    UIBarButtonSystemItem style = UIBarButtonSystemItemSave;
    SEL selector = @selector(saveTask);
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:self action:selector];
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.titleField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    [self.typeField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    [self.durationField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    
    self.typePicker = [[UIPickerView alloc] init];
    self.typePicker.dataSource = self;
    self.typePicker.delegate = self;
    [self.typePicker setShowsSelectionIndicator:YES];
    [self.typeField setInputView:self.typePicker];
    [[self.typeField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    
    self.hourPicker = [[UIPickerView alloc] init];
    self.hourPicker.dataSource = self;
    self.hourPicker.delegate = self;
    [self.hourPicker setShowsSelectionIndicator:YES];
    [self.durationField setInputView:self.hourPicker];
    [[self.durationField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    
    [self.titleField setDelegate:self];
    [self.typeField setDelegate:self];
    [self.durationField setDelegate:self];
}

- (void)textFieldValueChanged
{
    NSLog(@"Editing");
    
    NSInteger titleLenth = [self.titleField.text length];
    NSInteger typeLength = [self.typeField.text length];
    NSInteger durationLength = [self.durationField.text length];
    if (titleLenth > 0 && typeLength > 0 && durationLength > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)saveTask
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger lastTaskID = [[defaults objectForKey:@"lastTaskID"] intValue];
    
    NSMutableDictionary *task = [[NSMutableDictionary alloc] init];
    
    NSInteger taskID = lastTaskID + 1;
    NSString *title = self.titleField.text;
    NSString *type = self.typeField.text;
    NSString *description = self.descriptionArea.text;
    NSNumber *hours = self.selectedDuration;
    
    [task setObject:[NSNumber numberWithInt:taskID] forKey:@"id"];
    [task setObject:title forKey:@"title"];
    [task setObject:type forKey:@"type"];
    [task setObject:description forKey:@"description"];
    [task setObject:hours forKey:@"hours"];
    [task setObject:@[] forKey:@"technicians"];
    [task setObject:@[] forKey:@"started"];
    [task setObject:@0 forKey:@"completed"];
    
    [defaults setObject:task forKey:@"task"];
    [defaults setObject:[NSNumber numberWithInt:taskID] forKey:@"lastTaskID"];
    [defaults synchronize];
    
    [self performSegueWithIdentifier:@"saveNewTask" sender:self];
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.typeField] && [textField.text length] == 0)
    {
        self.typeField.text = self.types[0];
    }
    if ([textField isEqual:self.durationField] && [textField.text length] == 0)
    {
        self.durationField.text = @"1 hora";
        self.selectedDuration = [NSNumber numberWithInt:1];
    }
    self.selectedTextField = textField;
    
    [self textFieldValueChanged];
}

#pragma mark - TableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self.selectedTextField isEqual:self.typeField])
    {
        return self.types.count;
    }
    else
    {
        return 24;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.selectedTextField isEqual:self.typeField])
    {
        return self.types[row];
    }
    else
    {
        return [NSString stringWithFormat:@"%d %@", row + 1, (row == 0?@"hora":@"horas")];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.selectedTextField isEqual:self.typeField])
    {
        self.typeField.text = self.types[row];
    }
    if ([self.selectedTextField isEqual:self.durationField])
    {
        self.durationField.text = [NSString stringWithFormat:@"%d %@", row + 1, (row == 0?@"hora":@"horas")];
        self.selectedDuration = [NSNumber numberWithInt:row + 1];
    }
    
    [self textFieldValueChanged];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.titleField resignFirstResponder];
    [self.typeField resignFirstResponder];
    [self.durationField resignFirstResponder];
    [self.descriptionArea resignFirstResponder];
}

@end
