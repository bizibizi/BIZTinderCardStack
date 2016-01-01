# BIZTinderCardStack

*Wait for gif presentation, it's loading...*

![alt tag](https://github.com/bizibizi/BIZTinderCardStack/blob/master/presentation.gif)


BIZTinderCardStack is a stack of cards simular to Tinder app's stack. That stack could be moved by gesture or by click. Every card could have overlay.


# Installation

### Manually
 - Copy BIZTinderCardStack folder to your project 


# Usage

- create and setup your custom class for ```CardView``` with XIB, inherit that from ```DraggableCardView```
```objective-c
@interface CardView : DraggableCardView <UIGestureRecognizerDelegate>
@end
```
- For moving by click add events to controls in your custom ```CardView``` class
```objective-c
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
```

- in subclass of your UIViewController create outlet that will be present placeholder view for initial position of cards. On it's place  the stack of cards will be placed.
```objective-c
@interface ViewController ()  
@property (weak, nonatomic) IBOutlet UIView *cardViewPlaceholder;
@end
```

- in subclass of your UIViewController create stack of the cards 
```objective-c
@interface ViewController () <DraggableCardViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *cardViewPlaceholder;
@property (nonatomic, strong) NSMutableArray *cardViews; // of CardViews
@end

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
```


# Contact

Igor Bizi
- https://www.linkedin.com/in/igorbizi
- igorbizi@mail.ru


# License
 
The MIT License (MIT)

Copyright (c) 2015-present Igor Bizi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
