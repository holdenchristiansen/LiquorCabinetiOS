//
//  UnderlineLabel.m
//  LiquorCabinet
//
//  Created by Mark Powell on 11/10/11.
//  Copyright (c) 2011 Lavacado Studios, LLC. All rights reserved.
//

#import "UnderlineLabel.h"

@implementation UnderlineLabel

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.0f); // RGBA
    CGContextSetLineWidth(ctx, 2.0f);
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - 4);
    CGSize fontSize = [self.text sizeWithFont:self.font];
    int xLocation = fontSize.width;
    CGContextAddLineToPoint(ctx, xLocation, self.bounds.size.height - 4);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];  
}

@end
