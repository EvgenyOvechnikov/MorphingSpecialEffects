#version 330 compatibility
#extension GL_EXT_gpu_shader4: enable
#extension GL_EXT_geometry_shader4: enable

uniform float		transformFactor;	// Transformation factor

layout( triangles )  in;
layout( triangle_strip, max_vertices=204 )  out;

void
main()
{
	for (int i = 0; i < 3; i++){
		vec4 vert = gl_PositionIn[i];

		// Fixing the long triangles here.
		// For the transform factor 0.02 < t < 0.98 we cut the length of any triangle
		// such that it cannot exceed t. We move only 2nd and 3rd vertex.
		if (i > 0 && 0.02 <= transformFactor && transformFactor <= 0.98){
			float d = distance(vert, gl_PositionIn[0]);
			float t = .2;
			if (d > t){
				vert = gl_PositionIn[0] + (gl_PositionIn[i] - gl_PositionIn[0]) * t / d;
			}
		}

		gl_Position = vert;
		EmitVertex();
	}
}