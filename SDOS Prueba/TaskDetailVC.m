//
//  TaskDetailVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "TaskDetailVC.h"

@interface TaskDetailVC ()

@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *task;

@end

@implementation TaskDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.user = [defaults objectForKey:@"user"];
    self.task = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"task"]];
    
    [self.navigationItem setTitle:[self.task objectForKey:@"title"]];
    
    self.typeLabel.text = [self.task objectForKey:@"type"];
    self.duractionLabel.text = [self.task objectForKey:@"duration"];
    self.descriptionLabel.text = [self.task objectForKey:@"description"];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    
    NSArray *started = [self.task objectForKey:@"started"];
    
    NSLog(@"SE 234 %@", [defaults objectForKey:@"task"]);
    
    NSLog(@"%@", [self.task objectForKey:@"started"]);
    
    if ([started containsObject:[self.user objectForKey:@"id"]]) {
        NSLog(@"Yes");
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = @"Terminar";
    }
    
    NSNumber *completed = [self.task objectForKey:@"completed"];
    
    if ([completed isEqual:@1]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.text = @"Terminado";
        cell.textLabel.textColor = [UIColor redColor];
        cell.userInteractionEnabled = NO;
    }
}

- (void)saveTask {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.task forKey:@"task"];
    [defaults synchronize];
    
    NSLog(@"SE %@", [defaults objectForKey:@"task"][@"started"]);
    
    NSLog(@"%@", self.task[@"started"]);
    
    NSArray *loadedTasks = [JSONManager loadJSONArrayFromDocuments:@"tasks" withKey:@"tasks"];
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithArray:loadedTasks];
    
    for (int i = 0; i < tasks.count; i++) {
        NSDictionary *task = [tasks objectAtIndex:i];
        if ([[task objectForKey:@"id"] isEqual:[self.task objectForKey:@"id"]]) {
            [tasks replaceObjectAtIndex:i withObject:self.task];
            NSLog(@"Task replaced");
            break;
        }
    }
    
    [JSONManager writeArray:tasks toJSONFile:@"tasks" withkey:@"tasks"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell.textLabel.text isEqualToString:@"Comenzar"])
        {
            cell.textLabel.text = @"Terminar";
            
            NSMutableArray *started = [[NSMutableArray alloc] initWithArray:[self.task objectForKey:@"started"]];
            [started addObject:[self.user objectForKey:@"id"]];
            [self.task setObject:started forKey:@"started"];
            
            [self saveTask];
        }
        else if ([cell.textLabel.text isEqualToString:@"Terminar"])
        {
            cell.textLabel.text = @"Terminado";
            cell.textLabel.textColor = [UIColor redColor];
            cell.userInteractionEnabled = NO;
            
            [self.task setObject:@1 forKey:@"completed"];
            
            [self saveTask];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
