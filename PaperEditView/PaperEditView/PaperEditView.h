//
//  PaperEditView.h
//  PaperEditView
//
//  Created by ray on 16/6/15.
//  Copyright © 2016年 ray. All rights reserved.
//

#import "PaperEditCellModel.h"

@interface PaperEditView : UIView

- (void)undo;
- (void)redo;
- (bool)canUndo;
- (bool)canRedo;

@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) NSMutableArray<PaperEditCellModel *> *dataSource;

@end
