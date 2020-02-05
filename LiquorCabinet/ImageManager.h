//
//  ImageManager.h
//  LiquorCabinet
//
//  Created by Roy Quesada on 6/2/16.
//  Copyright © 2016 Lavacado Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject

+ (ImageManager*)sharedImageManager;
- (void) downloadRemoteImage:(NSString* )imageURLString;
- (UIImage*) loadImage:(NSString*) imageName;

@end
