//
//  GVGoogleBannerView.h
//
//  Created by Kevin Renskers on 13-09-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <Google-Mobile-Ads-SDK/DFPBannerView.h>
#import <UIKit/UIKit.h>

@class GVGoogleBannerView;
@protocol GVGoogleBannerViewDelegate <NSObject>

@required
- (NSString *)googleBannerViewAdUnitID;

@optional
- (void)googleBannerViewOpened:(GVGoogleBannerView *)googleBannerView;
- (void)googleBannerViewClosed:(GVGoogleBannerView *)googleBannerView;
- (BOOL)googleBannerViewEnabled;
- (BOOL)googleBannerViewHasCloseAdButton;
- (UIButton *)googleBannerViewCloseAdButton;
- (NSDictionary *)googleBannerTargeting;

@end


@interface GVGoogleBannerView : DFPBannerView

@property (weak, nonatomic) IBOutlet UIViewController <GVGoogleBannerViewDelegate> *googleBannerViewDelegate;

- (void)openAd;
- (void)closeAd;
- (void)refreshAd;

@end
