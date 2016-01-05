//
//  UserCardView.h
//  IgorBizi@mail.ru
//
//  Created by IgorBizi@mail.ru on 5/11/15.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableCardView.h"
 

@interface CardView : DraggableCardView <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rejectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *approveImageView;
@end
