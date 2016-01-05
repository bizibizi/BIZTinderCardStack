//
//  ViewController.m
//  Example
//
//  Created by IgorBizi@mail.ru on 12/16/15.
//  Copyright © 2015 IgorBizi@mail.ru. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"


@interface ViewController () <DraggableCardViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *cardViewPlaceholder;

@property (nonatomic, strong) NSMutableArray *cardViews; // of CardViews
@end


@implementation ViewController


#pragma mark - LifeCycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cardViews = [NSMutableArray array];
    self.cardViewPlaceholder.hidden = YES;
    [self initCardViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self layoutCardViews];
}

- (void)initCardViews
{
    for (NSUInteger i = 0; i < 20; i++)
    {
        CardView *cardView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil] firstObject];
        cardView.frame = self.cardViewPlaceholder.frame;
        cardView.delegateOfDragging = self;
        cardView.rightOverlayImage = [UIImage imageNamed:@"no.jpg"];
        cardView.leftOverlayImage = [UIImage imageNamed:@"yes.png"];
        cardView.titleLabel.text = [NSString stringWithFormat:@"#%lu", (unsigned long)i+1];
        [self.cardViews addObject:cardView];
    }
    
    for (CardView *cardView in self.cardViews.reverseObjectEnumerator)
    {
        [self.view addSubview:cardView];
    }
}

- (void)layoutCardViews
{
    for (CardView *i in self.cardViews)
    {
        i.frame = self.cardViewPlaceholder.frame;
    }
}


@end
