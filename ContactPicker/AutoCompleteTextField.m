//
//  MQAutoCompleteTextField.m
//  Meal Queue
//
//  Created by Jordan Focht on 2/17/14.
//  Copyright (c) 2014 Jordan Focht. All rights reserved.
//

#import "AutoCompleteTextField.h"

@implementation AutoCompleteTextField

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    if (self.hideCaret) {
        return CGRectZero;
    } else {
        return [super caretRectForPosition:position];
    }
}

- (void)dictationRecordingDidEnd
{
    if (self.autoCompleteDelegate) {
        [self.autoCompleteDelegate textFieldDictationRecordingDidEnd:self];
    }
}

- (void)insertDictationResult:(NSArray *)dictationResult
{
    if (self.autoCompleteDelegate) {
        [self.autoCompleteDelegate textField:self insertDictationResult:dictationResult];
    }
}

// Tap into the UITextView gesture recognizer, so that we can detect touches on the text view.
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [super addGestureRecognizer:gestureRecognizer];
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)gestureRecognizer;
        if ([tgr numberOfTapsRequired] == 1 &&
            [tgr numberOfTouchesRequired] == 1) {
            [tgr addTarget:self action:@selector(_handleOneFingerTap:)];
        }
    }
}
- (void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)gestureRecognizer;
        if ([tgr numberOfTapsRequired] == 1 &&
            [tgr numberOfTouchesRequired] == 1) {
            [tgr removeTarget:self action:@selector(_handleOneFingerTap:)];
        }
    }
    [super removeGestureRecognizer:gestureRecognizer];
}

- (void)_handleOneFingerTap:(UITapGestureRecognizer *)tgr
{
    [self.autoCompleteDelegate didTapTextField:self];
    
}

@end
