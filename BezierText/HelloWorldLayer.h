//
//  HelloWorldLayer.h
//  BezierText
//
//  Created by Aaron Pendley on 9/26/11.
//  Copyright CosMind & Blue 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Path.h"


typedef struct
{
	float position;
	float endPosition;	
	int pathIndex;
	float pathIndexPosition;
	int maxDistToNext;
} SSpriteBezierData;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	CCLabelBMFont* bmpFont;
	Path* path;
	SSpriteBezierData* bezierData;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
