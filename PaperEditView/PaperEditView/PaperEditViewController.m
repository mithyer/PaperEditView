//
//  PaperEditViewController.m
//  PaperEditView
//
//  Created by ray on 16/6/2.
//  Copyright © 2016年 ray. All rights reserved.
//

#import "PaperEditViewController.h"

#import "PaperEditCell.h"
#import "Masonry.h"
#import "PaperEditCellModel.h"

static NSString *const kCellIdentifier = @"kCellIdentifier";

@interface PaperEditViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PaperEditCell *selectedCell;
@property (nonatomic, strong) PaperEditCell *selectedCellTricker;

@property (nonatomic, assign) CGFloat selectedCellTrickerBeganOriginY;
@property (nonatomic, assign) CGFloat selectedCellTrickerBeganTouchLocationY;

@end

@implementation PaperEditViewController {
    UITableView *_tableView;
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
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make, UIView *superview) {
            make.edges.mas_equalTo(superview);
        }];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (PaperEditCell *)selectedCellTricker {
    if (nil == _selectedCellTricker) {
        _selectedCellTricker = [[PaperEditCell alloc] init];
        [self.view addSubview:_selectedCellTricker];
    }
    return _selectedCellTricker;
}

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
                            [wSelf.dataSource exchangeObjectAtIndex:selectedCellIndexPath.row withObjectAtIndex:vIndexPath.row];
                            [wTableView moveRowAtIndexPath:selectedCellIndexPath toIndexPath:vIndexPath];
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
            

            
        } else {
            NSParameterAssert(nil);
        }
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
        NSIndexPath *cellIndexPath = [wTableView indexPathForCell:editCell];
        PaperEditCellModel *cellModel = wSelf.dataSource[cellIndexPath.row];
        PaperEditCellType type = (cellModel.type + 1) % 6;
        if (type == kPaperEditCellTypeUnknown) {
            type = kPaperEditCellTypeTextSmall;
        }
        cellModel.type = type;
        [wTableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
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

@end
