//
//  AppDelegate.h
//  BezierText
//
//  Created by Aaron Pendley on 9/26/11.
//  Copyright CosMind & Blue 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
