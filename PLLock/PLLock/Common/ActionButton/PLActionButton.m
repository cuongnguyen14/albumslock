//
//  PLActionButton.m
//  PLLock
//
//  Created by CuongNguyen on 5/23/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLActionButton.h"

@implementation PLActionButton

+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit
                                     actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler {
    PLActionButton *button = [super plusButtonsViewWithNumberOfButtons:numberOfButtons firstButtonIsPlusButton:firstButtonIsPlusButton showAfterInit:showAfterInit actionHandler:actionHandler];
    
    if (button) {
        
        button.coverColor = [UIColor colorWithWhite:0.f alpha:0.3];
        button.position = LGPlusButtonsViewPositionBottomRight;
        button.showHideOnScroll = YES;
        button.plusButtonAnimationType = LGPlusButtonAnimationTypeRotate;
        button.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical;
        
        [button setButtonsAdjustsImageWhenHighlighted:NO];
        [button setButtonsBackgroundColor:MakeColor(255, 26, 85, 1) forState:UIControlStateNormal];
        [button setButtonsBackgroundColor:MakeColor(244, 69, 114, 1) forState:UIControlStateHighlighted];
        [button setButtonsBackgroundColor:MakeColor(255, 26, 85, 1) forState:UIControlStateHighlighted|UIControlStateSelected];
        [button setButtonsSize:CGSizeMake(34.f, 34.f) forOrientation:LGPlusButtonsViewOrientationAll];
        [button setButtonsLayerCornerRadius:34.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
        [button setButtonsTitleFont:[UIFont boldSystemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationAll];
        [button setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
        [button setButtonsLayerShadowOpacity:0.5];
        [button setButtonsLayerShadowRadius:3.f];
        [button setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
        [button setButtonAtIndex:0 size:CGSizeMake(48.f, 48.f)
                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
        [button setButtonAtIndex:0 layerCornerRadius:48.f/2.f
                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
        [button setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:40.f]
                                forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
        [button setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -3.f) forOrientation:LGPlusButtonsViewOrientationAll];
        [button setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.f blue:0.5 alpha:1.f] forState:UIControlStateNormal];
        [button setButtonAtIndex:1 backgroundColor:[UIColor colorWithRed:1.f green:0.2 blue:0.6 alpha:1.f] forState:UIControlStateHighlighted];
//        [button setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.5 blue:0.f alpha:1.f] forState:UIControlStateNormal];
//        [button setButtonAtIndex:2 backgroundColor:[UIColor colorWithRed:1.f green:0.6 blue:0.2 alpha:1.f] forState:UIControlStateHighlighted];
        
        [button setDescriptionsBackgroundColor:[UIColor whiteColor]];
        [button setDescriptionsTextColor:[UIColor blackColor]];
        [button setDescriptionsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
        [button setDescriptionsLayerShadowOpacity:0.25];
        [button setDescriptionsLayerShadowRadius:1.f];
        [button setDescriptionsLayerShadowOffset:CGSizeMake(0.f, 1.f)];
        [button setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
        [button setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
        
        for (NSUInteger i=1; i<=numberOfButtons-1; i++)
            [button setButtonAtIndex:i offset:CGPointMake(-8.f, 0.f)
                                    forOrientation:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationAll)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [button setButtonAtIndex:0 titleOffset:CGPointMake(0.f, -2.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
            [button setButtonAtIndex:0 titleFont:[UIFont systemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
        }
        
    }
    
    return button;
}
@end
