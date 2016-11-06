//
//  ProfilVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "ProfilVC.h"

@interface ProfilVC ()

@end

@implementation ProfilVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    
    NSString *readableType = @"Administrador";
    
    if ([user[@"type"] isEqualToString:@"technician"]) {
        readableType = @"Técnico";
    }
    
    [self.nameLabel setText:user[@"name"]];
    [self.typeLabel setText:readableType];
}

@end
