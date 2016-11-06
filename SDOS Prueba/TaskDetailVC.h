//
//  TaskDetailVC.h
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONManager.h"

@interface TaskDetailVC : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *duractionLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionLabel;

@end
