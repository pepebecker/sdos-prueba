//
//  AdminTaskDetails.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 06/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "AdminTaskDetails.h"

@interface AdminTaskDetails ()
{
    BOOL technicianExists;
}
@end

@implementation AdminTaskDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *task = [[NSUserDefaults standardUserDefaults] objectForKey:@"task"];
    
    [self.titleLabel setText:task[@"title"]];
    
    NSString *type = task[@"type"];
    
//    if ([type isEqualToString:@"sale"])
//    {
//        type = @"Venta";
//    }
//    
//    if ([type isEqualToString:@"logistic"])
//    {
//        type = @"Logística";
//    }
    
    self.typeLabel.text = type;
    
    NSInteger hours = [task[@"hours"] intValue];
    
    self.durationLabel.text = [NSString stringWithFormat:@"%d %@", hours, (hours == 1?@"hora":@"horas")];
    
    
    NSArray *users = [JSONManager loadJSONArrayFromDocuments:@"users" withKey:@"users"];
    
    for (NSDictionary *user in users)
    {
        if ([task[@"technicians"] containsObject:user[@"id"]]) {
            self.nameLabel.text = user[@"name"];
            technicianExists = YES;
            break;
        }
    }
    
    self.descriptionArea.text = task[@"description"];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (technicianExists)
            {
                return 4;
            }
            else
            {
                return 3;
            }
            
        default:
            return 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        [self performSegueWithIdentifier:@"deleteTask" sender:self];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
