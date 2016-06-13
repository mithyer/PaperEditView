//
//  PaperEditCell.h
//  PaperEditView
//
//  Created by ray on 16/6/2.
//  Copyright © 2016年 ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperEditCellModel.h"

@interface PaperEditCell : UITableViewCell

@property (nonatomic, copy) void (^selectAreaRecognizerStateChangedBlock)(PaperEditCell* selectedCell, UIGestureRecognizerState state, CGPoint location);
@property (nonatomic, copy) void (^textViewDidChangeBlock)(PaperEditCell* editCell);
@property (nonatomic, copy) void (^textViewDidSwipedRightBlock)(PaperEditCell* editCell);
@property (nonatomic, copy) void (^textViewDidTapReturnBlock)(PaperEditCell* editCell, NSRange returnRange);


@property (nonatomic, strong, readonly) UITextView *textView;

- (void)setupWithModel:(PaperEditCellModel *)model;

+ (CGFloat)heightForContent:(NSString *)content type:(PaperEditCellType)type;

@end
