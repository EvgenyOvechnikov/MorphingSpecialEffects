# OpenGL Morphing with Special Effects
![Final Project (1)](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/a45a4096-7259-4871-b31f-e1714e775c59)<br/>

Please check out the full demo video with explanations here: (markup syntax doesn't allow to embed it)<br/>
https://media.oregonstate.edu/media/t/1_2yigxgbu<br/>
Make sure to watch with the sound on! :)<br/>
<br/>
The solution should run out of the box in Visual studio. When run, use mouse to move the scene. Use the keys to do the following:<br/>
d - Transform the objects forward,<br/>
a - Transform the objects backward,<br/>
l - Toggle the light source visibility,<br/>
t,y,g,h,b,n - Move the light source in 3 dimentions back and forth.<br/>
<br/>
Storing information in a texture unit is a common way to pass the information to shader. 24-bit .bmp has three (rgb) 8-bit components at each texel, so we can for each vertex of a source model paint a pixel with the corresponding s and t coordinates with the color of the three components we need. First thing we need to find out is what new coordinates we want for each vertex.</br>
I modified the existing code that loads object file in order to return the lists of vertices, normals and texture coordinates in the calling code, so I could actually build the polygon structure in code and perform operations with them. My first idea was to assign each triangle the nearest triangle of the transformed structure, using greedy picking strategy. The brute force solution takes O(n3) time, it performs picking of the nearest polygons for two models with 10,000 polygons overnight. For heavier models, a fair amount of effort should be invested to come up with O(n2 log n) algorithm. However, with the further exploration of the problem, I gave up all the sorting and nearest polygon alignment at all. Here is why.<br/>
<br/>
For arbitrary 3D models we cannot guarantee that each vertex will have the same amount of polygons attached to it, even for the simple geometry. Let’s take a look at the 34-polygon sphere made in Blender, and then to 34-polygon cylinder. For the sphere, we see the vertices that are common to 4 to 8 triangles, but the cylinder is modeled in such a way that its top and bottom have many triangles having the same common point. In this particular case, there’s a point which has 10 polygons attached to it.
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/a754710f-98c2-4dac-800c-e1a45d068e80) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/a2e0c276-1d7b-4d01-8c04-473c36a2024b)<br/>
<br/>
This means, if we simply interpolate coordinates from one position to another, at least some of the triangles immediately start diverging from each other, making the smooth transformation hardly ever achievable.<br/>
Another tricky question is storing coordinates in the texture. Let’s assume we have properly assigned s and t coordinates to all the vertices. (In fact, there’s an impressively intelligent tool in Blender to do that automatically.) Now, we want to look at the texture and find the pixel painted exactly to that rgb which we painted it earlier, when encode coordinates of the model we wish to transform to. The first problem is, in 24-bit .bmp we have only 8 bits to store the coordinate, so, whatever model size we have, the coordinates will theoretically be quantized to a maximum of 256 steps from smallest value to biggest. The second problem is, if s or t do not point exactly to the texel, keeping in mind that their value ranges from 0. to 1. regardless of the texture resolution, the hardware tries to interpolate it with the neighbor texels, which we don’t want. I tried two workarounds – manually quantize s and t according to the texture resolution to point exactly at the texel center, and paint neighbor texels with the same color. Either way, for the simple 34-polygon models one or several vertices would try to go to the unexpected new location.<br/>
<br/>
After a while, I found out about the attribute values for the vertex and decided to use them. Moreover, if we cannot avoid the triangles to break apart when the transformation happens, there’s no need to preemptively assign nearest triangles of the original and transformed model. I decided to build a scene when one model breaks apart to a vortex of triangles, and after some circular movements puts together in the different model. Each triangle makes the spiral move around the Y axis, half of the triangles goes 2 rounds clockwise, half goes 5 rounds counter-clockwise. I pass the transformed coordinates, normals, and direction information in the attribute variables.<br/>
<br/>
To make a perfect transformation, we need to have two 3D models with the exact same amount of triangles. To get the models, I used Blender modifier called “Decimate”. The great thing about it that it works even on imported geometry. We don’t have to have parametrized or source .blend file. I imported high-polygon .obj files into Blender, and use “Decimate” to reduce the polygon number to exactly 10,000 for two models. It took a couple of iterations to get exactly 10,000, but it’s good to have such a powerful tool for 3D modeling for free. I used Steam version of Blender (3.4.1), it is super convenient the developers maintain it on Steam.<br/>
<br/>
Two models I use for transformation:<br/>
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/eb383ad2-c9e1-4f70-9257-24515bda836e) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/186d9d7a-066c-4519-9657-b9b529f58184)<br/>
<br/>
When the transformation happens, the vertices only know their start and end coordinates and spin direction. They do not care about other vertices, and there can be the situation when two or all three vertices of the same triangle appear far away from each other. This looks like solid triangular plates among the small triangles around, and destroys the feel of the special effect:<br/>
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/d26aebbd-d05a-4cca-bd73-3b4e5382b2a0)<br/>
<br/>
To fix it, instead of thinking how to move vertices differently, I use geometry shader to fix the size of a triangle. The feature of the geometry shader is each vertex knows the information of two other vertices of the same triangle. With the vector math provided in GLSL, I check very easily if the triangle exceeds the reasonable size, and fix the distance if necessary. The result looks like a cloud of small triangles, which is what I wanted:<br/>
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/742e56a5-da3e-4ae6-b32b-ba969458ca0b)
<br/>
Finally, I wanted to add more effects than a per-fragment lighting. Shadows give the scene extra depth and visual plausibility. So, I used the code from the class notes and added my special effect transformations to both of the render passes, so each triangle casts its own shadow. It actually now looks like sort of a cartoon scene. Notice how shadow matches to what the model state is:<br/>
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/b67e1a0e-df03-408f-9317-adb43e4143ba) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/b175389b-8e24-445e-aa57-8eaaa4d61ca5) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/1a294a1f-7df8-4f7e-9d48-816ddd409d5e) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/4685bf6d-ab17-4db1-a785-6717077c0d80) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/20b835f2-44a4-46bb-a352-8147f4c8a63f) 
![image](https://github.com/EvgenyOvechnikov/OpenGLMorphingSpecialEffects/assets/61941266/31c22553-250c-4d15-b865-51436d42c8ff)<br/>
<br/>
To sum up, I gave up transferring information through texture and aligning nearest polygons between two models. Instead, I discovered more efficient way for transferring additional vertex information for this particular task, through attribute variables. The transformation is done with the vertex and geometry shaders, which is much more efficient as if it was done procedurally on CPU with single-thread OpenGL instructions.<br/>
<br/>
Thank you. Have Fun!
