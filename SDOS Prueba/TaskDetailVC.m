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
    
    int hours = [self.task[@"hours"] intValue];
    NSString *hoursString = (hours == 1?@"hora":@"horas");
    
    self.durationLabel.text = [NSString stringWithFormat:@"%d %@", hours, hoursString];
    
    self.descriptionLabel.text = [self.task objectForKey:@"description"];
    
    BOOL started = [[self.task objectForKey:@"started"] containsObject:[self.user objectForKey:@"id"]];
    BOOL completed = [[self.task valueForKey:@"completed"] isEqual:@1];
    
    if (started)
    {
        self.buttonCell.textLabel.text = @"Terminar";
        self.buttonCell.textLabel.textColor = [UIColor redColor];
    }
    
    if (completed)
    {
        self.buttonCell.textLabel.text = @"Terminado";
        self.buttonCell.textLabel.textColor = [UIColor darkTextColor];
        self.buttonCell.userInteractionEnabled = NO;
    }
}

- (NSArray*)replaceTaskInList:(NSArray*)tasks withTask:(NSDictionary*)task {
    NSMutableArray *newTasks = [[NSMutableArray alloc] initWithArray:tasks];
    
    for (int i = 0; i < tasks.count; i++)
    {
        NSDictionary *t = [tasks objectAtIndex:i];
        if ([[t objectForKey:@"id"] isEqual:[task objectForKey:@"id"]])
        {
            [newTasks replaceObjectAtIndex:i withObject:task];
            break;
        }
    }
    
    return newTasks;
}

- (void)saveTask
{
    NSLog(@"Save Task");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.task forKey:@"task"];
    [defaults synchronize];
    
    NSArray *tasks = [JSONManager loadJSONArrayFromDocuments:@"tasks" withKey:@"tasks"];
    
    NSArray *updatedTasks = [self replaceTaskInList:tasks withTask:self.task];
    
    [JSONManager writeArray:updatedTasks toJSONFile:@"tasks" withkey:@"tasks"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    BOOL completed = [[self.task valueForKey:@"completed"] isEqual:@1];
    
    if (completed)
    {
        return 4;
    }
    else
    {
        return 3;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell.textLabel.text isEqualToString:@"Comenzar"])
        {
            NSMutableArray *started = [[NSMutableArray alloc] initWithArray:[self.task objectForKey:@"started"]];
            [started addObject:[self.user objectForKey:@"id"]];
            [self.task setObject:started forKey:@"started"];
            
            [self saveTask];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([cell.textLabel.text isEqualToString:@"Terminar"])
        {
            [self.task setObject:@1 forKey:@"completed"];
            
            [self saveTask];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (indexPath.section == 3)
    {
        NSMutableArray *technicians = [[NSMutableArray alloc] initWithArray:[self.task objectForKey:@"technicians"]];
        [technicians removeObject:[self.user objectForKey:@"id"]];
        [self.task setObject:technicians forKey:@"technicians"];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.task forKey:@"task"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSegueWithIdentifier:@"deletedTask" sender:self];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
