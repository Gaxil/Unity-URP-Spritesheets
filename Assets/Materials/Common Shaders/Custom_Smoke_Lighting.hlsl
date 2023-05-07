#ifndef CUSTOM_SMOKE_LIGHTING
#define CUSTOM_SMOKE_LIGHTING

// This is a neat trick to work around a bug in the shader graph when
// enabling shadow keywords. Created by @cyanilux
// https://github.com/Cyanilux/URP_ShaderGraphCustomLighting
// Licensed under the MIT License, Copyright (c) 2020 Cyanilux
#ifndef SHADERGRAPH_PREVIEW
	#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
	#if (SHADERPASS != SHADERPASS_FORWARD)
		#undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
	#endif
#endif

struct CustomLightingData {
	// Position and orientation
	float3 positionWS;
	float3 normalWS;
	float3 tangentlWS;
	float3 binormalWS;
	float3 viewDirectionWS;

	// Lighting intensities
	float2 lightTopBottom;
	float2 lightRightLeft;
	float2 lightBackFront;

	// Shadows
	float4 shadowCoord;
	float shadowsStrength;

	// Baked lighting
	float3 bakedGI;
	float4 shadowMask;
	float fogFactor;
};

#ifndef SHADERGRAPH_PREVIEW
float3 CustomGlobalIllumination(CustomLightingData d) {
	float3 indirectDiffuse =  d.bakedGI;
	return indirectDiffuse;
}

float3 CustomLightHandling(CustomLightingData d, Light light) {
	float3 radiance = light.color * (light.distanceAttenuation * lerp(1.0, light.shadowAttenuation, d.shadowsStrength));

	float3x3 tangentTransform_World = float3x3(d.tangentlWS, d.binormalWS, d.normalWS);
	float3 light_dir_tangent_space = TransformWorldToTangent(light.direction, tangentTransform_World);

	float3 light_X = (light_dir_tangent_space.x > 0.0 ? d.lightRightLeft.x : d.lightRightLeft.y).xxx;
	float3 light_Y = (light_dir_tangent_space.y > 0.0 ? d.lightTopBottom.x : d.lightTopBottom.y).xxx;
	float3 light_Z = (light_dir_tangent_space.z > 0.0 ? d.lightBackFront.x : d.lightBackFront.y).xxx;

	light_X *= smoothstep(0.0, 1.0, abs(light_dir_tangent_space.x));
	light_Y *= smoothstep(0.0, 1.0, abs(light_dir_tangent_space.y));
	light_Z *= smoothstep(0.0, 1.0, abs(light_dir_tangent_space.z));
	float combined_light = light_X + light_Y + light_Z;

	float3 color = combined_light * radiance;

	return color;
}
#endif

float3 CalculateCustomLighting(CustomLightingData d) {
#ifdef SHADERGRAPH_PREVIEW
	// In preview, estimate diffuse + specular
	float intensity = 0.5;
	return intensity.xxx;
#else

	// Get the main light. Located in URP/ShaderLibrary/Lighting.hlsl
	Light mainLight = GetMainLight(d.shadowCoord, d.positionWS, d.shadowMask);
	// In mixed subtractive baked lights, the main light must be subtracted
	// from the bakedGI value. This function in URP/ShaderLibrary/Lighting.hlsl takes care of that.
	MixRealtimeAndBakedGI(mainLight, d.normalWS, d.bakedGI);
	float3 color = CustomGlobalIllumination(d);
	// Shade the main light
	color += CustomLightHandling(d, mainLight);

	#ifdef _ADDITIONAL_LIGHTS
		// Shade additional cone and point lights. Functions in URP/ShaderLibrary/Lighting.hlsl
		uint numAdditionalLights = GetAdditionalLightsCount();
		for (uint lightI = 0; lightI < numAdditionalLights; lightI++) {
			Light light = GetAdditionalLight(lightI, d.positionWS, d.shadowMask);
			color += CustomLightHandling(d, light);
		}
	#endif

	color = MixFog(color, d.fogFactor);

	return color;
#endif
}

void CalculateCustomLighting_float( float3 Position, 
									float3 NormalWS, 
									float3 TangentWS, 
									float3 BinormalWS, 
									float3 ViewDirection,
									float2 LightTopBottom,
									float2 LightRightLeft,
									float2 LightBackFront,
									float ShadowsStrength,
									out float3 Color) {

	CustomLightingData d;
	d.positionWS = Position;
	d.normalWS = NormalWS;
	d.tangentlWS = TangentWS;
	d.binormalWS = BinormalWS;
	d.viewDirectionWS = ViewDirection;
	d.lightTopBottom = LightTopBottom;
	d.lightRightLeft = LightRightLeft;
	d.lightBackFront = LightBackFront;
	d.shadowsStrength = ShadowsStrength;

#ifdef SHADERGRAPH_PREVIEW
	// In preview, there's no shadows or bakedGI
	d.shadowCoord = 0;
	d.bakedGI = 0;
	d.shadowMask = 0;
	d.fogFactor = 0;
#else
	// Calculate the main light shadow coord
	// There are two types depending on if cascades are enabled
	float4 positionCS = TransformWorldToHClip(Position);
	#if SHADOWS_SCREEN
		d.shadowCoord = ComputeScreenPos(positionCS);
	#else
		d.shadowCoord = TransformWorldToShadowCoord(Position);
	#endif

	// The following URP functions and macros are all located in
	// URP/ShaderLibrary/Lighting.hlsl
	// Technically, OUTPUT_LIGHTMAP_UV, OUTPUT_SH and ComputeFogFactor
	// should be called in the vertex function of the shader. However, as of
	// 2021.1, we do not have access to custom interpolators in the shader graph.

	// The lightmap UV is usually in TEXCOORD1
	// If lightmaps are disabled, OUTPUT_LIGHTMAP_UV does nothing
	float2 lightmapUV;
	OUTPUT_LIGHTMAP_UV(LightmapUV, unity_LightmapST, lightmapUV);
	// Samples spherical harmonics, which encode light probe data
	float3 vertexSH;
	OUTPUT_SH(NormalWS, vertexSH);
	// This function calculates the final baked lighting from light maps or probes
	d.bakedGI = SAMPLE_GI(lightmapUV, vertexSH, NormalWS);
	// This function calculates the shadow mask if baked shadows are enabled
	d.shadowMask = SAMPLE_SHADOWMASK(lightmapUV);
	// This returns 0 if fog is turned off
	// It is not the same as the fog node in the shader graph
	d.fogFactor = ComputeFogFactor(positionCS.z);
#endif

	Color = CalculateCustomLighting(d);
}

#endif