#include "ReShade.fxh"

#if RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN
		#define UPSIDE_DOWN_HELP_TEXT "RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN is currently set to 1.\n"\
			"If the Depth map is shown upside down set it to 0."
		#define iUIUpsideDown 1
	#else
		#define UPSIDE_DOWN_HELP_TEXT "RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN is currently set to 0.\n"\
			"If the Depth map is shown upside down set it to 1."
		#define iUIUpsideDown 0
	#endif
	
	#if RESHADE_DEPTH_INPUT_IS_REVERSED
		#define REVERSED_HELP_TEXT "RESHADE_DEPTH_INPUT_IS_REVERSED is currently set to 1.\n"\
			"If close objects in the Depth map are bright and far ones are dark set it to 0.\n"\
			"Also try this if you can see the normals, but the depth view is all black."
		#define iUIReversed 1
	#else
		#define REVERSED_HELP_TEXT "RESHADE_DEPTH_INPUT_IS_REVERSED is currently set to 0.\n"\
			"If close objects in the Depth map are bright and far ones are dark set it to 1.\n"\
			"Also try this if you can see the normals, but the depth view is all black."
		#define iUIReversed 0
	#endif
	
	#if RESHADE_DEPTH_INPUT_IS_LOGARITHMIC
		#define LOGARITHMIC_HELP_TEXT "RESHADE_DEPTH_INPUT_IS_LOGARITHMIC is currently set to 1.\n"\
			"If the Normal map has banding artifacts (extra stripes) set it to 0."
		#define iUILogarithmic 1
	#else
		#define LOGARITHMIC_HELP_TEXT "RESHADE_DEPTH_INPUT_IS_LOGARITHMIC is currently set to 0.\n"\
			"If the Normal map has banding artifacts (extra stripes) set it to 1."
		#define iUILogarithmic 0	
	#endif

uniform float farPlane <
	ui_category = "Advanced settings"; 
	ui_type = "drag";
	ui_label = "Far Plane (Preview)";
	ui_tooltip = "RESHADE_DEPTH_LINEARIZATION_FAR_PLANE=<value>\n"
	             "Changing this value is not necessary in most cases.";
	ui_min = 0.0; ui_max = 1000.0;
	ui_step = 0.1;
> = RESHADE_DEPTH_LINEARIZATION_FAR_PLANE;

uniform float depthMultiplier <
	ui_category = "Advanced settings"; 
	ui_type = "drag";
	ui_label = "Multiplier (Preview)";
	ui_tooltip = "RESHADE_DEPTH_MULTIPLIER=<value>";
	ui_min = 0.0; ui_max = 1000.0;
	ui_step = 0.001;
> = RESHADE_DEPTH_MULTIPLIER;

uniform float colorFlattenFactor <
    ui_category = "Settings";
    ui_type = "drag";
    ui_label = "Color Flatten Factor";
    ui_tooltip = "COLOR_FLATTEN_FACTOR=<value>";
    ui_min = 0.01;
    ui_max = 0.5;
    ui_step = 0.01;
> = 0.15;