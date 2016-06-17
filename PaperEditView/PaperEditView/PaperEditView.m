//
//  PaperEditView.m
//  PaperEditView
//
//  Created by ray on 16/6/15.
//  Copyright © 2016年 ray. All rights reserved.
//

#import "PaperEditView.h"

#import "PaperEditCell.h"
#import "Masonry.h"
#import "PaperEditCellModel.h"
#import <objc/runtime.h>

static NSString *const kCellIdentifier = @"kCellIdentifier";

@interface PaperEditView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PaperEditCell *selectedCell;
@property (nonatomic, strong) PaperEditCell *selectedCellTricker;
@property (nonatomic, assign) NSInteger textViewIsEditingCellRow;

@property (nonatomic, assign) CGFloat selectedCellTrickerBeganOriginY;
@property (nonatomic, assign) CGFloat selectedCellTrickerBeganTouchLocationY;
@property (nonatomic, assign) NSInteger selectedCellStartRow;

@end

@implementation PaperEditView {
    @private
    UITableView *_tableView;
    
    BOOL _canUndo;
    BOOL _canRedo;
}

- (void)commonInit {
    self.textViewIsEditingCellRow = -1;
    [self tableView];
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] init];
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:PaperEditCell.class forCellReuseIdentifier:kCellIdentifier];
        
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make, UIView *superview) {
            make.edges.mas_equalTo(superview);
        }];
    }
    return _tableView;
}

