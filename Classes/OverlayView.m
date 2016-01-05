//
//  OverlayView.m
//  BIZTinderCardStack
//
//  Created by IgorBizi@mail.ru on 5/19/15.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import "OverlayView.h"


#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@interface OverlayView ()
@property (nonatomic, strong) UIImageView *imageView; // for signs
@end


@implementation OverlayView


#pragma mark - LifeCycle


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeRedraw;
    [self addSubview:self.imageView];
}


#pragma mark - Getters/Setters


// * Lazy selection of overlay
- (void)setMode:(OverlayMode)mode
{
    if (self.mode == mode) {
        return;
    }
    
    _mode = mode;
    
    // * Start with initial imageView
    UIImage *image = nil;
    self.imageView.transform = CGAffineTransformMakeRotation(0);
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.image = nil;
    
    CGFloat insetTop = 0.22;//0.15;
    // * Calculate size of image base on sizes of the CardView and sizes of Image
    CGFloat sizeFactor = 0.003;
    
    if (mode == OverlayApprove) {
        
        image = self.leftImage;
        
        CGRect frame = self.frame;
        frame.size.width = sizeFactor * image.size.width * self.frame.size.width;
        frame.size.height = frame.size.width * image.size.width * sizeFactor / 2;
        frame.origin.x = 0;
        frame.origin.y = self.frame.size.height * insetTop;
        self.imageView.frame = frame;
        // * Rotate
        self.imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45));
    } else
        
        if (mode == OverlayReject) {
            
            image = self.rightImage;
            
            CGRect frame = self.frame;
            frame.size.width = sizeFactor * image.size.width * self.frame.size.width;
            frame.size.height = frame.size.width * image.size.width * sizeFactor / 2;
            frame.origin.x = self.frame.size.width - frame.size.width;
            frame.origin.y = self.frame.size.height * insetTop;
            self.imageView.frame = frame;
            // * Rotate
            self.imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45));
        }
    
    self.imageView.image = image;
}


#pragma mark - Events


- (void)setSignsTransperancy:(CGFloat)transperancy
{
    self.imageView.alpha = transperancy;
}

- (void)setBackgroundTransperancy:(CGFloat)transperancy
{
    UIColor *color = [UIColor colorWithWhite:0 alpha:0.2];
    self.backgroundColor = color; //[color colorBlendedWithColor:[UIColor clearColor] factor:1-transperancy];
}

@end
