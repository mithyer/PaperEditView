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

@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) NSMutableArray<PaperEditCellModel *> *dataSource;

@property (nonatomic, copy) void (^undoStateChangedBlock)(PaperEditView *editView);
@property (nonatomic, copy) void (^redoStateChangedBlock)(PaperEditView *editView);
@property (nonatomic, assign, readonly) BOOL canUndo;
@property (nonatomic, assign, readonly) BOOL canRedo;

@end
