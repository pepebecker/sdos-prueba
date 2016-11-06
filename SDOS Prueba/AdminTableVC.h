//
//  AdminVC.h
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONManager.h"
#import "MGSwipeTableCell.h"

@interface AdminTableVC : UITableViewController<MGSwipeTableCellDelegate>

@property (nonatomic, strong) NSMutableArray *tasks;

@end
