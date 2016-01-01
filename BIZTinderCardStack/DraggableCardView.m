//
//  CardView.m
//  BIZTinderCardStack
//
//  Created by IgorBizi@mail.ru on 5/18/15.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import "DraggableCardView.h"
#import "OverlayView.h"


#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height


// This constant represent how quickly the view shrinks.
// The view will shrink when is beign moved out the visible
// area.
// A Higher value means slower shrinking
#define SCALE_QUICKNESS 4.0

// This constant represent how much the view shrinks.
// A Higher value means less shrinking
#define SCALE_MAX .93

// This constant represent the rotation angle
#define ROTATION_ANGLE M_PI / 8

// This constant represent the maximum rotation angle
// allowed in radiands.
// A higher value enables more rotation for the view
#define ROTATION_MAX 1

// This constant defines how fast
// the rotation should be.
// A higher values means a faster rotation.
#define ROTATION_QUICKNESS 320

// Used at animation time
#define k_AnimationTime 0.4


@interface DraggableCardView ()

// * Holds screenshot of self for view transform
@property (nonatomic, strong) UIView *screenshotView;
// * Used Pan to detect direction of dragging
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
// * Startting center coordinate in superveiew
@property (nonatomic) CGPoint originalCenterPoint;
// * Overlay while dragging
@property (nonatomic, strong) OverlayView *overlayView;

@end


@implementation DraggableCardView
{
    // * Offsets of drag from self center point
    CGFloat xFromCenter;
    CGFloat yFromCenter;
    // * Distance from the center, after acrossing which - applies the action to self.
    CGFloat k_ACTION_MARGIN_X;
    CGFloat k_ACTION_MARGIN_Y;
}


#pragma mark - LifeCycle


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
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
    self.gesturesEnabled = YES;
}


#pragma mark - Dragging


// * Make a screenshot of self if further transform required
// * Do not need to handle transform of all subviews
- (void)createScreenshotOfSelf
{
    self.screenshotView = [self snapshotViewAfterScreenUpdates:NO];
    self.screenshotView.frame = self.bounds;
    [self addSubview:self.screenshotView];
    
    // * Create shadow
    self.screenshotView.layer.cornerRadius = 4.0;
    self.screenshotView.layer.shadowRadius = 2.0;
    self.screenshotView.layer.shadowOpacity = 0.5;
    self.screenshotView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    // * Improve app performance using shadowPath
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.screenshotView.layer.shadowPath = path.CGPath;
    self.screenshotView.layer.masksToBounds = NO;
    self.screenshotView.contentMode = UIViewContentModeRedraw;
    
    // * Hide all other views, that are also be trasformed
    for (UIView *v in self.subviews) {
        if (![v isEqual:self.screenshotView]) {
            v.hidden = YES;
        }
    }
    
    // * Add overlayView to screenshotView
    [self createOverlayView];
}

- (void)createOverlayView
{
    if (self.overlayView) {
        [self.overlayView removeFromSuperview];
    }
    
    self.overlayView = [[OverlayView alloc] initWithFrame:self.screenshotView.bounds];
    self.overlayView.leftImage = self.leftOverlayImage;
    self.overlayView.rightImage = self.rightOverlayImage;
    [self.screenshotView addSubview:self.overlayView];
}

- (void)restoreOriginSelf_animationBlock
{
    self.screenshotView.layer.cornerRadius = 0.0;
    self.screenshotView.layer.shadowRadius = 0.0;
    self.screenshotView.layer.shadowOpacity = 0.0;
}

- (void)restoreOriginSelf_completionBlock
{
    for (UIView *v in self.subviews) {
        if (![v isEqual:self.screenshotView]) {
            v.hidden = NO;
        }
    }
    
    [self.screenshotView removeFromSuperview];
}

