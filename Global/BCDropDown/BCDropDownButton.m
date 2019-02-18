//
//  DropDownLabel.m
//  BCDropDownView
//
//  Created by Bharat Jagtap on 17/06/15.
//  Copyright (c) 2015 Bitcode Technologies. All rights reserved.
//

#import "BCDropDownButton.h"

@interface BCDropDownButton ()
@property (nonatomic,strong) NSString * placeholderText ;
@end

@interface BCDropDownButton () <UIPickerViewDataSource,UIPickerViewDelegate,UIPopoverControllerDelegate>
{
    UIPickerView * picker;
    UIToolbar * toolbar ;
    UIColor * originalColor ;
    UIImageView * arrowView;
    UIPopoverController * popOverController;
    
}
@end

@implementation BCDropDownButton
@synthesize selectedIndex = _selectedIndex;

- (void)awakeFromNib {
    
    [self setup];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    
        [self setup];
    }
    return self;
}

- (void)setup {
    
    //self.backgroundColor = [UIColor lightGrayColor];
    
    [self addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    
    self.userInteractionEnabled = YES;
    [self setEnabled:YES];
    UITapGestureRecognizer * tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapG];
    
    
    picker = [[UIPickerView alloc ] initWithFrame:CGRectMake(0, 0, 320, 220)];
    picker.dataSource = self;
    picker.delegate = self;
    picker.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:234.0/255.0 blue:232.0/255.0 alpha:1.0];
    
    [picker setTintColor:[UIColor darkGrayColor]];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.translucent = NO;
    toolbar.backgroundColor = [UIColor grayColor];
    UIBarButtonItem * btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(hidePicker:)];
    UIBarButtonItem * flexBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = @[flexBtn,btnDone];
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        UIViewController * vc = [[UIViewController alloc] init];
        vc.preferredContentSize = CGSizeMake(320, picker.frame.size.height+44);
        vc.view.frame = CGRectMake(0, 0, 320, picker.frame.size.height+44);
        CGRect rect = CGRectMake(0, 0, 320, 44);
        toolbar.frame = rect;
        rect = picker.frame;
        rect.origin.y = 44 ;
        picker.frame = rect;
        
        [vc.view addSubview:picker];
        [vc.view addSubview:toolbar];
        
        popOverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        popOverController.delegate = self;
        
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self && [keyPath isEqualToString:@"items"]) {
        self.placeholderText = self.text ;
        [picker reloadAllComponents];
        [picker selectRow:0 inComponent:0 animated:NO];
         
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (arrowView) {
        [arrowView removeFromSuperview];
    }
    
    if (!arrowView) {
        arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
        arrowView.image = [UIImage imageNamed:BCDropDownImageName];
    }
    
    arrowView.center = CGPointMake(rect.size.width - 10.5, rect.size.height/2.0);
    [self addSubview:arrowView];
}

- (NSInteger)selectedIndex {
    
    return [picker selectedRowInComponent:0] ;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    _selectedIndex = selectedIndex;
    [picker selectRow:_selectedIndex inComponent:0 animated:YES];
    self.text = self.items[selectedIndex];
    
    
}

- (void)hidePicker:(id)sender {

    [self resignFirstResponder];
   
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){

        [popOverController dismissPopoverAnimated:YES];
    }
    
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(dropDownButton:didChangeValue:withIndex:)]) {
        
        NSInteger index = [picker selectedRowInComponent:0];
        
        [self.delegate dropDownButton:self didChangeValue:self.text withIndex:index];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndEditing:)]) {
        
        [self.delegate didEndEditing:self];
    }
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
    
    if ([self isFirstResponder]) {

        [self resignFirstResponder];
        
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            
            [popOverController dismissPopoverAnimated:YES];
        }

        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndEditing:)]) {
            
            [self.delegate didEndEditing:self];
        }

    }
    else {
        [self becomeFirstResponder];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            
            [popOverController presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }

        originalColor = self.textColor;
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didBeginEditing:)]) {
        
            [self.delegate didBeginEditing:self];
        }

        
    }
    
    if (self.items.count == 0) {
        [self hidePicker:self];
    }
    
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (BOOL)canResignFirstResponder {
    return YES;
}



- (UIView *)inputView {
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        return nil;
    }
    return picker;
}

- (UIView *)inputAccessoryView {
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        return nil;
    }
    
    return toolbar;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.items.count;
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.items[row];
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
 
    UILabel * lbl = (UILabel*)view;
    
    if(!lbl){
        lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentCenter;
    }
    lbl.textColor = [UIColor blackColor];
    [lbl drawTextInRect:lbl.frame];
    lbl.text = self.items[row];
    return lbl;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    self.alpha = 1.0;

    [UIView animateWithDuration:0.3 animations:^{
    
        self.text = self.items[row];
        self.alpha = 1.0;
    } completion:^(BOOL finished){
    
           
    }];
    
    
}


- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return NO;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 5, 0, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


- (void)dealloc {
    
    [self removeObserver:self forKeyPath:@"items"];
}

@end
