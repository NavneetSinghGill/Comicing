//
//  ComicItemTools.h
//  ComicMakingPage
//
//  Created by Ramesh on 25/01/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BubbleViewItem.h"


#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppConstants.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreAudio/CoreAudioTypes.h>


typedef enum {
    ComicSticker,
    ComicExclamation,
    ComicBubble,
    ComicCaption
} ComicItemType;

@protocol ComicItem <NSObject>

-(id)addItemWithImage:(id)sticker;

//- (id)initWithCoder:(NSCoder *)decoder;
//-(void)encodeWithCoder:(NSCoder *)aCoder;

@end


#pragma mark - ComicItemSticker

@interface ComicItemSticker : UIImageView<ComicItem> {

}

@end

#pragma mark - ComicItemExclamation

@interface ComicItemExclamation : UIImageView<ComicItem> {
    
}

@end

#pragma mark - ComicItemBubble

@interface ComicItemBubble : UIView<ComicItem> {
        AVAudioRecorder *recorder;
        AVAudioSession *audioSession;
        NSURL *temporaryRecFile;
}
@property (strong, nonatomic) NSString* bubbleString;
@property (nonatomic, strong) NSString *recorderFilePath;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic , strong) UIButton *audioImageButton;
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UITextView* txtBuble;
@property (nonatomic,strong)UIButton* imagebtn;
-(void)recordAction;
-(BOOL)isPlayVoice;
-(void)playAction;
- (void)stopRecording;
-(float)playDuration;
-(void)pauseAction;

@end

#pragma mark - ComicCaption

@interface ComicItemCaption : UIView<ComicItem> {
    
}

@property (strong,nonatomic)UIImageView* bgImageView;
@property(strong,nonatomic) UITextView* txtCaption;
@property(strong,nonatomic)UIButton* plusButton;
@property (strong,nonatomic) UIView* dotHolder;
@property (strong,nonatomic) NSString* tintColourString;

@end

