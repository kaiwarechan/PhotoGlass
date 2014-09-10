//
//  sandGlassViewController.m
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import "sandGlassViewController.h"
#import "Image.h"
#import "mosaicViewController.h"
#import "UIImage+GIF.h"

@interface sandGlassViewController ()

@end

@implementation sandGlassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /* --- ステータスバー消す　---*/
    if( [ UIApplication sharedApplication ].isStatusBarHidden == NO ) {
        [ UIApplication sharedApplication ].statusBarHidden = YES;
    }
    
    
    /* ---　背景画像設定 --- */
    
    back = [UIImage imageNamed:@"sandglass.png"];
    backView = [[UIImageView alloc] initWithImage:back];
    backView.frame = CGRectMake(0, 0, 320, 568);
    
    
    /* ---　背景画像設定 --- */
    
    back = [UIImage imageNamed:@"back.png"];
    
    backView = [[UIImageView alloc] initWithImage:back];
    backView.frame = CGRectMake(0, 0, 320, 568);
    
    suna = [UIImage imageNamed:@"sandglass.png"];
    sunaView = [[UIImageView alloc] initWithImage:suna];
    sunaView.frame = CGRectMake(0, 0, 320, 568);
    
    upsand = [UIImage imageNamed:@"upsand.png"];
    upsandView = [[UIImageView alloc] initWithImage:upsand];
    upsandView.frame = CGRectMake(9, 40, 300, 491);
    
    
    //gifアニメーション
    UIImage* sunaImage = [UIImage animatedGIFNamed:@"suna"];
    sunaImageView = [[UIImageView alloc] initWithImage:sunaImage];
    sunaImageView.frame = CGRectMake(158, 284, 5, 128);
    
    //    UIImage* sunaupImage = [UIImage animatedGIFNamed:@"sunaup"];
    //    sunaupImageView = [[UIImageView alloc] initWithImage:sunaupImage];
    //    sunaupImageView.frame = CGRectMake(48, 100, 220, 189);
    
    
    [self.view addSubview:backView];
    [self.view addSubview:sunaView];
    [self.view addSubview:sunaImageView];
    [self.view addSubview:upsandView];
    //    [self.view addSubview:sunaupImageView];
    
    
    AlbumSandName = @"Mosaic";
    
    //端末回転通知の開始
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self.view addSubview:backView];
    
    //UIImagePickerController
    _pickerController =[[UIImagePickerController alloc] init];
    _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    _pickerController.delegate = self;
    _pickerController.allowsEditing = YES;
    
    //ALAssetLibraryのインスタン作成
    _library = [[ALAssetsLibrary alloc] init];
    _AlbumName = @"PhotoGlass";
    _albumWasFound = FALSE;
    
    //アルバムを検索してなかったら新規作成、あったらアルバムのURLを保持
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                
                                if (group) {
                                    
                                    NSLog(@"作成したよ");
                                    if ([_AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                        
                                        //URLをクラスインスタンスに保持
                                        _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                        _albumWasFound = TRUE;
                                        
                                        //アルバムがない場合は新規作成
                                    }else if (_albumWasFound==FALSE) {
                                        
                                        ALAssetsLibraryGroupResultBlock resultBlock = ^(ALAssetsGroup *group) {
                                            _groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                        };
                                        
                                        //新しいアルバムを作成
                                        [_library addAssetsGroupAlbumWithName:_AlbumName
                                                                  resultBlock:resultBlock
                                                                 failureBlock: nil];
                                        
                                        _albumWasFound = TRUE;

                                        
                                        
                                    }
                                }
                                
                            } failureBlock:nil];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self makeImgParts];

}


