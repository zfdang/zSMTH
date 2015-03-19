//
//  UIImage+RoundedResize.m
//
//  Created by Amudi SEBASTIAN.
//

#import "UIImage+RoundedResize.h"

@interface UIImage (RoundedResize)

- (void)drawBorderInRect:(CGRect)rect
                 context:(CGContextRef)context
            cornerRadius:(CGFloat)radius
              borderSize:(CGFloat)borderSize
             borderColor:(CGColorRef)borderColor;

@end

@implementation UIImage (RoundedResize)

CGContextRef MyCreateBitmapContextTemp(int pixelsWide, int pixelsHigh)
{
    CGContextRef    context=NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc(bitmapByteCount);
    
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
    
}

- (UIImage *)copyWithSize:(CGSize)newSize
             cornerRadius:(CGFloat)radius
               borderSize:(CGFloat)borderSize
              borderColor:(CGColorRef)borderColor
{
    CGRect rect = CGRectMake(0,0, newSize.width, newSize.height);
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        rect.size.height *= [[UIScreen mainScreen] scale];
        rect.size.width *= [[UIScreen mainScreen] scale];
        
        borderSize *= [[UIScreen mainScreen] scale];
        radius *= [[UIScreen mainScreen] scale];
    }
    
    CGContextRef context = MyCreateBitmapContextTemp(rect.size.width, rect.size.height);
    CGContextClearRect(context, rect);
    
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    
    CGContextClip(context);
    
    CGContextDrawImage(context, rect, [self CGImage]);
    
    if ((borderSize > 0) && (borderColor != NULL)) {
        [self drawBorderInRect:rect context:context cornerRadius:radius borderSize:borderSize borderColor:borderColor];
    }
    
    CGImageRef myRef=CGBitmapContextCreateImage(context);
    
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    UIImage *returnImage = [UIImage imageWithCGImage: myRef];
    CGImageRelease(myRef);
    
    return returnImage;
}

- (UIImage *)copyWithSize:(CGSize)newSize cornerRadius:(CGFloat)radius
{
    return [self copyWithSize:newSize cornerRadius:radius borderSize:0 borderColor:NULL];
}

- (UIImage *)shadowedImageWithColor:(UIColor *)shadowColor offset:(CGSize)shadowOffset
{
    CGSize resizedShadowOffset = shadowOffset;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        resizedShadowOffset.height *= [[UIScreen mainScreen] scale];
        resizedShadowOffset.width *= [[UIScreen mainScreen] scale];
    }
    
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             self.size.width + 2 * fabsf(resizedShadowOffset.width),
                             self.size.height + 2 * fabsf(resizedShadowOffset.height));
    
    CGContextRef context = MyCreateBitmapContextTemp(rect.size.width, rect.size.height);
    CGContextSetShadowWithColor(context, resizedShadowOffset, 3.0f, [shadowColor CGColor]);
    
    CGContextDrawImage(context, CGRectMake(fabsf(resizedShadowOffset.width), 
                                           fabsf(resizedShadowOffset.height), 
                                           self.size.width, 
                                           self.size.height), [self CGImage]);
    
    CGImageRef myRef = CGBitmapContextCreateImage(context);
    
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    UIImage *returnImage = [UIImage imageWithCGImage: myRef];
    CGImageRelease(myRef);
    
    return returnImage;
}

- (void)drawBorderInRect:(CGRect)rect
                 context:(CGContextRef)context
            cornerRadius:(CGFloat)radius
              borderSize:(CGFloat)borderSize
             borderColor:(CGColorRef)borderColor
{
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    
    CGContextSetLineWidth(context, borderSize);
    CGContextSetStrokeColorWithColor(context, borderColor);
    CGContextStrokePath(context);
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;        
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }       
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                 cornerRadius:(CGFloat)radius
                                   borderSize:(CGFloat)borderSize
                                  borderColor:(CGColorRef)borderColor
{
    UIImage *resizedImage = [self imageByScalingAndCroppingForSize:targetSize];
    
    CGRect rect = CGRectMake(0, 0, targetSize.width, targetSize.height);
    
    CGContextRef context = MyCreateBitmapContextTemp(targetSize.width, targetSize.height);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, [resizedImage CGImage]);
    
    if ((borderSize > 0) && (borderColor != NULL)) {
        [self drawBorderInRect:rect context:context cornerRadius:radius borderSize:borderSize borderColor:borderColor];
    }
    
    CGImageRef myRef=CGBitmapContextCreateImage(context);
    
    free(CGBitmapContextGetData(context));
    CGContextRelease(context);
    UIImage *returnImage = [UIImage imageWithCGImage: myRef];
    CGImageRelease(myRef);
    
    return returnImage;
}

@end