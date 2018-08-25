//
//  UIImage+Trim.m
//  littleprinter
//
//  Created by Joe Rickerby on 25/08/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

#import "UIImage+Trim.h"

@implementation UIImage (Trim)

- (nonnull UIImage *)imageByTrimmingTopAndBottomPixels {
    CGImageRef cgImage = self.CGImage;
    
    int rows = (int)CGImageGetHeight(cgImage);
    int cols = (int)CGImageGetWidth(cgImage);
    int bytesPerRow = cols * 4 * sizeof(uint8_t);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (rows < 2 || cols < 2) {
        return self;
    }
    
    // allocate array to hold image data
    uint8_t *bitmapData = calloc(rows*cols*4, sizeof(uint8_t));
    
    // create rgb bitmap context
    CGContextRef contextRef = CGBitmapContextCreate(bitmapData,
                                                    cols,
                                                    rows,
                                                    8,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedFirst);
    
    // draw our image on that context
    CGRect rect = CGRectMake(0, 0, cols, rows);
    CGContextDrawImage(contextRef, rect, cgImage);
    
    // count all non-white pixels in every row
    uint16_t *rowSum = calloc(rows, sizeof(uint16_t));
    
    // enumerate through all pixels
    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
            int i = (row*bytesPerRow + col*4);
            // uint8_t x = bitmapData[i];
            uint8_t r = bitmapData[i+1];
            uint8_t g = bitmapData[i+2];
            uint8_t b = bitmapData[i+3];
            
            if (r != 255 || g != 255 || b != 255) { // found a non-white pixel
                rowSum[row]++;
            }
        }
    }
    
    int firstRow = 0;
    int lastRow = rect.size.height;
    
    for (int i = 0; i<rows; i++) {
        if (rowSum[i] > 0) {
            firstRow = i;
            break;
        }
    }
    
    for (int i = rows-1; i >= 0; i--) {
        if (rowSum[i] > 0) {
            lastRow = i+1;
            break;
        }
    }
    
    free(bitmapData);
    free(rowSum);
    
    CGImageRef newImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(0, firstRow,
                                                                           rect.size.width, lastRow - firstRow));
    
    return [UIImage imageWithCGImage:newImage];
}

@end
