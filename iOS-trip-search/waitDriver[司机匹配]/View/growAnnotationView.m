//
//  growAnnotationView.m
//  iOS-marker-grow
//
//  Created by 翁乐 on 30/11/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

#import "growAnnotationView.h"

@interface growAnnotationView()<CAAnimationDelegate>

@end

@implementation growAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil) {
        return;
    }
    
    if (CGRectContainsPoint(newSuperview.bounds, self.center)) {
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        growAnimation.delegate = (id<CAAnimationDelegate>)self;
        growAnimation.duration = 0.5f;
        growAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        growAnimation.fromValue = [NSNumber numberWithDouble:0.0f];
        
        growAnimation.toValue = [NSNumber numberWithDouble:1.0f];
        
        [self.layer addAnimation:growAnimation forKey:@"growAnimation"];
    }
}

@end
