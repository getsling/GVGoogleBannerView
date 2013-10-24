//
//  GVGoogleBannerView.m
//
//  Created by Kevin Renskers on 13-09-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <Google-AdMob-Ads-SDK/DFPExtras.h>
#import "GVGoogleBannerView.h"


@interface GVGoogleBannerView () <GADBannerViewDelegate>
@property (strong, nonatomic) UIButton *closeButton;
@end


@implementation GVGoogleBannerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.hidden = YES;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        if ([self.googleBannerViewDelegate respondsToSelector:@selector(googleBannerViewCloseAdButton)]) {
            _closeButton = [self.googleBannerViewDelegate googleBannerViewCloseAdButton];
        } else {
            // Default close button
            self.clipsToBounds = NO;
            _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _closeButton.frame = CGRectMake(self.bounds.size.width-40, -10, 40, 40);
            _closeButton.hidden = YES;
            _closeButton.accessibilityLabel = @"Close banner";
            [_closeButton setImage:[UIImage imageNamed:@"b_ad_close"] forState:UIControlStateNormal];
            [_closeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 12, 12, 0)];
            [_closeButton addTarget:self action:@selector(closeAd) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    return _closeButton;
}

- (void)drawRect:(CGRect)rect {
    self.adSize = GADAdSizeFromCGSize(self.bounds.size);
    self.delegate = self;
    self.rootViewController = self.googleBannerViewDelegate;

    [self openAd];

    [super drawRect:rect];
}

- (BOOL)enabled {
    BOOL enabled = YES;
    if ([self.googleBannerViewDelegate respondsToSelector:@selector(googleBannerViewEnabled)]) {
        enabled = [self.googleBannerViewDelegate googleBannerViewEnabled];
    }
    return enabled;
}

- (BOOL)hasCloseAdButton {
    BOOL hasCloseAdButton = YES;
    if ([self.googleBannerViewDelegate respondsToSelector:@selector(googleBannerViewHasCloseAdButton)]) {
        hasCloseAdButton = [self.googleBannerViewDelegate googleBannerViewHasCloseAdButton];
    }
    return hasCloseAdButton;
}

- (void)openAd {
    if ([self enabled]) {
        self.adUnitID = [self.googleBannerViewDelegate googleBannerViewAdUnitID];

        // Load the ad, enable testing on simulator
        GADRequest *request = [GADRequest request];
        request.testDevices = @[GAD_SIMULATOR_ID];

        // Send extra targeting params
        if ([self.googleBannerViewDelegate respondsToSelector:@selector(googleBannerTargeting)]) {
            NSDictionary *targetDict = [self.googleBannerViewDelegate googleBannerTargeting];
            if (targetDict) {
                DFPExtras *extras = [[DFPExtras alloc] init];
                extras.additionalParameters = targetDict;
                [request registerAdNetworkExtras:extras];
            }
            NSLog(@"Requesting banner with ad unit id %@ for size %@ and targeting %@", self.adUnitID, NSStringFromCGSize(self.bounds.size), targetDict);
        } else {
            NSLog(@"Requesting banner with ad unit id %@ for size %@", self.adUnitID, NSStringFromCGSize(self.bounds.size));
        }

        [self loadRequest:request];
    }
}

- (void)closeAd {
    if (!self.hidden) {
        self.hidden = YES;
        if ([self.googleBannerViewDelegate respondsToSelector:@selector(googleBannerViewClosed:)]) {
            [self.googleBannerViewDelegate googleBannerViewClosed:self];
        }
    }
}

- (void)refreshAd {
    [self openAd];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    if (self.hidden) {
        self.hidden = NO;

        if ([self hasCloseAdButton]) {
            if (!self.closeButton.superview) {
                [self addSubview:self.closeButton];
            }

            self.closeButton.hidden = NO;
            [self bringSubviewToFront:self.closeButton];
        } else {
            self.closeButton.hidden = YES;
            [self sendSubviewToBack:self.closeButton];
        }

        if ([self.googleBannerViewDelegate respondsToSelector:@selector(googleBannerViewOpened:)]) {
            [self.googleBannerViewDelegate googleBannerViewOpened:self];
        }
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"didFailToReceiveAdWithError: %@", error);
    [self closeAd];
}

@end
