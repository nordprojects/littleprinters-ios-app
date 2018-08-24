//
//  UIImage+Dither.h
//  littleprinter
//
//  Created by Joe Rickerby on 24/08/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ImageDitherStyleAtkinson = 0,
    ImageDitherStyleLines,
    ImageDitherStyleDiagonal,
    ImageDitherStyleDotty
} ImageDitherStyle;

@interface UIImage (Dither)

- (UIImage *)ditheredImageWithWidth:(CGFloat)width;
- (UIImage *)ditheredImageWithWidth:(CGFloat)width style:(ImageDitherStyle)style;

@end
