//
//  LiquorCabinetOnlineCache.h
//  LiquorCabinet
//
//  Created by Mark Powell on 11/1/12.
//  Copyright (c) 2012 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                        CFStringConvertNSStringEncodingToEncoding(encoding));
}
@end

@interface LiquorCabinetOnlineCache : NSObject

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSString *listCacheLocation;

- (void)listIconImageForListNamed:(NSString *)urlString completionBlock:(void (^)(NSData *data, NSError *error))block;
- (void)clearCache;

@end
