//
//  ProfileVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC ()

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    
    NSString *readableType = @"Administrador";
    
    if ([user[@"type"] isEqualToString:@"technician"])
    {
        readableType = user[@"field"];
    }
    
    [self.nameLabel setText:user[@"name"]];
    [self.typeLabel setText:readableType];
}

@end
