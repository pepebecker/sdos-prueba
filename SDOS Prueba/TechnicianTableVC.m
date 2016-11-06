//
//  TechnicianTableVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "TechnicianTableVC.h"

@interface TechnicianTableVC ()

@property (nonatomic, strong) NSMutableDictionary *user;
@property (nonatomic, strong) NSMutableArray *tasks;

@end

@implementation TechnicianTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    self.tasks = [[NSMutableArray alloc] init];
    
    NSArray *tasks = [JSONManager loadJSONArrayFromDocuments:@"tasks" withKey:@"tasks"];
    
    for (NSDictionary *task in tasks) {
        NSArray *techniciansWorkingOnTask = [task objectForKey:@"technicians"];
        if ([techniciansWorkingOnTask containsObject:[self.user objectForKey:@"id"]]) {
            [self.tasks addObject:task];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell" forIndexPath:indexPath];
    
    NSDictionary *task = [self.tasks objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [task objectForKey:@"title"];
    
    cell.detailTextLabel.text = [task objectForKey:@"duration"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *task = [self.tasks objectAtIndex:indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:task forKey:@"task"];
    [defaults setInteger:indexPath.row forKey:@"taskIndex"];
    [defaults synchronize];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"showTask" sender:self];
}

@end