// * Called when you move your finger across the screen.
// * Called many times a second
-(void)handlePanGesture:(UIPanGestureRecognizer *)panRecognizer
{
    // * This extracts the coordinate data from your swipe movement. How much did fingers move.
    // * Positive for right swipe, negative for left
    xFromCenter = [panRecognizer translationInView:self].x;
    // * Positive for up swipe, negative for down
    yFromCenter = [panRecognizer translationInView:self].y;
    
    // * Checks what state the gesture is in.
    switch (panRecognizer.state) {

        case UIGestureRecognizerStateBegan:
        {
            // * Get sizes of the view that already on the screen
            // * Then view draged more then half in any direction - move view out of screen
            CGFloat actionMargin = MIN(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
            k_ACTION_MARGIN_X = actionMargin;
            k_ACTION_MARGIN_Y = actionMargin;
            
            // * Save origin point to restore if user will cancel swiping
            self.originalCenterPoint = self.center;

            // * Make screenshot of self to further transform
            [self createScreenshotOfSelf];
            
            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            // * Rotates the view and changes its scale and position
            [self animateView];
            
            break;
        }
            
        // * Gesture is ended - it's time for actions
        case UIGestureRecognizerStateEnded:
        {
            [self updateResizing];
            
            [self detectSwipeDirection];
            
            break;
        }
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
    }
}

// * Rotates the view and changes its scale and position
// * Now we apply this to screenshotView
- (void)animateView
{
    // Dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
    CGFloat rotationQuickness = MIN(xFromCenter / ROTATION_QUICKNESS, ROTATION_MAX);
    
    // Change the rotation in radians
    CGFloat rotationAngle = (CGFloat) (ROTATION_ANGLE * rotationQuickness);
    
    // the height will change when the view reaches certain point
    CGFloat scale = MAX(1 - fabs(rotationQuickness) / SCALE_QUICKNESS, SCALE_MAX);
    
    // move the object center depending on the coordinate
    self.center = CGPointMake(self.originalCenterPoint.x + xFromCenter,
                              self.originalCenterPoint.y + yFromCenter);
    
    // rotate by the angle
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(rotationAngle);
    
    // scale depending on the rotation
    CGAffineTransform scaleTransform = CGAffineTransformScale(rotateTransform, scale, scale);
    
    // apply transformations
    self.transform = scaleTransform;
    
    // * Update overlay above screenshotView
    [self updateOverlayView];
}


- (void)updateOverlayView
{
    // * Set overlay image
    if (xFromCenter > 0) {
        self.overlayView.mode = OverlayApprove;
        
    } else if (xFromCenter < 0) {
        self.overlayView.mode = OverlayReject;
    } 
    
    // * Update transperancy in left/right directions
    if (fabs(xFromCenter) > fabs(yFromCenter)) {
        
        CGFloat transperancy = MIN(fabs(xFromCenter)/125, 1.0);
        [self.overlayView setSignsTransperancy:transperancy];
        [self.overlayView setBackgroundTransperancy:transperancy];
    } else {
        // * Update transperancy in up/down directions
        CGFloat transperancy = MIN(fabs(yFromCenter)/200, 0.8);
        [self.overlayView setSignsTransperancy:0.0];
        [self.overlayView setBackgroundTransperancy:transperancy];
    }
}

// * While view was transformed it could change its sizes then it will be restored to original center point, need to restore it's sizes
- (void)updateResizing
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleRightMargin;
}

// * With all the values fetched from the pan gesture, get the direction of the swipe
- (void)detectSwipeDirection
{
    SwipeDirection swipeDirection = NoneSwipeDirection;
    
    if (xFromCenter > k_ACTION_MARGIN_X) {
        swipeDirection = RightSwipeDirection;
    } else if (xFromCenter < -k_ACTION_MARGIN_X) {
        swipeDirection = LeftSwipeDirection;
    } else if (yFromCenter > k_ACTION_MARGIN_Y) {
        swipeDirection = DownSwipeDirection;
    } else if (yFromCenter < -k_ACTION_MARGIN_Y) {
        swipeDirection = UpSwipeDirection;
    }
    
    // * Move out of screen or return back to center if user does not reached the margin of action or swipe direction is blocked
    if ([self.delegateOfDragging respondsToSelector:@selector(shouldBlockSwipeDirections)] &&
        [[self.delegateOfDragging shouldBlockSwipeDirections] containsObject:@(swipeDirection)])
    {
        [self performCenterAnimation];
    } else if (swipeDirection == RightSwipeDirection) {
        [self performRightAnimation];
    } else if (swipeDirection == LeftSwipeDirection) {
        [self performLeftAnimation];
    } else if (swipeDirection == DownSwipeDirection) {
        [self performDownAnimation];
    } else if (swipeDirection == UpSwipeDirection) {
        [self performUpAnimation];
    } else {
        [self performCenterAnimation];
    }
}


#pragma mark - Finish animations


- (void)performCenterAnimation
{
    // * OverlayView
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.overlayView setSignsTransperancy:0.0];
                         [self.overlayView setBackgroundTransperancy:0.0];
                     } completion:^(BOOL finished) {
                         [self.overlayView removeFromSuperview];
                     }];
    
    // * ScreenshotView and restoring original self
    [UIView animateWithDuration:k_AnimationTime * 2
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         // * Restore origin state
                         self.center = self.originalCenterPoint;
                         self.transform = CGAffineTransformIdentity;
                         
                         [self restoreOriginSelf_animationBlock];
                         
                     } completion:^(BOOL finished) {
                         
                         [self restoreOriginSelf_completionBlock];
                     }];
}

- (void)performRightAnimation
{
    CGPoint finishPoint = CGPointMake(ScreenWidth*2, 2 * yFromCenter + self.originalCenterPoint.y);
    [self performAnimationBlockForSwipesWithCenterPoint:finishPoint withSwipeDirection:RightSwipeDirection];
}

- (void)performLeftAnimation
{
    CGPoint finishPoint = CGPointMake(-ScreenWidth, 2 * yFromCenter + self.originalCenterPoint.y);
    [self performAnimationBlockForSwipesWithCenterPoint:finishPoint withSwipeDirection:LeftSwipeDirection];
}

