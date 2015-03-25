//
//  MQAutoCompleteTextField.h
//  Meal Queue
//
//  Created by Jordan Focht on 2/17/14.
//  Copyright (c) 2014 Jordan Focht. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AutoCompleteTextFieldDelegate
- (void)textFieldDictationRecordingDidEnd:(UITextField*)textField;
- (void)textField:(UITextField*)textField insertDictationResult:(NSArray *)dictationResult;
- (void)didTapTextField:(UITextField*)textField;
@end

@interface AutoCompleteTextField : UITextField
@property() BOOL hideCaret;
@property() id<AutoCompleteTextFieldDelegate> autoCompleteDelegate;
@end

