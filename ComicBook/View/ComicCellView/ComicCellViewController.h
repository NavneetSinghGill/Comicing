//
//  ComicCellViewController.h
//  ComicBook
//
//  Created by ADNAN THATHIYA on 06/10/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ComicCellViewController;

@protocol ComicCellViewControllerwDelegate <NSObject>

@optional

- (void)didFrameChange:(ComicCellViewController*)viewController withFrame:(CGRect)frame;

@end


@interface ComicCellViewController : UIViewController

@property (nonatomic, assign) id<ComicCellViewControllerwDelegate> delegate;
@property (nonatomic, strong) UIView *viewWhiteBorder;

-(id)initWithFrame:(CGRect)frame;
- (void)setupComicSlidePreview:(NSArray *)slides;

@end
