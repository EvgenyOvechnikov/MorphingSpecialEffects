#version 330 compatibility

uniform	mat4 	uLightSpaceMatrix;
uniform mat4 	uModel;
uniform mat4 	uView;
uniform mat4 	uProj;
uniform float	uLightX;
uniform float	uLightY;
uniform float	uLightZ;
uniform float	transformFactor;	// Transformation factor

out vec4 vFragPosLightSpace;
out vec3 vNs;
out vec3 vLs;
out vec3 vEs;

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
	vec3 LightPosition = vec3(uLightX, uLightY, uLightZ);

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

	// Normals are interpolated linearly so far
	vec3 norm = gl_Normal.xyz + (vec3(nxtr, nytr, nztr) - gl_Normal.xyz) * transformFactor;

	vec4 ECposition = uView * uModel * vec4( vert, 1. );
    vec3 tnorm = normalize( mat3(uModel) * norm );
	vNs = tnorm;
	vLs = LightPosition      - ECposition.xyz;
	vEs = vec3( 0., 0., 0. ) - ECposition.xyz;
        
	vFragPosLightSpace = uLightSpaceMatrix  * uModel * vec4( vert, 1. );
	gl_Position        = uProj * uView      * uModel * vec4( vert, 1. );
}