-(void)makeImgParts{
    
    /* --- 時間 --- */
    NSDate *begin =[[NSUserDefaults standardUserDefaults] objectForKey:@"begin"];
    
    if(begin== nil){
        
        begin = [NSDate date]; //使い始めた日にちをbeginにいれる
        
        [[NSUserDefaults standardUserDefaults] setObject:begin forKey:@"begin"]; //開始時刻を保存
        
    }
    
    
    /* --- 写真 --- */
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         
         //NSLog(@"number %d",(int)[group numberOfAssets]);
         //NSLog(@"group is %@",group);
         
         
         if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"])
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //全部の写真とってくる(movieはない)
             
             
             //__block int f = 0;
             NSMutableArray *array = [[NSMutableArray alloc] init];
             
             
             for(int p = (int)[group numberOfAssets]-1; p >=(int)[group numberOfAssets]-71 ; p--)
                 //[group numberOfAssets]は個数、pは順番(0から始まる)→0が一番古い写真
                 
             {
                 
                 //NSLog(@"p is %d",[group numberOfAssets]);
                 
                 /*if((int)f == 1){
                  break;
                  }
                  */
                 
                 [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:p]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                  {
                      assetDate = [result valueForProperty:ALAssetPropertyDate]; //メタデータの中の日付のみ取得
                      
                      NSTimeInterval  since = [assetDate timeIntervalSinceDate:begin]; //現在時刻からbeginまでの秒数
                      
                      //NSLog(@"result =============== %@",result);
                      NSLog(@"メタデータ-------%@",[[result defaultRepresentation] metadata]);
                      
                      if(since/(60*60*24) > -30){
                          
                          //NSLog(@"since is %f",since);
                          
                          if (nil != result) {
                              
                              ALAssetRepresentation *assetRespresentation = [result defaultRepresentation];
                              
                              UIImage *picImg = [UIImage imageWithCGImage:[assetRespresentation fullScreenImage]]; //フルスクリーンサイズの画像をpicImgにいれる
                              
                              
                              
                              int i = (int)[group numberOfAssets]-p-1; //最新の写真が0
                              int x = 0; //x座標
                              
                              double n = pow(-1, i);  //-1をi乗した数をresultにいれる
                              
                              if(30< i && i <= 32) //6段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-26; i <=(int)[group numberOfAssets]-p-26; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 406, 24, 24)];
                                  }
                              }
                              
                              else if(32< i && i <= 34) //6段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-30; i <=(int)[group numberOfAssets]-p-30; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 417, 24, 24)];
                                  }
                              }
                              
                              else if(34< i && i <= 36) //6段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-34; i <=(int)[group numberOfAssets]-p-34; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 423, 24, 24)];
                                  }
                              }
                              else if(36< i && i <= 38) //6段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-38; i <=(int)[group numberOfAssets]-p-38; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 427, 24, 24)];
                                  }
                              }
                              
                              
                              else if(38< i && i <= 40) //7段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-34; i <=(int)[group numberOfAssets]-p-34; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 430, 24, 24)];
                                  }
                              }
                              
                              
                              else if(40< i && i <= 42) //7段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-38; i <=(int)[group numberOfAssets]-p-38; i++)
                                  {
                                      x = 136 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 441, 24, 24)];
                                  }
                              }
                              
                              
                              else if(42< i && i <= 44) //7段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-42; i <=(int)[group numberOfAssets]-p-42; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 447, 24, 24)];
                                  }
                              }
                              
                              else if(44< i && i <= 46) //7段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-46; i <=(int)[group numberOfAssets]-p-46; i++)
                                  {
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 451, 24, 24)];
                                  }
                              }
                              
                              
                              else if(46< i && i <= 48) //8段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-42; i <=(int)[group numberOfAssets]-p-42; i++)
                                  {
                                      //NSLog(@"i is %d",(-1)^i);
                                      
                                      x = 138.7 +23.3 *(i/2 + i%2)*n;
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 454, 24, 24)];
                                  }
                                  
                              }
                              
                              
                              
                              
                              else if(48< i && i <= 50) //8段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-46; i <=(int)[group numberOfAssets]-p-46; i++)
                                  {
                                      //NSLog(@"i is %d",(-1)^i);
                                      
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 465, 24, 24)];
                                  }
                                  
                              }
                              
                              
                              else if(50< i && i <= 52) //8段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-50; i <=(int)[group numberOfAssets]-p-50; i++)
                                  {
                                      //NSLog(@"i is %d",(-1)^i);
                                      
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 471, 24, 24)];
                                  }
                              }
                              
                              else if(52< i && i <= 54) //8段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-54; i <=(int)[group numberOfAssets]-p-54; i++)
                                  {
                                      //NSLog(@"i is %d",(-1)^i);
                                      
                                      x = 137 +24 *(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 475, 24, 24)];
                                  }
                              }
                              
                              else if(54 < i && i <= 56) //9段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-50; i <=(int)[group numberOfAssets]-p-50; i++)
                                  {
                                      //NSLog(@"i is %d",i);
                                      
                                      x = 138 +23.5*(i/2 + i%2)*n;
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 478, 24, 24)];
                                  }
                              }
                              
                              else if(56 < i && i <= 58) //9段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-54; i <=(int)[group numberOfAssets]-p-54; i++)
                                  {
                                      //NSLog(@"i is %d",i);
                                      
                                      x = 137 +24*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 489, 24, 24)];
                                  }
                              }
                              
                              else if(58 < i && i <= 60) //9段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-58; i <=(int)[group numberOfAssets]-p-58; i++)
                                  {
                                      NSLog(@"i is %d",i);
                                      
                                      x = 137 +24*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 495, 24, 24)];
                                  }
                                  
                              }
                              
                              else if(60 < i && i <=62) //9段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-62; i <=(int)[group numberOfAssets]-p-62; i++)
                                  {
                                      //NSLog(@"i is %d",i);
                                      
                                      x = 137 +24*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 499, 24, 24)];
                                  }
                                  
                              }
                              
                              else if(62 < i && i <=64) //10段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-58; i <=(int)[group numberOfAssets]-p-58; i++)
                                  {
                                      //NSLog(@"i is %d",i);
                                      
                                      x = 138+22.8*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 502, 24, 24)];
                                  }
                                  
                              }
                              else if(64 < i && i <= 66) //10段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-62; i <=(int)[group numberOfAssets]-p-62; i++)
                                  {
                                      //NSLog(@"i is %d",i);
                                      
                                      x = 137 +23.5*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 513, 24, 24)];
                                  }
                                  
                              }
                              
                              
                              
                              else if(66 < i && i <= 68) //10段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-66; i <=(int)[group numberOfAssets]-p-66; i++)
                                  {
                                      //NSLog(@"i is %d",i);
                                      
                                      x = 137  +24*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 520, 24, 24)];
                                  }
                                  
                              }
                              
                              
                              else if(68 < i && i <= 70) //10段目
                              {
                                  for (i = (int)[group numberOfAssets]-p-70; i <=(int)[group numberOfAssets]-p-70; i++)
                                  {
                                      x = 137  +24*(i/2 + i%2)*n;
                                      
                                      
                                      [array addObject:[NSNumber numberWithInteger:x]];
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 523, 24, 24)];
                                  }
                                  
                              }
                              //else if(64<i&&i<=66)
                              
                              
                              else{
                                  return;
                              }
                              
                              
                              
                              [self.view addSubview:picImgView];
                              
                              picImgView.userInteractionEnabled = YES; //タッチできるようにする
                              //TODO:image
                              picImgView.image = picImg;
                              
                              [self picSetting];
                              //[self.view sendSubviewToBack:picImgView];
                              [self.view sendSubviewToBack:backView];
                          }
                      }
                      /*else{
                       f = 1;
                       //NSLog(@"表示されない");
                       }
                       */
                  }
                  ];
                 
                 *stop = NO;
                 
             }
         }
     }failureBlock:^(NSError *error) {
         //NSLog(@"error: %@", error);
     }
     ];
}



-(void)picSetting
{
    /* 画像の設定 */
    picImgView.contentMode = UIViewContentModeScaleAspectFill;
    picImgView.clipsToBounds = YES;
    
    CALayer *layer = picImgView.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 12.0f;
    
    [picImgView.layer setBorderWidth:1.0];
    [picImgView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
}



//端末の向きの取得
- (void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[notification object] orientation];
    
    if (orientation==UIDeviceOrientationPortraitUpsideDown) {
        _orientation = @"縦(上下逆)";
        
        
        NSLog(@"がめんせんいー");
        
        mosaicViewController *mosaicViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mosaic"];
        mosaicViewViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:mosaicViewViewController animated:YES completion:nil];
        
    }else if (orientation == UIDeviceOrientationPortrait) {
        _orientation = @"縦";
    }
}

- (BOOL)shouldAutorotate
{
    return YES;                                           //回転許可
}

//回転する方向の指定
- (NSUInteger)supportedInterfaceOrientations
{
    //全方位回転
    //return UIInterfaceOrientationMaskAll;
    ////Portrait(HomeButtonが下)のみ
    return UIInterfaceOrientationMaskPortrait;
    
}

@end
