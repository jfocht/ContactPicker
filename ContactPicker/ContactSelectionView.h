//
//  MQIngredientModalView.h
//  Meal Queue
//
//  Created by Jordan Focht on 12/23/13.
//  Copyright (c) 2013 Jordan Focht. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoCompleteTextField.h"


@protocol ContactSelectionDataSource
-(NSUInteger)numberOfItemsSelectedInContactSelectionView:(id)ingredientView;
-(NSString*)contactSelectionView:(id)contactSelectionView itemAtIndex:(NSUInteger)index;
@end

@protocol ContactSelectionDelegate
-(void)contactSelectionView:(id)contactSelectionView insertSelection:(NSString*)selection;
-(void)contactSelectionView:(id)contactSelectionView removeSelection:(NSString*)selection;
-(void)contactSelectionView:(id)contactSelectionView insertDictationResult:(NSArray*)dictationResult;

@optional
-(void)contactSelectionView:(id)contactSelectionView didChangeLineCount:(NSUInteger)count;
-(void)contactSelectionView:(id)contactSelectionView didChangeText:(NSString*)text;
@end

@interface ContactSelectionView : UITableViewCell <UITextFieldDelegate, AutoCompleteTextFieldDelegate>


@property(readonly) NSInteger lineCount;
@property(readonly) UILabel* titleLabel;
@property(weak, nonatomic) IBOutlet UITableView* tableView;
@property(weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property(nonatomic) AutoCompleteTextField* ingredientField;
@property(nonatomic) IBOutlet id<ContactSelectionDelegate> selectionDelegate;
@property(nonatomic) IBOutlet id<ContactSelectionDataSource> selectionDataSource;

- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage*)backgroundImage;
- (void)reloadData;
@end
