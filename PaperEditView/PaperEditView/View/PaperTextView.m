//
//  PaperTextView.m
//  PaperEditView
//
//  Created by ray on 16/6/16.
//  Copyright © 2016年 ray. All rights reserved.
//

#import "PaperTextView.h"
#import "BlocksKit+UIKit.h"

@interface PaperTextView() <UITextViewDelegate>

@end

@implementation PaperTextView {
    @private
    BOOL _haveBeginEditing;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        self.delegate = self;
        self.editable = YES;
        self.scrollEnabled = NO;
        
        __weak typeof(self) wSelf = self;
        [self addGestureRecognizer:[[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer * _Nonnull sender, UIGestureRecognizerState state, CGPoint location) {
            UISwipeGestureRecognizer *recognizer = (UISwipeGestureRecognizer *)sender;
            if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
                CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:wSelf.layer.position];
                [path addLineToPoint:({
                    CGPoint p = wSelf.layer.position;
                    p.x += 5;
                    p;
                })];
                moveAnim.duration = 0.25;
                moveAnim.path = path.CGPath;
                [wSelf.layer addAnimation:moveAnim forKey:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (nil != wSelf && nil != wSelf.textViewDidSwipedRightBlock) {
                        wSelf.textViewDidSwipedRightBlock();
                    }
                });
            }
        }]];
    }
    return self;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _haveBeginEditing = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (nil != self.textViewDidChangeBlock) {
        self.textViewDidChangeBlock(self);
    }
    if (_haveBeginEditing) {
        _haveBeginEditing = NO;
        if (self.textViewWillFirstChangeAfterBeginEditing) {
            self.textViewWillFirstChangeAfterBeginEditing();
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (nil != self.textViewShouldReturnBlock) {
            return self.textViewShouldReturnBlock(range);
        }
    }
    if ([text isEqualToString:@""]) {
        if (nil != self.textViewShouldDeleteBlock) {
            return self.textViewShouldDeleteBlock(range);
        }
    }
    return YES;
}

@end
