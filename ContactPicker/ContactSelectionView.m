    //
//  MQIngredientModalView.m
//  Meal Queue
//
//  Created by Jordan Focht on 12/23/13.
//  Copyright (c) 2013 Jordan Focht. All rights reserved.
//

#import "ContactSelectionView.h"

static const int MIN_TEXT_WIDTH = 75.0f;
static const int COMMA_WIDTH = 5.0f;
static const int LEFT_OFFSET = 10.0f;
static const int SMALL_TEXT_EXTRA_MARGIN = 1.0f;
static const int HORIZONTAL_MARGIN = 5.0f;
static const int LEFT_TEXT_X = LEFT_OFFSET + HORIZONTAL_MARGIN;
static const int LINE_HEIGHT = 26.5f;
static const int CORNER_RADIUS = 6.0f;

#define PLACEHOLDER_COLOR [UIColor lightGrayColor]
#define TEXT_COLOR [UIColor blackColor]
#define PLACEHOLDER_TEXT @""

// TODO add top padding to view
// TODO embed in another view for padding
// TODO fix selected item button color
// TODO slim down ingredients view when keyboard displays

typedef enum DeleteButtonStatus : NSUInteger {
    DeleteButtonStatusNoAction,
    DeleteButtonStatusSelected,
    DeleteButtonStatusDeleted
} DeleteButtonStatus;

@interface ContactSelectionView ()

@property() NSUInteger scrollViewTop;
@property() BOOL enableAutoCompletion;
@property(nonatomic) UILabel* toLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightConstraint;

@end

@implementation ContactSelectionView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame backgroundImage:nil];
}

- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage*)backgroundImage
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{
    self.toLabel = [[UILabel alloc] init];
    self.toLabel.text = @"To:";
    self.toLabel.textColor = [UIColor lightGrayColor];
    _lineCount = 1;
    
    self.ingredientField = [[AutoCompleteTextField alloc] init];
    self.ingredientField.font = [UIFont systemFontOfSize:17];
    self.ingredientField.textColor = TEXT_COLOR;
    self.ingredientField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.ingredientField.delegate = self;
    self.ingredientField.autoCompleteDelegate = self;
    self.ingredientField.returnKeyType = UIReturnKeyNext;
    UIColor* placeholderColor = PLACEHOLDER_COLOR;
    NSDictionary *placeholderAttrs = @{NSForegroundColorAttributeName: placeholderColor};
    self.ingredientField.attributedPlaceholder = [[NSAttributedString alloc]
                                                  initWithString:PLACEHOLDER_TEXT
                                                  attributes:placeholderAttrs];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, LINE_HEIGHT);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.ingredientField];
    
    
    [self.scrollView addSubview:self.toLabel];
    [self.scrollView addSubview:self.ingredientField];
}

