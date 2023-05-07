# Unity-URP Spritesheets shaders
===============================================================

This is a repository that contains shader graph shaders to display spritesheets exported from Embergen.

These shaders are provided AS IS, I will not provide any support for this, you have the code, you have some samples and it's free.

Functionality has been split in multiple subgraphs so you can easily create your own shader depending on the features you want, the packing you are using in your textures. 

The provided subgraphs are : 
- SG_6_points_lighting : Computes the lighting for smoke using 2 textures containing the up, down, left, right, front and back lightings. This support multiple dynamic lights (directional, point, spot ...) as well as shadows.
- SG_DepthFade : Soft sprites depth fade function including an offset to support depth map exported from Embergen 
- SG_Frame_animation : Automatic frame animation, used for sprites that are not part of a particle system. Phase is changed depending on the position of the sprite to ensure that they are not all synchronized. Scale of the quad is also affecting the replay framerate : Bigger quads are slower than smaller ones. 
- SG_Frame_uv : Given a frame time (in float), this computes the UVs that can be used to access the spritesheet.
- SG_Orientation : Subgraph including 3 other subgraphs to automatically align the quad as either : camera facing sprite, camera facing sprite using only rotation around Y axis, regular non facing quad. This is working only on meshes that have their faces facing negative Z axis, like the unity Quad.
- SG_Sample_Flipbook : Access a texture using its UVs, very basic
- SG_Sample_Flipbook_with_motion_vector : Access a texture using its UVs and a motion vector texture, so it can smoothly interpolate the image between frames. This requires access to motion vector texture and twice the texture you want to display, this is not free, but worth it if you want smoother spritesheets animations. 

On top of that, there are some typical shaders using these subgraphs : 
- Shader_Emissive_Flames : Using only flames export, supporting depthfade, auto animation, sprite orientation ...
- Shader_Emissive_Smoke : Using only smoke export, supporting depthfade, auto animation, sprite orientation ...
- Shader_Lit_Smoke : Using only smoke export, 6 points lighting, supporting depthfade, auto animation, sprite orientation ...
- Shader_Lit_Smoke_and_Flames : the most feature crammed one, smoke, emissive, 6 points lighting, supporting depthfade, auto animation, sprite orientation ...
- Shader_recoloring_flames : uses flames and temperature export to recolor flames on the go

Can I use this freely?
----------------------
Feel free to use the shaders and provided resources in your projects, improve it, modify it ... 
Just don't sell it and make profit out of it please, it is free on purpose. 