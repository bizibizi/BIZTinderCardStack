//
//  CardView.h
//  BIZTinderCardStack
//
//  Created by IgorBizi@mail.ru on 5/18/15.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class DraggableCardView, OverlayView;


typedef enum {
    NoneSwipeDirection = 0,
    LeftSwipeDirection = 1,
    RightSwipeDirection,
    UpSwipeDirection,
    DownSwipeDirection
} SwipeDirection;


@protocol DraggableCardViewDelegate <NSObject>
@optional
- (void)cardViewWillBeginSwipeToDirection:(SwipeDirection)swipeDirection;
- (void)cardView:(DraggableCardView *)cardView didEndSwipeToDirection:(SwipeDirection)swipeDirection;
//! Block swipe
- (NSArray *)shouldBlockSwipeDirections;

@end


//! View that can be draggable in 4 directions by swipe of by button. View have overlay
@interface DraggableCardView : UIView

//! Delegate that is responsible for dragging
@property (nonatomic, strong) id <DraggableCardViewDelegate> delegateOfDragging;

//! Must call super in subclasses
- (void)setup;

//! Manage dragg gesture 
@property (nonatomic) BOOL gesturesEnabled;

//! Notifies while animation of moving left/right is active
@property (nonatomic) BOOL isAnimatingMoving;
//! Flag appers as YES then cardView finished moving
@property (nonatomic) BOOL movingAnimaionDidFinish;


@property (nonatomic, strong) UIImage *rightOverlayImage;
@property (nonatomic, strong) UIImage *leftOverlayImage;

// * Events for manually use. Call that method to perform action on cardView

- (void)rightButtonAction;
- (void)leftButtonAction;
- (void)upButtonAction;
- (void)downButtonAction;



@end
