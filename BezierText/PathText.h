//
//  BezierText.h
//  BezierText
//
//  Created by Aaron Pendley on 9/29/11.
//  Copyright 2011 CosMind & Blue. All rights reserved.
//

#import "cocos2d.h"
#import "Path.h"

typedef enum
{
	ePTD_Forward,
	ePTD_Backward
} EPathTextDirection;

typedef struct
{
	float position;
	float endPosition;	
	int pathIndex;
	float pathIndexPosition;
	int maxDistToNext;
} SSpritePathData;

@interface PathText : CCSpriteBatchNode <CCRGBAProtocol>
{
	Path* path;
	SSpritePathData* pathData;
	float speed;
	
	// texture RGBA
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL opacityModifyRGB_;
}

/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readwrite) GLubyte opacity;
/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readwrite) ccColor3B color;

+(id)pathTextWithString:(NSString*)string fntFile:(NSString*)fntFile path:(Path*)path direction:(EPathTextDirection)direction speed:(float)speed;

-(id) initWithString:(NSString*)string fntFile:(NSString*)fntFile path:(Path*)path direction:(EPathTextDirection)direction speed:(float)speed;

@end
