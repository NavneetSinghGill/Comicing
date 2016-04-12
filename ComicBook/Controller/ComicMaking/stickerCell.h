//
//  stickerCell.h
//  ComicMakingPage
//
//  Created by ADNAN THATHIYA on 04/03/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface stickerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgvSticker;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property BOOL isQuivering;

- (void)startQuivering;
- (void)stopQuivering;

@end