- (void)reloadData
{
    if ([self.selectionDataSource numberOfItemsSelectedInContactSelectionView:self] == 0) {
        self.ingredientField.text = @"";
        self.enableAutoCompletion = NO;
    } else {
        self.ingredientField.text = @"\u200B";
    }
    [self.selectionDelegate contactSelectionView:self didChangeText:@""
     ];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [UIView setAnimationsEnabled:NO];
    int selIndex = 0;
    int xPos = LEFT_OFFSET;
    int yPos = 0.0;

    // Add search image if no selections exist
    NSUInteger selectionCount = [self.selectionDataSource numberOfItemsSelectedInContactSelectionView:self];
    xPos += HORIZONTAL_MARGIN;
    [self.toLabel sizeToFit];
    int searchYPos = yPos + (LINE_HEIGHT - self.toLabel.frame.size.height) / 2;
    self.toLabel.frame = CGRectMake(xPos, searchYPos, self.toLabel.frame.size.width, self.toLabel.frame.size.height);
    xPos += self.toLabel.frame.size.width;

    long nextButtonIndex = -1;
    for (int i = 0; i < selectionCount; i++) {
        NSString* ingredient = [self.selectionDataSource contactSelectionView:self itemAtIndex:i];
        nextButtonIndex = [self indexOfViewOfClass:[UIButton class] afterIndex:nextButtonIndex];
        if (nextButtonIndex == -1) {
            [self addButtonWithText:ingredient];
            nextButtonIndex = self.scrollView.subviews.count - 1;
        }
        UILabel* commaLabel = [self.scrollView.subviews objectAtIndex:nextButtonIndex - 1];
        UIButton* button = [self.scrollView.subviews objectAtIndex:nextButtonIndex];

        [button setTitle:ingredient forState:UIControlStateNormal];
        [button sizeToFit];

        // Layout button
        int buttonY = yPos;
        int buttonX = xPos;
        int rightX = buttonX + button.frame.size.width + 2 * HORIZONTAL_MARGIN + COMMA_WIDTH;
        if (rightX > self.frame.size.width) {
            buttonX = LEFT_OFFSET;
            buttonY += LINE_HEIGHT;
        }

        int buttonWidth;
        NSString* text = button.titleLabel.text;
        if (text.length < 4) {
            NSDictionary *textAttrs = @{NSForegroundColorAttributeName: TEXT_COLOR};
            int buttonMargin = 2 * (HORIZONTAL_MARGIN + SMALL_TEXT_EXTRA_MARGIN);
            buttonWidth = [text sizeWithAttributes:textAttrs].width + buttonMargin;
        } else {
            buttonWidth = button.frame.size.width + 2 * HORIZONTAL_MARGIN;
        }
        button.frame = CGRectMake(buttonX, buttonY, buttonWidth, LINE_HEIGHT);
        xPos = buttonX + buttonWidth;
        yPos = buttonY;

        // Layout comma
        int commaX = buttonX + button.frame.size.width - HORIZONTAL_MARGIN;
        CGRect commaFrame = CGRectMake(commaX, buttonY, COMMA_WIDTH, button.frame.size.height);
        [commaLabel setFrame:commaFrame];
        commaLabel = nil;
        selIndex++;
    }

    // Delete views that aren't needed anymore
    nextButtonIndex = [self indexOfViewOfClass:[UIButton class] afterIndex:nextButtonIndex];
    while (nextButtonIndex > -1) {
        // Remove unneeded button
        [[self.scrollView.subviews objectAtIndex:nextButtonIndex] removeFromSuperview];
        // Remove unneeded comma
        [[self.scrollView.subviews objectAtIndex:nextButtonIndex - 1] removeFromSuperview];
        nextButtonIndex = [self indexOfViewOfClass:[UIButton class] afterIndex:nextButtonIndex];
    }

    if ((selectionCount == 0 || !self.ingredientField.editing) &&
        [self.ingredientField.text isEqualToString:@"\u200B"]) {
        self.ingredientField.text = @"";
    }

    // Layout Text View
    int rightX = xPos + MIN_TEXT_WIDTH;
    int textX = xPos + HORIZONTAL_MARGIN;
    int textY = yPos;
    if (rightX > self.frame.size.width) {
        textX = LEFT_TEXT_X;
        textY += LINE_HEIGHT;
    }
    int width = self.frame.size.width - HORIZONTAL_MARGIN - textX - LEFT_OFFSET;
    CGRect textFieldFrame = CGRectMake(textX, textY, width, LINE_HEIGHT);
    self.ingredientField.frame = textFieldFrame;

    // Resize scroll view
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, textY + LINE_HEIGHT);

    // Re-frame views
    
    NSUInteger newLineCount = roundf(self.scrollView.contentSize.height / LINE_HEIGHT);
    if (self.lineCount != newLineCount) {
        _lineCount = newLineCount;
        [self.selectionDelegate contactSelectionView:self didChangeLineCount:newLineCount];
    }
    [super layoutSubviews];
    
    [UIView setAnimationsEnabled:YES];
}

- (DeleteButtonStatus)deleteButton
{
    // Delete the currently selected button.
    UILabel* comma = nil;
    for (UIView* view in self.scrollView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            comma = (UILabel*)view;
        }
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* field = (UIButton*)view;
            if (field.selected) {
                [self.selectionDelegate contactSelectionView:self removeSelection:field.titleLabel.text];
                [self setNeedsLayout];
                field.selected = false;
                self.ingredientField.hideCaret = NO;
                return DeleteButtonStatusDeleted;
            }
        }
    }

    // If no button was selected, then select the last button.
    for (long i = (self.scrollView.subviews.count - 1); i >= 0; i--) {
        UIView* view = [self.scrollView.subviews objectAtIndex:i];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* field = (UIButton*)view;
            field.selected = YES;
            return DeleteButtonStatusSelected;
        }
    }
    return DeleteButtonStatusNoAction;
}


