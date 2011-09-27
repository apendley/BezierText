//
//  HelloWorldLayer.h
//  BezierText
//
//  Created by Aaron Pendley on 9/26/11.
//  Copyright CosMind & Blue 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

typedef struct
{
	float position;
	float endPosition;	
	int pathIndex;
	float pathIndexPosition;
	int maxDistToNext;
} SBezierSpriteData;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	CCLabelBMFont* bmpFont;
	CGPoint* points;
	SBezierSpriteData* bezierData;
	float bezierLength;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