- (void)performUpAnimation
{
    CGPoint finishPoint = CGPointMake(ScreenWidth/2, -ScreenHeight);
    [self performAnimationBlockForSwipesWithCenterPoint:finishPoint withSwipeDirection:UpSwipeDirection];
}

- (void)performDownAnimation
{
    CGPoint finishPoint = CGPointMake(ScreenWidth/2, ScreenHeight*2);
    [self performAnimationBlockForSwipesWithCenterPoint:finishPoint withSwipeDirection:DownSwipeDirection];
}

- (void)performAnimationBlockForSwipesWithCenterPoint:(CGPoint)point withSwipeDirection:(SwipeDirection)swipeDirection
{
    [self willBeginSwipeToDirection:swipeDirection];
    
    [UIView animateWithDuration:k_AnimationTime
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.center = point;
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [self didEndSwipeToDirection:swipeDirection];
                     }];
}

// * Delay used for swipes with buttons
- (void)performRightAnimationButtonAction
{
    self.isAnimatingMoving = YES;
    
    // * Animation with screenshot of self
    [self createScreenshotOfSelf];
    
    // * Overlay
    self.overlayView.mode = OverlayApprove;
    CGFloat transperancy = 1.0;
    [self.overlayView setSignsTransperancy:transperancy];
    
    CGPoint finishPoint = CGPointMake(ScreenWidth*2, ScreenHeight * 0.3);
    [self willBeginSwipeToDirection:RightSwipeDirection];
    
    [UIView animateWithDuration:k_AnimationTime*2
                          delay:k_AnimationTime*2
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         
                         // * Coordinates, transform
                        self.center = finishPoint;
                        self.transform = CGAffineTransformMakeRotation(1);;
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [self didEndSwipeToDirection:RightSwipeDirection];
                     }];
}

- (void)performLeftAnimationButtonAction
{
    self.isAnimatingMoving = YES;
    
    // * Animation with screenshot of self
    [self createScreenshotOfSelf];
    
    // * Overlay
    self.overlayView.mode = OverlayReject;
    CGFloat transperancy = 1.0;
    [self.overlayView setSignsTransperancy:transperancy];
    
    CGPoint finishPoint = CGPointMake(-ScreenWidth, ScreenHeight * 0.3);
    [self willBeginSwipeToDirection:LeftSwipeDirection];
    
    [UIView animateWithDuration:k_AnimationTime*2
                          delay:k_AnimationTime*2
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         // * Coordinates, transform
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [self didEndSwipeToDirection:LeftSwipeDirection];
                    }];
}

- (void)performUpAnimationButtonAction
{
    CGPoint finishPoint = CGPointMake(ScreenWidth/2, -ScreenHeight);
    [self performAnimationBlockForUpAndDownButtonActionWithCenterPoint:finishPoint withSwipeDirection:UpSwipeDirection];
}

- (void)performDownAnimationButtonAction
{
    CGPoint finishPoint = CGPointMake(ScreenWidth/2, ScreenHeight*2);
    [self performAnimationBlockForUpAndDownButtonActionWithCenterPoint:finishPoint withSwipeDirection:DownSwipeDirection];
}

- (void)performAnimationBlockForUpAndDownButtonActionWithCenterPoint:(CGPoint)point withSwipeDirection:(SwipeDirection)swipeDirection
{
    [self willBeginSwipeToDirection:swipeDirection];
    
    [UIView animateWithDuration:k_AnimationTime*2
                          delay:k_AnimationTime/2
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.center = point;
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [self didEndSwipeToDirection:swipeDirection];
                     }];
}


#pragma mark - Events


- (void)rightButtonAction
{
    [self performRightAnimationButtonAction];
}

- (void)leftButtonAction
{
    [self performLeftAnimationButtonAction];
}

- (void)upButtonAction
{
    [self performUpAnimationButtonAction];
}

- (void)downButtonAction
{
    [self performDownAnimationButtonAction];
}

- (void)setGesturesEnabled:(BOOL)gesturesEnabled
{
    _gesturesEnabled = gesturesEnabled;
    
    if (gesturesEnabled) {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:self.panGestureRecognizer];
    } else {
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
            [self removeGestureRecognizer:recognizer];
        }
    }
}


#pragma mark - Delegate assistants


// * Use the delegate assistants to find out whether delegate takes this method
- (void)willBeginSwipeToDirection:(SwipeDirection)swipeDirection
{    
    if ([self.delegateOfDragging respondsToSelector:@selector(cardViewWillBeginSwipeToDirection:)]) {
        [self.delegateOfDragging cardViewWillBeginSwipeToDirection:swipeDirection];
    }
}

- (void)didEndSwipeToDirection:(SwipeDirection)swipeDirection
{
    self.isAnimatingMoving = NO;
    self.movingAnimaionDidFinish = YES;
    
    if ([self.delegateOfDragging respondsToSelector:@selector(cardView:didEndSwipeToDirection:)]) {
        [self.delegateOfDragging cardView:self didEndSwipeToDirection:swipeDirection];
    }
}


@end
