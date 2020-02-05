//
//  LiquorCabinetOnlineCache.m
//  LiquorCabinet
//
//  Created by Mark Powell on 11/1/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import "LiquorCabinetOnlineCache.h"

@implementation LiquorCabinetOnlineCache

- (id)init {
    if ((self = [super init])) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 4;
        _listCacheLocation = @"Library/Caches/List";
    }
    
    return self;
}

- (void)listIconImageForListNamed:(NSString *)list completionBlock:(void (^)(NSData *data, NSError *error))block {
    [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
        NSString *fileNameURL = [list urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSData *imageData = nil;
        //Check disk trips first
        NSString *listIconDestPath = [NSHomeDirectory() stringByAppendingPathComponent:self.listCacheLocation];
        if (![[NSFileManager defaultManager] fileExistsAtPath:listIconDestPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:listIconDestPath
                                      withIntermediateDirectories:YES attributes:nil error:nil];
        }
        listIconDestPath = [listIconDestPath stringByAppendingPathComponent:fileNameURL];
        imageData = [NSData dataWithContentsOfFile:listIconDestPath];
        
        //Get from web
        if (imageData == nil) {
            @autoreleasepool {
                NSString *fileURL = [NSString stringWithFormat:@"http://liquorcabinetapp.appspot.com/list/listImage?name=%@", fileNameURL];
                
                NSLog(@"path=%@",fileNameURL);
                
                imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
                
                if (imageData != nil) {
                    [imageData writeToFile:listIconDestPath atomically:YES];
                    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                        block(imageData, nil);
                    }]];
                }
                
            }
        } else {
            [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^(void){
                block(imageData, nil);
            }]];
        }
    }]];
}

- (void)clearCache {
    NSString *listIconDestPath = [NSHomeDirectory() stringByAppendingPathComponent:self.listCacheLocation];
    NSDirectoryEnumerator* en = [[NSFileManager defaultManager] enumeratorAtPath:listIconDestPath];
    NSError* err = nil;
    BOOL res;
    
    NSString* file;
    while (file = [en nextObject]) {
        res = [[NSFileManager defaultManager] removeItemAtPath:[listIconDestPath stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }
}

@end
