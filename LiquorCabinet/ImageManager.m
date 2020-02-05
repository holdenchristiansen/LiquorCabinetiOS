//
//  ImageManager.m
//  LiquorCabinet
//
//  Created by Roy Quesada on 6/2/16.
//  Copyright © 2016 Lavacado Studios, LLC. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager

static ImageManager* _sharedMySingleton = nil;

+(ImageManager*)sharedImageManager
{
    @synchronized([ImageManager class])
    {
        if (!_sharedMySingleton)
            _sharedMySingleton = [[self alloc] init];
        return _sharedMySingleton;
    }
    
    return nil;
}

- (void) downloadRemoteImage:(NSString* )imageName{
    
    //http://wsdcentroamerica.com/files/wpsc/product_images/
    //Botella-Cacique-Guaro-01-2.png
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSLog(@"http://wsdcentroamerica.com/files/wpsc/product_images/%@",imageName);
        NSString *urlToDownload = [NSString stringWithFormat:@"http://wsdcentroamerica.com/files/wpsc/product_images/%@",imageName];
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSArray    *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,imageName];
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"File Saved !");
            });
        }
        
    });
    
}

- (UIImage*) loadImage:(NSString*) imageName{
    UIImage *returnImage;
    
    returnImage = [UIImage imageNamed:imageName];
    if (returnImage == nil) {
        returnImage = [self loadImageSavedLocally:imageName];
    }
    
    
    if (returnImage == nil) {
        returnImage = [UIImage imageNamed:@"bottle_none.png"];
    }
    
    return returnImage;
}

- (UIImage*)loadImageSavedLocally:(NSString*)imageName{
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: imageName];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    return image;
}

@end
