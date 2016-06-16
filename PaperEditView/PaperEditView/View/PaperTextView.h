//
//  PaperTextView.h
//  PaperEditView
//
//  Created by ray on 16/6/16.
//  Copyright © 2016年 ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaperTextView : UITextView

@property (nonatomic, copy) void (^textViewDidChangeBlock)();
@property (nonatomic, copy) void (^textViewWillFirstChangeAfterBeginEditing)();
@property (nonatomic, copy) void (^textViewDidSwipedRightBlock)();
@property (nonatomic, copy) BOOL (^textViewShouldReturnBlock)(NSRange range);
@property (nonatomic, copy) BOOL (^textViewShouldDeleteBlock)(NSRange range);

@end
