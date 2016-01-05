//
//  UserCardView.m
//  IgorBizi@mail.ru
//
//  Created by IgorBizi@mail.ru on 5/11/15.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//


#import "CardView.h"


@interface CardView ()
@end


@implementation CardView


#pragma mark - LifeCycle


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    [super setup];
    
    UITapGestureRecognizer *tapApproveImageViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rightButtonAction)];
    // * Pass the touch to the next responder
    tapApproveImageViewGesture.cancelsTouchesInView = NO;
    [self.approveImageView addGestureRecognizer:tapApproveImageViewGesture];
    
    UITapGestureRecognizer *tapRejectImageViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftButtonAction)];
    tapRejectImageViewGesture.cancelsTouchesInView = NO;
    [self.rejectImageView addGestureRecognizer:tapRejectImageViewGesture];
}






@end
