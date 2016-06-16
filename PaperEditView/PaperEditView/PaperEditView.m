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

static NSString *const kCellIdentifier = @"kCellIdentifier";

@interface PaperEditView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PaperEditCell *selectedCell;
@property (nonatomic, strong) PaperEditCell *selectedCellTricker;
@property (nonatomic, strong) PaperEditCell *textViewIsEditingCell;

@property (nonatomic, assign) CGFloat selectedCellTrickerBeganOriginY;
@property (nonatomic, assign) CGFloat selectedCellTrickerBeganTouchLocationY;
@property (nonatomic, assign) NSInteger selectedCellStartRow;

@end

@implementation PaperEditView {
    @private
    UITableView *_tableView;
}

- (void)commonInit {
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
    if (nil != self.inputAccessoryView) {
        cell.textView.inputAccessoryView = self.inputAccessoryView;
    }
    [cell setupWithModel:model];
    
    __weak UITableView *wTableView = tableView;
    __weak typeof(self) wSelf = self;
    
    cell.selectAreaRecognizerStateChangedBlock = ^(PaperEditCell *selectedCell, UIGestureRecognizerState state, CGPoint location) {
        NSIndexPath *selectedCellIndexPath = [wTableView indexPathForCell:selectedCell];
        CGRect selectedCellRect = [wTableView rectForRowAtIndexPath:selectedCellIndexPath];
        CGFloat tableViewTouchLocationY = selectedCellRect.origin.y + location.y;
        PaperEditCell *selectedCellTricker = wSelf.selectedCellTricker;
        
        if (state == UIGestureRecognizerStateBegan) {
            selectedCellTricker.hidden = NO;
            
            selectedCellTricker.frame = CGRectMake(selectedCellRect.origin.x, selectedCellRect.origin.y - tableView.contentOffset.y, selectedCellRect.size.width, selectedCellRect.size.height);
            selectedCellTricker.textView.frame = selectedCell.textView.frame;
            selectedCellTricker.textView.font = selectedCell.textView.font;
            selectedCellTricker.textView.text = selectedCell.textView.text;
            
            
            wSelf.selectedCellTrickerBeganTouchLocationY = tableViewTouchLocationY;
            wSelf.selectedCellTrickerBeganOriginY = selectedCellRect.origin.y;
            wSelf.selectedCellStartRow = selectedCellIndexPath.row;
            
            wSelf.selectedCell = selectedCell;
            
            selectedCell.hidden = YES;
            
            
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
                selectedCell.hidden = NO;
                selectedCellTricker.hidden = YES;
            }];
            
            [self finalMoveEditCellAtRow:wSelf.selectedCellStartRow toRow:selectedCellIndexPath.row];
            
        } else {
            NSParameterAssert(nil);
        }
    };
    
    cell.textViewDidBeginEditingBlock = ^(PaperEditCell *editCell) {
        [wSelf tagCellDidBeginEditing:editCell];
    };
    
    cell.textViewDidChangeBlock = ^(PaperEditCell *editCell) {
        NSIndexPath *editCellIndexPath = [wTableView indexPathForCell:editCell];
        PaperEditCellModel *editCellModel = wSelf.dataSource[editCellIndexPath.row];
        editCellModel.content = editCell.textView.text;
        CGFloat height = [PaperEditCell heightForContent:editCell.textView.text type:editCellModel.type];
        if (ABS(height - editCell.textView.frame.size.height) > 1) {
            [wTableView reloadRowsAtIndexPaths:@[editCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            PaperEditCell *newCell = [wTableView cellForRowAtIndexPath:editCellIndexPath];
            [newCell.textView becomeFirstResponder];
        }
    };
    
    cell.textViewDidSwipedRightBlock = ^(PaperEditCell *editCell) {
        [wSelf editCellAtRow:[wTableView indexPathForCell:editCell].row typeChange:YES];
    };
    
    cell.textViewDidTapReturnBlock = ^(PaperEditCell *editCell, NSRange returnRange) {
        NSIndexPath *cellIndexPath = [wTableView indexPathForCell:editCell];
        PaperEditCellModel *cellModel = wSelf.dataSource[cellIndexPath.row];
        
        NSString *content = cellModel.content;
        NSString *leftContent = [content substringToIndex:returnRange.location];
        NSString *rightContent = [content substringFromIndex:returnRange.location];
        
        cellModel.content = leftContent;
        
        PaperEditCellModel *newCellModel = [[PaperEditCellModel alloc] init];
        newCellModel.content = rightContent;
        newCellModel.type = cellModel.type;
        
        [wSelf.dataSource insertObject:newCellModel atIndex:cellIndexPath.row + 1];
        [wTableView reloadData];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaperEditCellModel *model = self.dataSource[indexPath.row];
    CGFloat height = [PaperEditCell heightForContent:model.content type:model.type];
    return height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (nil != self.textViewIsEditingCell) {
        [self tagCellDidResignEditing:self.textViewIsEditingCell];
    }
}


#pragma mark - Undo Action

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
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tagCellDidBeginEditing:(PaperEditCell *)editCell {
    if (nil == self.textViewIsEditingCell) {
        [[self.undoManager prepareWithInvocationTarget:self] tagCellDidResignEditing:editCell];
    } else {
        [[self.undoManager prepareWithInvocationTarget:self] tagCellDidBeginEditing:self.textViewIsEditingCell];
    }
    
    [editCell.textView becomeFirstResponder];
    self.textViewIsEditingCell = editCell;
    
}

- (void)tagCellDidResignEditing:(PaperEditCell *)editCell {
    [[self.undoManager prepareWithInvocationTarget:self] tagCellDidBeginEditing:editCell];
    
    [editCell resignFirstResponder];
    self.textViewIsEditingCell = nil;
}

- (void)undo {
    if (nil != self.textViewIsEditingCell && self.textViewIsEditingCell.textView.undoManager.canUndo) {
        [self.textViewIsEditingCell.textView.undoManager undo];
    } else {
        [self.undoManager undo];
    }
}

- (void)redo {
    if (nil != self.textViewIsEditingCell && self.textViewIsEditingCell.textView.undoManager.canRedo) {
        [self.textViewIsEditingCell.textView.undoManager redo];
    } else {
        [self.undoManager redo];
    }
}

- (bool)canUndo {
    if (nil != self.textViewIsEditingCell && self.textViewIsEditingCell.textView.undoManager.canUndo) {
        return true;
    }
    return self.undoManager.canUndo;
}

- (bool)canRedo {
    if (nil != self.textViewIsEditingCell && self.textViewIsEditingCell.textView.undoManager.canRedo) {
        return true;
    }
    return self.undoManager.canRedo;
}


@end
