//
//  JSONManager.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "JSONManager.h"

@implementation JSONManager

+(NSArray *)loadJSONArrayFromMainBundle:(NSString *)fileName withKey:(NSString *)key {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    if (!filePath) {
        NSLog(@"Couldn't get path of %@.json", fileName);
        return @[];
    }
    
    NSString *json = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (!json) {
        NSLog(@"%@.json couldn't be read!", fileName);
        return @[];
    }
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (error) {
        NSLog(@"Failed to get NSDictionary from jsonData: %@", error.userInfo);
        return @[];
    }
    
    NSArray *array = dict[key];
    
    return array;
}

+ (NSArray *)loadJSONArrayFromDocuments:(NSString *)fileName withKey:(NSString *)key {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".json"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    if (error) {
        NSLog(@"Failed to get NSDictionary from jsonData: %@", error.userInfo);
        return @[];
    }
    
    NSArray *array = dict[key];
    
    return array;
}

+ (BOOL)writeArray:(NSArray*)array toJSONFile:(NSString*)fileName withkey:(NSString*)key {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".json"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[array] forKeys:@[key]];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"Failed to get jsonData from NSDictionary: %@", error.userInfo);
        return NO;
    }
    
    [jsonData writeToFile:filePath atomically:NO];
    
    return YES;
}

@end
