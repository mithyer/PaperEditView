//
//  PaperEditCell.m
//  PaperEditView
//
//  Created by ray on 16/6/2.
//  Copyright © 2016年 ray. All rights reserved.
//

#import "PaperEditCell.h"

#import "Masonry.h"
#import "BlocksKit+UIKit.h"


@interface PaperEditCell()

@end

@implementation PaperEditCell {
    UIView *_selectArea;
    __weak PaperTextView *_textView;
}

+ (CGFloat)leftPaddingForType:(PaperEditCellType)type {
    switch (type) {
        case kPaperEditCellTypeTextSmall:
        case kPaperEditCellTypeTextMiddle:
        case kPaperEditCellTypeTextLarge:
            return 5;
        case kPaperEditCellTypeMoveble1:
            return 30;
        case kPaperEditCellTypeMoveble2:
            return 40;
        default:
            NSParameterAssert(nil);
            return 0;
    }
    return 0;
}

+ (CGFloat)rightPaddingForType:(PaperEditCellType)type {
    switch (type) {
        case kPaperEditCellTypeTextSmall:
        case kPaperEditCellTypeTextMiddle:
        case kPaperEditCellTypeTextLarge:
            return 5;
        case kPaperEditCellTypeMoveble1:
            return 10;
        case kPaperEditCellTypeMoveble2:
            return 10;
        default:
            NSParameterAssert(nil);
            return 0;
    }
    return 0;
}

+ (CGFloat)fontSizeForType:(PaperEditCellType)type {
    switch (type) {
        case kPaperEditCellTypeTextSmall:
            return 12;
        case kPaperEditCellTypeTextMiddle:
            return 16;
        case kPaperEditCellTypeTextLarge:
            return 20;
        case kPaperEditCellTypeMoveble1:
            return 15;
        case kPaperEditCellTypeMoveble2:
            return 15;
        default:
            NSParameterAssert(nil);
            return 0;
    }
    return 0;
}

+ (UIView *)leftViewForType:(PaperEditCellType)type {
    switch (type) {
        case kPaperEditCellTypeTextSmall:
        case kPaperEditCellTypeTextMiddle:
        case kPaperEditCellTypeTextLarge:
            return nil;
        case kPaperEditCellTypeMoveble1: {
            // TODO:
        }
        case kPaperEditCellTypeMoveble2: {
            // TODO:
            return nil;
        }
        default:
            NSParameterAssert(nil);
            return nil;
    }
    return nil;
}


+ (CGFloat)heightForContent:(NSString *)content type:(PaperEditCellType)type {
    static UITextView *textView;
    if (nil == textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    CGFloat boundsWidth = [UIScreen mainScreen].bounds.size.width;
    textView.frame = ({
        CGRect frame = textView.frame;
        frame.size.width = boundsWidth - [self leftPaddingForType:type] - [self rightPaddingForType:type];
        frame;
    });
    textView.font = [UIFont systemFontOfSize:[self fontSizeForType:type]];
    textView.text = content;
    return textView.contentSize.height + 10;
    // TODO : 优化...
//    return textView.frame.size.height;
//    
//    CGFloat boundsWidth = [UIScreen mainScreen].bounds.size.width - 65;
//    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin;
//    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
//    para.lineBreakMode = NSLineBreakByWordWrapping;
//    
//    CGSize size = [content boundingRectWithSize:CGSizeMake(boundsWidth, CGFLOAT_MAX)
//                                              options:options
//                                     attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName : para} context:nil].size;
//    
//    return size.height + 20;
}

- (void)setupWithModel:(PaperEditCellModel *)model textView:(PaperTextView *)textView {
    _textView = textView;

    if (nil != _textView.superview) {
        [_textView removeFromSuperview];
    }
    [self.contentView addSubview:_textView];

    _textView.font = [UIFont systemFontOfSize:[self.class fontSizeForType:model.type]];
    _textView.text = model.content;
    
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make, UIView *superview) {
        make.edges.mas_equalTo(superview).mas_offset(UIEdgeInsetsMake(0, [self.class leftPaddingForType:model.type], 0, [self.class rightPaddingForType:model.type]));
    }];
}

- (UIView *)selectArea {
    if (nil == _selectArea) {
        _selectArea = [[UIView alloc] init];
        _selectArea.userInteractionEnabled = YES;
        
        [self.contentView addSubview:_selectArea];
        
        [_selectArea mas_makeConstraints:^(MASConstraintMaker *make, UIView *superview) {
            make.top.mas_equalTo(10);
            make.leading.mas_equalTo(10);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(_selectArea.mas_height);
        }];
        
        __weak typeof(self) wSelf = self;
        [_selectArea addGestureRecognizer:[UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer * _Nonnull sender, UIGestureRecognizerState state, CGPoint location) {
            if (nil != wSelf.selectAreaRecognizerStateChangedBlock) {
                wSelf.selectAreaRecognizerStateChangedBlock(state, location);
            }

        }]];
    }
    return _selectArea;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        [self selectArea];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}




@end
