//
//  HelloWorldLayer.m
//  BezierText
//
//  Created by Aaron Pendley on 9/26/11.
//  Copyright CosMind & Blue 2011. All rights reserved.
//




// Import the interfaces
#import "HelloWorldLayer.h"
#import "PathText.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( ![super init] )
		return nil;
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	// points will be relative to PathText object, which will have an anchorPoint of 0.5, 0.5
	CGPoint controlPoints[4] = 
	{
		{ winSize.width/2 - 30, -winSize.height/2 + 30 },
		{ winSize.width/2 * 0.66666, winSize.height/2 * 0.75f },
		{ -winSize.width/2 * 0.333333, winSize.height/2 * 0.75f },
		{ -winSize.width/2 + 30, -winSize.height/2 + 30}
	};
	
	Path* path = [Path pathWithCapacity:100];
	[path addPointsWithBezier:controlPoints pointCount:100];
	
	PathText* pathText = [PathText pathTextWithString:@"Text on a bezier!!!!" fntFile:@"bitmapFontTest4.fnt" path:path direction:ePTD_Forward speed:60.0f];
	pathText.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
	
	[self addChild:pathText];

	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}
@end
