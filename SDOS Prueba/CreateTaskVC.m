//
//  CreateTaskVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "CreateTaskVC.h"

@interface CreateTaskVC ()

@end

@implementation CreateTaskVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonSystemItem style = UIBarButtonSystemItemSave;
    SEL selector = @selector(saveTask);
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:self action:selector];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)saveTask
{
    NSMutableDictionary *task = [[NSMutableDictionary alloc] init];
    
    NSString *title = self.titleField.text;
    NSString *type = self.typeField.text;
    NSString *duraction = self.durationField.text;
    NSString *description = self.descriptionArea.text;
    
    [task setObject:title forKey:@"title"];
    [task setObject:type forKey:@"type"];
    [task setObject:duraction forKey:@"duration"];
    [task setObject:description forKey:@"description"];
    [task setObject:@[] forKey:@"technicians"];
    [task setObject:@[] forKey:@"started"];
    [task setObject:@0 forKey:@"completed"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:task forKey:@"task"];
    [defaults synchronize];
    
    [self performSegueWithIdentifier:@"saveNewTask" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
