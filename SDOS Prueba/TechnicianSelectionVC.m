//
//  TechnicianSelectionVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "TechnicianSelectionVC.h"

@interface TechnicianSelectionVC ()

@property (nonatomic, strong) NSMutableDictionary *task;
@property (nonatomic, strong) NSMutableArray *technicans;
@property (nonatomic, strong) NSMutableArray *selectedTechinicians;
//@property (nonatomic, strong) NSMutableArray *techiniciansWhoHaveStarted;

@end

@implementation TechnicianSelectionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonSystemItem style = UIBarButtonSystemItemSave;
    SEL selector = @selector(saveSelection);
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:self action:selector];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Task
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.task = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"task"]];
    
    self.selectedTechinicians = [[NSMutableArray alloc] initWithArray:[self.task objectForKey:@"technicians"]];
    
    // Technician
    NSArray *users = [JSONManager loadJSONArrayFromDocuments:@"users" withKey:@"users"];
    
    self.technicans = [[NSMutableArray alloc] init];
    
    for (NSDictionary *user in users)
    {
        if ([user[@"type"] isEqualToString:@"technician"])
        {
            [self.technicans addObject:user];
        }
    }
}

-(void)saveSelection
{
    [self.task setObject:self.selectedTechinicians forKey:@"technicians"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.task forKey:@"task"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"updateTask" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.technicans.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"technicianCell" forIndexPath:indexPath];
    
    NSDictionary *techinician = self.technicans[indexPath.row];
    NSString *tecName = [techinician objectForKey:@"name"];
    NSNumber *tecID = [techinician objectForKey:@"id"];
    
    cell.textLabel.text = tecName;
    
    if ([self.selectedTechinicians containsObject:tecID])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    NSArray *started = [self.task objectForKey:@"started"];
    
    if ([started containsObject:tecID])
    {
        cell.detailTextLabel.text = @"comenzado";
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *technician = [self.technicans objectAtIndex:indexPath.row];
    NSNumber *tecID = [technician objectForKey:@"id"];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedTechinicians removeObject:tecID];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedTechinicians addObject:tecID];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
