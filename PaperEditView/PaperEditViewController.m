//
//  PaperEditViewController.m
//  PaperEditView
//
//  Created by ray on 16/6/2.
//  Copyright © 2016年 ray. All rights reserved.
//

#import "PaperEditViewController.h"

#import "PaperEditView.h"
#import "Masonry.h"

@implementation PaperEditViewController {
    PaperEditView *_pView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    view.backgroundColor = [UIColor redColor];
    
    PaperEditView *pView = [[PaperEditView alloc] init];
    pView.inputAccessoryView = view;
    
    __weak typeof(self) wSelf = self;
    pView.redoStateChangedBlock = ^(PaperEditView *editView) {
        [wSelf refreshUnReDoBtn];
    };
    pView.undoStateChangedBlock = ^(PaperEditView *editView) {
        [wSelf refreshUnReDoBtn];
    };
    
    [self.view addSubview:pView];
    
    [pView mas_makeConstraints:^(MASConstraintMaker *make, UIView *superview) {
        make.edges.mas_equalTo(superview);
    }];
    _pView = pView;

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"undo" style:UIBarButtonItemStylePlain target:self action:@selector(undoAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"redo" style:UIBarButtonItemStylePlain target:self action:@selector(redoAction:)];
    
    [self refreshUnReDoBtn];
}

- (void)undoAction:(id)sender {
    [_pView undo];
}

- (void)redoAction:(id)sender {
    [_pView redo];
}

- (void)refreshUnReDoBtn {
    self.navigationItem.leftBarButtonItem.enabled = _pView.canRedo;
    self.navigationItem.rightBarButtonItem.enabled = _pView.canUndo;
}

@end
