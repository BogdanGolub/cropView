//
//  TOCropToolbar.h
//
//  Copyright 2015-2018 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropToolbar.h"

#define TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT     0   // convenience debug toggle

@interface TOCropToolbar()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIButton *rotateButton; // defaults to counterclockwise button for legacy compatibility

@end

@implementation TOCropToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backgroundView];
    
    _flipXButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _flipXButton.contentMode = UIViewContentModeCenter;
    _flipXButton.tintColor = [UIColor blackColor];
    [_flipXButton setImage:[UIImage imageNamed:@"ic_vertical_black"] forState:UIControlStateNormal];
    [_flipXButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flipXButton];
    
    _flipYButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _flipYButton.contentMode = UIViewContentModeCenter;
    _flipYButton.tintColor = [UIColor blackColor];
    [_flipYButton setImage:[UIImage imageNamed:@"ic_horizontal_black"] forState:UIControlStateNormal];
    [_flipYButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flipYButton];
    
    _rotateClockwiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rotateClockwiseButton.contentMode = UIViewContentModeCenter;
    _rotateClockwiseButton.tintColor = [UIColor blackColor];
    [_rotateClockwiseButton setImage:[UIImage imageNamed:@"ic_right_black"] forState:UIControlStateNormal];
    [_rotateClockwiseButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rotateClockwiseButton];
    
    _rotateCounterclockwiseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _rotateCounterclockwiseButton.contentMode = UIViewContentModeCenter;
    _rotateCounterclockwiseButton.tintColor = [UIColor blackColor];
    [_rotateCounterclockwiseButton setImage:[UIImage imageNamed:@"ic_left_black"] forState:UIControlStateNormal];
    [_rotateCounterclockwiseButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rotateCounterclockwiseButton];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    
    CGRect frame = self.bounds;
    frame.origin.x -= self.backgroundViewOutsets.left;
    frame.size.width += self.backgroundViewOutsets.left;
    frame.size.width += self.backgroundViewOutsets.right;
    frame.origin.y -= self.backgroundViewOutsets.top;
    frame.size.height += self.backgroundViewOutsets.top;
    frame.size.height += self.backgroundViewOutsets.bottom;
    self.backgroundView.frame = frame;
    
#if TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT
    static UIView *containerView = nil;
    if (!containerView) {
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor redColor];
        containerView.alpha = 0.1;
        [self addSubview:containerView];
    }
#endif

        CGFloat insetPadding = 0.0f;
        // Work out the cancel button frame
        CGRect leadingFrame = CGRectZero;
        leadingFrame.size.height = 44.0f;
        leadingFrame.size.width = MIN(self.frame.size.width / 3.0, 15.5);
        leadingFrame.origin.x = insetPadding;

        // Work out the Done button frame
        CGRect trailingFrame = CGRectZero;
        trailingFrame = leadingFrame;
        trailingFrame.size.width = MIN(self.frame.size.width / 3.0, 15.5);
        
        trailingFrame.origin.x = boundsSize.width - (trailingFrame.size.width + insetPadding);
        
        // Work out the frame between the two buttons where we can layout our action buttons
        CGFloat x = CGRectGetMaxX(leadingFrame);
        CGFloat width = 0.0f;
        
        width = CGRectGetMinX(trailingFrame) - CGRectGetMaxX(leadingFrame);
        
        CGRect containerRect = CGRectIntegral((CGRect){x,frame.origin.y,width,44.0f});

#if TOCROPTOOLBAR_DEBUG_SHOWING_BUTTONS_CONTAINER_RECT
        containerView.frame = containerRect;
#endif
        
        CGSize buttonSize = (CGSize){44.0f,44.0f};
        
        NSMutableArray *buttonsInOrderHorizontally = [NSMutableArray new];
        
        [buttonsInOrderHorizontally addObject:self.flipXButton];
        [buttonsInOrderHorizontally addObject:self.flipYButton];
        [buttonsInOrderHorizontally addObject:self.rotateClockwiseButton];
        [buttonsInOrderHorizontally addObject:self.rotateCounterclockwiseButton];

        [self layoutToolbarButtons:buttonsInOrderHorizontally withSameButtonSize:buttonSize inContainerRect:containerRect];
}

// The convenience method for calculating button's frame inside of the container rect
- (void)layoutToolbarButtons:(NSArray *)buttons withSameButtonSize:(CGSize)size inContainerRect:(CGRect)containerRect {
    NSInteger count = buttons.count;
    CGFloat fixedSize = size.width;
    CGFloat maxLength = CGRectGetWidth(containerRect);
    CGFloat padding = (maxLength - fixedSize * count) / (count);
    padding += 3;
    for (NSInteger i = 0; i < count; i++) {
        UIView *button = buttons[i];
        CGFloat sameOffset = fabs(CGRectGetHeight(containerRect)-CGRectGetHeight(button.bounds));
        CGFloat diffOffset = containerRect.origin.x + i * (fixedSize + padding);
        CGPoint origin = CGPointMake(diffOffset, sameOffset);
        origin.x += CGRectGetMinX(containerRect);
        button.frame = (CGRect){origin, size};
    }
}

- (void)buttonTapped:(id)button {
    if (button == self.flipXButton && self.flipXButtonTapped) {
        self.flipXButtonTapped();
    } else if (button == self.flipYButton && self.flipYButtonTapped) {
        self.flipYButtonTapped();
    } else if (button == self.rotateCounterclockwiseButton && self.rotateCounterclockwiseButtonTapped) {
        self.rotateCounterclockwiseButtonTapped();
    } else if (button == self.rotateClockwiseButton && self.rotateClockwiseButtonTapped) {
        self.rotateClockwiseButtonTapped();
    }
}

- (void)setRotateCounterClockwiseButtonHidden:(BOOL)rotateButtonHidden {
    if (_rotateCounterclockwiseButtonHidden == rotateButtonHidden)
        return;
    
    _rotateCounterclockwiseButtonHidden = rotateButtonHidden;
    [self setNeedsLayout];
}

#pragma mark - Accessors -

- (void)setRotateClockwiseButtonHidden:(BOOL)rotateClockwiseButtonHidden {
    if (_rotateClockwiseButtonHidden == rotateClockwiseButtonHidden) {
        return;
    }
    
    _rotateClockwiseButtonHidden = rotateClockwiseButtonHidden;
    
    [self setNeedsLayout];
}

- (UIButton *)rotateButton {
    return self.rotateCounterclockwiseButton;
}

- (void)setStatusBarHeightInset:(CGFloat)statusBarHeightInset {
    _statusBarHeightInset = statusBarHeightInset;
    [self setNeedsLayout];
}

@end
