//
//  UIImage+Dither.m
//  littleprinter
//
//  Created by Joe Rickerby on 24/08/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

#import "UIImage+Dither.h"

typedef struct {
    intptr_t x;
    intptr_t y;
} PixelCoord;

@implementation UIImage (Dither)

- (UIImage *)ditheredImageWithWidth:(CGFloat)width {
    return [self ditheredImageWithWidth:width style:ImageDitherStyleAtkinson];
}

- (UIImage *)ditheredImageWithWidth:(CGFloat)width style:(ImageDitherStyle)style
{
    CGFloat height = ceil(self.size.height / self.size.width * width);
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    [self drawInRect:CGRectMake(0, 0, width, height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef resizedImage = CGBitmapContextCreateImage(context);
    
    UIGraphicsEndImageContext();
    
    CFDataRef immutableData = CGDataProviderCopyData(CGImageGetDataProvider(resizedImage));
    CFMutableDataRef rawData = CFDataCreateMutableCopy(NULL, CFDataGetLength(immutableData), immutableData);
    CFRelease(immutableData);
    
    uint8_t *buf = (uint8_t *)CFDataGetMutableBytePtr(rawData);
    CFIndex length = CFDataGetLength(rawData);
    
    float *ditherError = calloc(length / 4, sizeof(float));
    
    size_t w = CGImageGetWidth(resizedImage);
    size_t h = CGImageGetHeight(resizedImage);
    
    for (unsigned long i=0; i<length; i+=4) {
        intptr_t pixelIndex = i / 4;
        intptr_t x = pixelIndex % w;
        intptr_t y = pixelIndex / w;
        
        // uint8_t a = buf[i];
        uint8_t r = buf[i+1];
        uint8_t g = buf[i+2];
        uint8_t b = buf[i+3];
        
        float gray = 0.3f*r + 0.59f*g + 0.11f*b;
        
        gray += ditherError[pixelIndex];
        
        float pixel = gray > 128.0f ? 255.0f : 0.0f;
        float error = gray - pixel;
        
        // set the rounded value back to the source buffer
        buf[i] = 255; // always max out the alpha
//        buf[i+1] = fmax(fmin(gray, 255), 0);
//        buf[i+2] = fmax(fmin(gray, 255), 0);
//        buf[i+3] = fmax(fmin(gray, 255), 0);
        buf[i+1] = pixel;
        buf[i+2] = pixel;
        buf[i+3] = pixel;
        
        // distribute the error
        PixelCoord errorPixels[10];
        size_t nErrorPixels = 0;
        switch (style) {
            case ImageDitherStyleAtkinson:
                errorPixels[nErrorPixels++] = (PixelCoord){ 1, 0};
                errorPixels[nErrorPixels++] = (PixelCoord){ 2, 0};
                errorPixels[nErrorPixels++] = (PixelCoord){-1, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 0, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 1, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 0, 2};
                break;
            case ImageDitherStyleLines:
                errorPixels[nErrorPixels++] = (PixelCoord){-2, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){-1, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 0, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 1, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 2, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 3, 1};
                break;
            case ImageDitherStyleDiagonal:
                errorPixels[nErrorPixels++] = (PixelCoord){-1, 1};
                errorPixels[nErrorPixels++] = (PixelCoord){ 2, 2};
                errorPixels[nErrorPixels++] = (PixelCoord){ 3, 3};
                errorPixels[nErrorPixels++] = (PixelCoord){ 4, 4};
                break;
            case ImageDitherStyleDotty:
                errorPixels[nErrorPixels++] = (PixelCoord){ 0, 2};
                errorPixels[nErrorPixels++] = (PixelCoord){ 0, 4};
                errorPixels[nErrorPixels++] = (PixelCoord){ 0, 6};
                break;
        }
        
        
        for (int j = 0; j < nErrorPixels; j++) {
            intptr_t errorX = x + errorPixels[j].x;
            intptr_t errorY = y + errorPixels[j].y;
            
            if (errorX < 0 || errorX >= w || errorY >= h) continue;
            
            intptr_t errorI = errorX + errorY * w;
            ditherError[errorI] += error / (float)(nErrorPixels + 1);
        }
    }
    
    CGColorSpaceRef cgColorSpace = CGImageGetColorSpace(resizedImage);
    CGDataProviderRef ditheredImageDataProvider = CGDataProviderCreateWithCFData(rawData);
    
    CGImageRef ditheredCGImage = CGImageCreate(/*size_t width*/ w,
                                               /*size_t height*/ h,
                                               /*size_t bitsPerComponent*/ 8,
                                               /*size_t bitsPerPixel*/ 8*4,
                                               /*size_t bytesPerRow*/ 4*w,
                                               /*CGColorSpaceRef  _Nullable space*/ cgColorSpace,
                                               /*CGBitmapInfo bitmapInfo*/ (CGBitmapInfo)kCGImageAlphaPremultipliedFirst,
                                               /*CGDataProviderRef  _Nullable provider*/ ditheredImageDataProvider,
                                               /*const CGFloat * _Nullable decode*/ NULL,
                                               /*bool shouldInterpolate*/ false,
                                               /*CGColorRenderingIntent intent*/ kCGRenderingIntentDefault);
    UIImage *ditheredImage = [UIImage imageWithCGImage:ditheredCGImage];
    
    CFRelease(ditheredImageDataProvider);
    CFRelease(ditheredCGImage);
    CFRelease(resizedImage);
    CFRelease(rawData);
    free(ditherError);
    
    return ditheredImage;
}

//        let height = ceil(image.size.height / image.size.width * width)
//UIGraphicsBeginImageContext(CGSize(width: width, height: height))
//image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
//let context = UIGraphicsGetCurrentContext()!
//
//let resizedImage = context.makeImage()!

//        let pixelData = ditheredImage.dataProvider!.data
//        let data: UnsafeMutablePointer<UInt8> = CFDataGetMutableBytePtr(pixelData)
//        let data = context.data!.assumingMemoryBound(to: UInt8.self)
//
//        let rowStride = Int(width) * 4
//
//        for y in 0..<Int(height) {
//            for x in 0..<Int(width) {
//                let offset: Int = ((Int(width) * y) + x) * 4
//                let r = CGFloat(data[offset]) / CGFloat(255)
//                let g = CGFloat(data[offset+1]) / CGFloat(255)
//                let b = CGFloat(data[offset+2]) / CGFloat(255)
//                let gray = r*0.3 + g*0.59 + b*0.11;
//
//                let bwPixel = CGFloat(gray < 0.5 ? 0 : 1)
//                let error = gray - bwPixel;
//
//                // distribute the error
//                data[offset+4+0] += UInt8(error/8)
//                data[offset+4+1] += UInt8(error/8)
//                data[offset+4+2] += UInt8(error/8)
//                data[offset+8+0]
//
//                data[offset -]
//            }
//        }
//        kvImageConvert_DitherAtkinson
//        vImage
//
//        let ditheredImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return ditheredImage

@end
