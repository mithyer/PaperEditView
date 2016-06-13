//
//  PaperEditCellModel.h
//  PaperEditView
//
//  Created by ray on 16/6/12.
//  Copyright © 2016年 ray. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PaperEditCellType) {
    kPaperEditCellTypeUnknown,
    kPaperEditCellTypeTextSmall,
    kPaperEditCellTypeTextMiddle,
    kPaperEditCellTypeTextLarge,
    kPaperEditCellTypeMoveble1,
    kPaperEditCellTypeMoveble2
};

@interface PaperEditCellModel : NSObject

@property (nonatomic, assign) PaperEditCellType type;
@property (nonatomic, copy) NSString *content;


@end
