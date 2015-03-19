//
//  UIImage+RoundedResize.h
//
//  Created by Amudi SEBASTIAN
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface UIImage (RoundedResize)

- (UIImage *)copyWithSize:(CGSize)newSize
             cornerRadius:(CGFloat)radius;

- (UIImage *)copyWithSize:(CGSize)newSize
             cornerRadius:(CGFloat)radius
               borderSize:(CGFloat)borderSize
              borderColor:(CGColorRef)borderColor;

- (UIImage *)shadowedImageWithColor:(UIColor *)shadowColor
                             offset:(CGSize)shadowOffset;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                 cornerRadius:(CGFloat)radius
                                   borderSize:(CGFloat)borderSize
                                  borderColor:(CGColorRef)borderColor;

@end