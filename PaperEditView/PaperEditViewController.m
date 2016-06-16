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
    
    [self.view addSubview:pView];
    
    [pView mas_makeConstraints:^(MASConstraintMaker *make, UIView *superview) {
        make.edges.mas_equalTo(superview);
    }];
    _pView = pView;

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"undo" style:UIBarButtonItemStylePlain target:self action:@selector(undoAction:)];
}

- (void)undoAction:(id)sender {
    [_pView undo];
}

@end
