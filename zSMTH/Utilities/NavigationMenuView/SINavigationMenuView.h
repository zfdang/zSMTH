//
//  SINavigationMenuView.h
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIMenuTable.h"
#import "SIMenuButton.h"

@protocol SINavigationMenuDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSUInteger)index;

@end

@interface SINavigationMenuView : UIView <SIMenuDelegate>

@property (nonatomic, weak) id <SINavigationMenuDelegate> delegate;
@property (nonatomic, strong) NSArray *items;


// expose the following property and methods, so that we can hide the menu in caller
//- (void)viewWillDisappear:(BOOL)animated
//{
//    SINavigationMenuView *menu = (SINavigationMenuView*) self.navigationItem.titleView;
//    if (menu.menuButton.isActive) {
//        [menu onHideMenu];
//    }
//}
@property (nonatomic, strong) SIMenuButton *menuButton;
- (void)onShowMenu;
- (void)onHideMenu;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)displayMenuInView:(UIView *)view;

@end
