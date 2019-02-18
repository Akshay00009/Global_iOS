//
//  DropDownLabel.h
//  BCDropDownView
//
//  Created by Bharat Jagtap on 17/06/15.
//  Copyright (c) 2015 Bitcode Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BCFrameworks.h"

#define BCDropDownImageName @"drop_down_arrow"

@class BCDropDownButton;

@protocol BCDropDownButtonDelegate <NSObject>

@optional

- (void)didBeginEditing:(BCDropDownButton*)button;

- (void)dropDownButton:(BCDropDownButton*)button didChangeValue:(NSString*)value withIndex:(NSInteger)index ;

- (void)didEndEditing:(BCDropDownButton*)button;

@end

@interface BCDropDownButton : UILabel
@property (nonatomic,strong) NSArray * items ;
@property (nonatomic,weak) id<BCDropDownButtonDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex ;

@end
