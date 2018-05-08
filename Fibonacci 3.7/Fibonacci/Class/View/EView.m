//
//  EView.m
//  Edemo
//
//  Created by woaiqiu947 on 16/9/20.
//  Copyright © 2016年 woaiqiu947. All rights reserved.
//

#import "EView.h"

@implementation EView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
//  eViewTransformStatus = EViewTransformStatusRight;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rect);
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGFloat x = rect.size.width/5;
    CGContextFillRect(context, CGRectMake(x, x, rect.size.width-x, x));
    
    CGContextFillRect(context, CGRectMake(x, rect.size.width-2*x, rect.size.width-x, x));
    CGContextStrokePath(context);
    if (viewCenter.x >0) {
        self.center = viewCenter;
    }
}

-(void)setHeigthAndWidth:(CGFloat)value center:(CGPoint)center
{
    if (value) {
        CGRect rects = self.frame;
        rects.size.height = rects.size.width= value;
        self.frame = rects;
    }
    viewCenter = center;
    [self setNeedsDisplay];
}

-(void)setEViewTransform:(EViewTransformStatus)status
{
    eViewTransformStatus = status;
    switch (eViewTransformStatus)
    {
        case EViewTransformStatusTop:
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            self.transform = CGAffineTransformRotate(transform, M_PI*1.5);
        }
            break;
        case EViewTransformStatusRight:
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            self.transform = CGAffineTransformRotate(transform, 0);
        }
            break;
        case EViewTransformStatusBottom:
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            self.transform = CGAffineTransformRotate(transform, M_PI*0.5);
        }
            break;
        case EViewTransformStatusLeft:
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            self.transform = CGAffineTransformRotate(transform, M_PI*1.0);
        }
            break;
        default:
            break;
    }
}

-(BOOL)eViewTransformDirection:(EViewTransformStatus)status
{
    if (eViewTransformStatus == status)
    {
        return YES;
    }
    return NO;
}
@end
