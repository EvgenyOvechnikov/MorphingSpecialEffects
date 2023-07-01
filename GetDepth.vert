#version 330 compatibility

uniform mat4	uLightSpaceMatrix;
uniform mat4	uModel;
uniform float	transformFactor;	// Transformation factor

attribute float xtr;
attribute float ytr;
attribute float ztr;
attribute float nxtr;
attribute float nytr;
attribute float nztr;
attribute float dir;

const float PI = 3.14159265;

float
atan2( float y, float x )
{
	if( x == 0. )
	{
		if( y >= 0. )
			return  PI/2.;
		else
			return -PI/2.;
	}
	return atan(y,x);
}

void
main()
{
	// Computing transformed coordinates
	float currY = gl_Vertex.y + (ytr - gl_Vertex.y) * transformFactor;
	float radius = length( gl_Vertex.xz );
	float theta = atan2( gl_Vertex.z, gl_Vertex.x );

	float radiusTr = length( vec2(xtr, ztr) );
	float thetaTr = atan2( ztr, xtr );

	// 5 rounds counterclockwise, 2 rounds clockwise
	float thetaToGo = (dir == 0.) ? 5*2*PI + (thetaTr - theta) : 2*2*PI - (thetaTr - theta);
	
	float currRadius = radius + (radiusTr - radius) * transformFactor;
	float currentTheta = (dir == 0.) ? theta + thetaToGo * transformFactor : theta - thetaToGo * transformFactor;
	
	vec3 vert = vec3(currRadius * cos(currentTheta), currY, currRadius * sin(currentTheta)); 

    gl_Position = uLightSpaceMatrix * uModel * vec4( vert, 1. );
} 