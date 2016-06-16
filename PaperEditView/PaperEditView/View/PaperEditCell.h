//
//  PaperEditCell.h
//  PaperEditView
//
//  Created by ray on 16/6/2.
//  Copyright © 2016年 ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperEditCellModel.h"
#import "PaperTextView.h"

@interface PaperEditCell : UITableViewCell

@property (nonatomic, copy) void (^selectAreaRecognizerStateChangedBlock)(UIGestureRecognizerState state, CGPoint location);

@property (nonatomic, weak, readonly) PaperTextView *textView;

- (void)setupWithModel:(PaperEditCellModel *)model textView:(PaperTextView *)textView;

+ (CGFloat)heightForContent:(NSString *)content type:(PaperEditCellType)type;

@end