- (PaperTextView *)textViewForPaperEditCellModel:(PaperEditCellModel *)model {

    static void *kTextViewkey = &kTextViewkey;
    
    PaperTextView *textView = objc_getAssociatedObject(model, kTextViewkey);
    if (nil == textView) {
        textView = [[PaperTextView alloc] init];
        objc_setAssociatedObject(model, kTextViewkey, textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return textView;
}

- (PaperEditCell *)selectedCellTricker {
    if (nil == _selectedCellTricker) {
        _selectedCellTricker = [[PaperEditCell alloc] init];
        [self addSubview:_selectedCellTricker];
    }
    return _selectedCellTricker;
}

- (void)setDataSource:(NSMutableArray<PaperEditCellModel *> *)dataSource {
    self.dataSource = dataSource;
    [self.tableView reloadData];
}

// for test

- (NSMutableArray *)dataSource {
    static NSMutableArray *array;
    static NSArray *textArray;
    if (nil == textArray) {
        textArray = @[@"都是发生的发生的发生阿斯顿发按时发生的发顺丰按时按时发送",@"都是发生的发生的发生阿斯顿发按时发生的发顺丰按时按时发dd3324234234送",@"2234aabb",@"2234aabadsfasdfasdfasdfasdfasb",@"爱的发爱的发阿斯顿发那师傅阿斯顿发啊沙发上发生大多数十大杀手的发生的发生的发生的发顺丰爱啥啥地方所发生的发送发送发送的发顺丰按时发送"];
    }
    if (nil == array) {
        array = [NSMutableArray array];
        for (NSInteger i = 0; i < 30; ++ i) {
            PaperEditCellModel *model = [[PaperEditCellModel alloc] init];
            model.type = kPaperEditCellTypeTextSmall;
            model.content = textArray[arc4random()%5];
            [array addObject:model];
        }
    }
    
    return array;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaperEditCellModel *model = self.dataSource[indexPath.row];
    
    PaperEditCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [cell setupWithModel:model textView:[self textViewForPaperEditCellModel:model]];

    if (nil != self.inputAccessoryView && nil != cell.textView) {
        cell.textView.inputAccessoryView = self.inputAccessoryView;
    }

    __weak UITableView *wTableView = tableView;
    __weak typeof(self) wSelf = self;
    
    __weak PaperEditCell *wCell = cell;
    cell.selectAreaRecognizerStateChangedBlock = ^(UIGestureRecognizerState state, CGPoint location) {
        NSIndexPath *selectedCellIndexPath = [wTableView indexPathForCell:wCell];
        CGRect selectedCellRect = [wTableView rectForRowAtIndexPath:selectedCellIndexPath];
        CGFloat tableViewTouchLocationY = selectedCellRect.origin.y + location.y;
        PaperEditCell *selectedCellTricker = wSelf.selectedCellTricker;
        
        if (state == UIGestureRecognizerStateBegan) {
            selectedCellTricker.hidden = NO;
            
            selectedCellTricker.frame = CGRectMake(selectedCellRect.origin.x, selectedCellRect.origin.y - tableView.contentOffset.y, selectedCellRect.size.width, selectedCellRect.size.height);
            selectedCellTricker.textView.frame = wCell.textView.frame;
            selectedCellTricker.textView.font = wCell.textView.font;
            selectedCellTricker.textView.text = wCell.textView.text;
            
            
            wSelf.selectedCellTrickerBeganTouchLocationY = tableViewTouchLocationY;
            wSelf.selectedCellTrickerBeganOriginY = selectedCellRect.origin.y;
            wSelf.selectedCellStartRow = selectedCellIndexPath.row;
            
            wSelf.selectedCell = wCell;
            
            wCell.hidden = YES;
            
            
        } else if (state == UIGestureRecognizerStateChanged) {
            CGRect selectedCellTrickerFrame = selectedCellTricker.frame;
            selectedCellTrickerFrame.origin.y = (tableViewTouchLocationY - wSelf.selectedCellTrickerBeganTouchLocationY) + wSelf.selectedCellTrickerBeganOriginY - tableView.contentOffset.y;
            selectedCellTricker.frame = selectedCellTrickerFrame;
            
            if (!CGRectContainsPoint(selectedCellRect, CGPointMake(1, tableViewTouchLocationY))) {
                NSArray *visibleCellsIndexPath = [wTableView indexPathsForVisibleRows];
                for (NSIndexPath *vIndexPath in visibleCellsIndexPath) {
                    if (vIndexPath.row == selectedCellIndexPath.row) {
                        continue;
                    } else {
                        CGRect visibleRect = [wTableView rectForRowAtIndexPath:vIndexPath];
                        if (CGRectContainsPoint(visibleRect, CGPointMake(1, tableViewTouchLocationY))) {
                            [self moveEditCellAtRow:selectedCellIndexPath.row toRow:vIndexPath.row];
                            break;
                        }
                    }
                }
            }
        } else if (state == UIGestureRecognizerStatePossible) {
            CGRect selectedCellTrickerFrame = selectedCellRect;
            selectedCellTrickerFrame.origin.y -= tableView.contentOffset.y;
            
            
            [UIView animateWithDuration:0.3 animations:^{
                selectedCellTricker.frame = selectedCellTrickerFrame;
            } completion:^(BOOL finished) {
                wCell.hidden = NO;
                selectedCellTricker.hidden = YES;
            }];
            
            [self finalMoveEditCellAtRow:wSelf.selectedCellStartRow toRow:selectedCellIndexPath.row];
            
        } else {
            NSCParameterAssert(nil);
        }
    };
    
    cell.textView.textViewWillFirstChangeAfterBeginEditing = ^() {
        NSIndexPath *path = [wTableView indexPathForCell:wCell];
        if (wSelf.textViewIsEditingCellRow == path.row) {
            return;
        }
        [wSelf tagCellDidFirstEditing:path.row];
    };
    
    cell.textView.textViewDidChangeBlock = ^() {
        NSIndexPath *editCellIndexPath = [wTableView indexPathForCell:wCell];
        PaperEditCellModel *editCellModel = wSelf.dataSource[editCellIndexPath.row];
        editCellModel.content = wCell.textView.text;
        CGFloat height = [PaperEditCell heightForContent:wCell.textView.text type:editCellModel.type];
        if (ABS(height - wCell.textView.frame.size.height) > 1) {
            [wTableView reloadRowsAtIndexPaths:@[editCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [wCell.textView becomeFirstResponder];
        }
        [wSelf checkUndoRedoEnableState];
    };
    
    cell.textView.textViewDidSwipedRightBlock = ^() {
        [wSelf editCellAtRow:[wTableView indexPathForCell:wCell].row typeChange:YES];
    };
    
    cell.textView.textViewShouldReturnBlock = ^(NSRange range) {
        [wSelf breakCellAtRow:[wTableView indexPathForCell:wCell].row breakRange:range];
        return NO;
    };
    
    cell.textView.textViewShouldDeleteBlock = ^(NSRange range) {
        if (range.location == 0 && range.length == 0) {
            NSInteger row = [wTableView indexPathForCell:wCell].row;
            if (row > 0) {
                PaperEditCellModel *topCellModel = wSelf.dataSource[row - 1];
                [wSelf combineCellAtRow:row combineRange:NSMakeRange(topCellModel.content.length, 0)];
            }
            return NO;
        }
        return YES;
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaperEditCellModel *model = self.dataSource[indexPath.row];
    CGFloat height = [PaperEditCell heightForContent:model.content type:model.type];
    return height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.textViewIsEditingCellRow >= 0) {
        [self tagCellDidResignEditing:self.textViewIsEditingCellRow];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}


#pragma mark - Undo Action

- (void)checkUndoRedoEnableState {
    PaperEditCell *editCell = nil;
    
    if (self.textViewIsEditingCellRow != - 1) {
        editCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.textViewIsEditingCellRow inSection:0]];
    }

    BOOL canUndo = (nil != editCell && editCell.textView.undoManager.canUndo) || self.undoManager.canUndo;
    BOOL canRedo = (nil != editCell && editCell.textView.undoManager.canRedo) || self.undoManager.canRedo;
    
    if (_canUndo != canUndo) {
        _canUndo = canUndo;
        if (nil != self.undoStateChangedBlock) {
            self.undoStateChangedBlock(self);
        }
    }
    if (_canRedo != canRedo) {
        _canRedo = canRedo;
        if (nil != self.redoStateChangedBlock) {
            self.redoStateChangedBlock(self);
        }
    }
}

- (void)moveEditCellAtRow:(NSInteger)row1 toRow:(NSInteger)row2 {

    if (row1 == row2) {
        return;
    }
    if (row1 >= self.dataSource.count || row2 >= self.dataSource.count) {
        return;
    }
    PaperEditCellModel *row1Model = self.dataSource[row1];
    if (row1 > row2) {
        [self.dataSource removeObjectAtIndex:row1];
        [self.dataSource insertObject:row1Model atIndex:row2];
    } else {
        [self.dataSource insertObject:row1Model atIndex:row2];
        [self.dataSource removeObjectAtIndex:row1];
    }
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:row1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:row2 inSection:0]];
}

- (void)finalMoveEditCellAtRow:(NSInteger)row1 toRow:(NSInteger)row2 {
    
    [[self.undoManager prepareWithInvocationTarget:self] moveEditCellAtRow:row2 toRow:row1];
    
    [self checkUndoRedoEnableState];
}

- (void)editCellAtRow:(NSInteger)row typeChange:(BOOL)toNext {
    
    [[self.undoManager prepareWithInvocationTarget:self] editCellAtRow:row typeChange:!toNext];
    

    PaperEditCellModel *cellModel = self.dataSource[row];
    
    PaperEditCellType type;
    if (toNext) {
        type = (cellModel.type + 1) % 6;
        if (type == kPaperEditCellTypeUnknown) {
            type = kPaperEditCellTypeTextSmall;
        }
    } else {
        type = (cellModel.type - 1) % 6;
        if (type == kPaperEditCellTypeUnknown) {
            type = kPaperEditCellTypeMoveble2;
        }
    }

    cellModel.type = type;
    [self.tableView reloadData];
    
    [self checkUndoRedoEnableState];
}

- (void)tagCellDidFirstEditing:(NSInteger)editCellRow {
    if (self.textViewIsEditingCellRow < 0) {
        [[self.undoManager prepareWithInvocationTarget:self] tagCellDidResignEditing:editCellRow];
    } else {
        [[self.undoManager prepareWithInvocationTarget:self] tagCellDidFirstEditing:self.textViewIsEditingCellRow];
    }
    
    self.textViewIsEditingCellRow = editCellRow;
    
    [self checkUndoRedoEnableState];
}

- (void)tagCellDidResignEditing:(NSInteger)editCellRow {
    if (editCellRow <  0) {
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] tagCellDidFirstEditing:editCellRow];
    
    PaperEditCell *editCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editCellRow inSection:0]];

    [editCell.textView resignFirstResponder];
    self.textViewIsEditingCellRow = -1;
    
    [self checkUndoRedoEnableState];
}

