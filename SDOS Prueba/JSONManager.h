//
//  JSONManager.h
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONManager : NSObject

+ (NSArray*)loadJSONArrayFromMainBundle:(NSString*)fileName withKey:(NSString*)key;
+ (NSArray*)loadJSONArrayFromDocuments:(NSString*)fileName withKey:(NSString*)key;
+ (BOOL)writeArray:(NSArray*)array toJSONFile:(NSString*)fileName withkey:(NSString*)key;

@end
