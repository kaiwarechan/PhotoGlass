//
//  sandGlassViewController.h
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "mosaicViewController.h"


@interface sandGlassViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAccelerometerDelegate>{
    
    UIImage *back;
    UIImageView *backView;
    UIImageView *picImgView;
    
    NSDate *assetDate;
    
    NSInteger assetYear;
    NSInteger assetMonth;
    NSInteger assetDay;
    
    
    UIImage *suna;
    UIImageView *sunaView;
    
    UIImage *uesuna;
    UIImageView *uesunaView;
    
    
    NSInteger nowYear;
    NSInteger nowMonth;
    NSInteger nowDay;
    
    NSString *AlbumSandName;
    NSString *_orientation;
    
    UIImageView *sunaImageView;
    UIImageView *sunaupImageView;
    
    UIImage *upsand;
    UIImageView *upsandView;
    
    UIImagePickerController *_pickerController;
    ALAssetsLibrary *_library;
    NSURL *_groupURL;
    NSString *_AlbumName;
    
    //アルバムが写真アプリに既にあるかどうかの判定用
    BOOL _albumWasFound;

}

@end