- (void)breakCellAtRow:(NSInteger)row breakRange:(NSRange)range {
    [[self.undoManager prepareWithInvocationTarget:self] combineCellAtRow:row + 1 combineRange:range];
    
    PaperEditCellModel *cellModel = self.dataSource[row];
    
    NSString *content = cellModel.content;
    NSString *leftContent = [content substringToIndex:range.location];
    NSString *rightContent = [content substringFromIndex:range.location];
    
    cellModel.content = leftContent;
    
    PaperEditCellModel *newCellModel = [[PaperEditCellModel alloc] init];
    newCellModel.content = rightContent;
    newCellModel.type = cellModel.type;
    
    [self.dataSource insertObject:newCellModel atIndex:row + 1];
    [self.tableView reloadData];
    PaperEditCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:0]];
    [cell.textView becomeFirstResponder];
    cell.textView.selectedRange = NSMakeRange(0, 0);
    
    [self checkUndoRedoEnableState];
}

- (void)combineCellAtRow:(NSInteger)row combineRange:(NSRange)range {
    [[self.undoManager prepareWithInvocationTarget:self] breakCellAtRow:row - 1 breakRange:range];
    
    PaperEditCellModel *breakedCellModel = self.dataSource[row - 1];
    PaperEditCellModel *cellModel = self.dataSource[row];
    
    NSMutableString *str = [NSMutableString stringWithString:breakedCellModel.content];
    [str replaceCharactersInRange:range withString:cellModel.content];
    breakedCellModel.content = str;
    [self.dataSource removeObjectAtIndex:row];
    
    [self.tableView reloadData];
    PaperEditCell *breakedCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:0]];
    [breakedCell.textView becomeFirstResponder];
    breakedCell.textView.selectedRange = range;

    [self checkUndoRedoEnableState];
}

- (void)undo {
    if (!_canUndo) {
        return;
    }
    PaperEditCell *editCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.textViewIsEditingCellRow inSection:0]];

    if (nil != editCell && editCell.textView.undoManager.canUndo) {
        [editCell.textView.undoManager undo];
    } else {
        [self.undoManager undo];
    }
    [self checkUndoRedoEnableState];
}

- (void)redo {
    if (!_canRedo) {
        return;
    }
    
    PaperEditCell *editCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.textViewIsEditingCellRow inSection:0]];

    if (nil != editCell && editCell.textView.undoManager.canRedo) {
        [editCell.textView.undoManager redo];
    } else {
        [self.undoManager redo];
    }
    [self checkUndoRedoEnableState];
}

- (bool)canUndo {
    return _canUndo;
}

- (bool)canRedo {
    return _canRedo;
}


@end