- (void)addButtonWithText:(NSString*)text
{

    // Build Button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    
    UIImage* selectedImage = [self imageWithColor:self.tintColor];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.selected = NO;
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = CORNER_RADIUS;
    [button addTarget:self action:@selector(didPushUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Build Comma
    UILabel* commaLabel = [[UILabel alloc] init];
    [commaLabel setText:@","];

    // Layout views
    [self.scrollView addSubview:commaLabel];
    [self.scrollView addSubview:button];
}

- (long)indexOfViewOfClass:(__unsafe_unretained Class)class afterIndex:(NSUInteger)index
{
    for (long i = index + 1; i < self.scrollView.subviews.count; i++) {
        id view = [self.scrollView.subviews objectAtIndex:i];
        if ([view isKindOfClass:class]) {
            return i;
        }
    }
    return -1;
}

- (UIImage*)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);

    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


- (void)didPushUpInsideButton:(UIButton*)sender
{
    BOOL selected = !sender.selected;
    for (UIView* view in self.scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton*)view).selected = NO;
        }
    }
    if (selected) {
        self.ingredientField.text = @"\u200B";
        self.enableAutoCompletion = NO;
        // notify the delegate
    }
    sender.selected = YES;
    [self.ingredientField becomeFirstResponder];
    self.ingredientField.hideCaret = YES;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"\u200B"]) {
        textField.text = @"";
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSUInteger count = [self.selectionDataSource numberOfItemsSelectedInContactSelectionView:self];
    if ([textField.text isEqualToString:@""] && count) {
        textField.text = @"\u200B";
    }
}

- (void)textFieldChanged:(NSNotification*)notification
{
    AutoCompleteTextField* textField = (AutoCompleteTextField*)notification.object;
    if ([textField.text isEqualToString:@""]) {
        DeleteButtonStatus deleteStatus = [self deleteButton];
        NSUInteger selectionCount = [self.selectionDataSource numberOfItemsSelectedInContactSelectionView:self];
        if (selectionCount) {
            // Change textField
            self.ingredientField.text = @"\u200B";
        }
        self.ingredientField.hideCaret = (deleteStatus == DeleteButtonStatusSelected);
    } else {
        if ([self selectedButton]) {
            [self deleteButton];
        }
        textField.hideCaret = NO;
    }
    NSString* text = [self.ingredientField.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
    [self.selectionDelegate contactSelectionView:self didChangeText:text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""] &&
        ![textField.text isEqualToString:@"\u200B"])
    {
        NSString* text = self.ingredientField.text;
        [self.selectionDelegate contactSelectionView:self insertSelection:text];
        self.ingredientField.text = @"\u200B";
        self.enableAutoCompletion = NO;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    self.ingredientField.text = @"\u200B";
    return YES;
}


#pragma mark -
#pragma mark Auto Complete Text Field Delegate

- (UIButton*)selectedButton
{
    for (UIView* view in self.scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (((UIButton*)view).selected) {
                return (UIButton*)view;
            }
        }
    }
    return nil;
}

- (void)didTapTextField:(UITextField *)textField
{
    UIButton* selectedButton = [self selectedButton];
    if (selectedButton) {
        self.ingredientField.text = @"\u200B";
        self.ingredientField.hideCaret = NO;
        [UIView setAnimationsEnabled:NO];
        selectedButton.selected = NO;
        [UIView setAnimationsEnabled:YES];
    }
}

- (void)textFieldDictationRecordingDidEnd:(UITextField *)textField
{
    UIButton* selectedButton = [self selectedButton];
    if (selectedButton) {
        [self deleteButton];
        self.ingredientField.text = @"\u200B";
        self.ingredientField.hideCaret = NO;
    }
}

- (void)textField:(UITextField *)textField insertDictationResult:(NSArray *)dictationResult
{
    [self.selectionDelegate contactSelectionView:self insertDictationResult:dictationResult];
}

@end
