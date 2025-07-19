Shader "Red Studios/Filters/CRTFilter"
{
    Properties
    {
        _MainTex            ("Base (RGB)",    2D)    = "white" {}
        _ScanIntensity      ("Scanline Intensity", Range(0,1))   = 0.3
        _Distortion         ("Barrel Distortion",  Range(0,0.2)) = 0.05
        _RGBOffset          ("Chromatic Aberration", Range(0,0.02)) = 0.005
        _FlickerAmp         ("Flicker Amplitude",  Range(0,0.2)) = 0.05
        _NoiseIntensity     ("Noise Intensity",    Range(0,0.1)) = 0.02
    }
    SubShader
    {
        Cull Off ZTest Always ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float    _ScanIntensity;
            float    _Distortion;
            float    _RGBOffset;
            float    _FlickerAmp;
            float    _NoiseIntensity;

            float4 frag(v2f_img i) : SV_Target
            {
                // UV coordinates
                float2 uvc = i.uv * 2 - 1;

                // Barrel distortion
                float r2    = dot(uvc, uvc);
                float2 disp = uvc * (1 + _Distortion * r2);
                float2 uv   = (disp + 1) * 0.5;

                // Chromatic Aberration: apply RGB offset
                float2 chroma = disp * _RGBOffset;
                float r = tex2D(_MainTex, uv + chroma).r;
                float g = tex2D(_MainTex, uv).g;
                float b = tex2D(_MainTex, uv - chroma).b;
                float3 col = float3(r, g, b);

                // Scan‑lines
                float t = _Time.y;
                float scan = sin(i.uv.y * _ScreenParams.y * 1.5 + t * 10) * _ScanIntensity;
                col -= scan;

                // Flicker effect
                float flick = (sin(t * 20) * 0.5 + 0.5) * _FlickerAmp;
                col += flick;

                // Noise effect
                float noise = frac(sin(dot(i.uv * _ScreenParams.xy, float2(12.9898,78.233))) * 43758.5453);
                col += (noise - 0.5) * _NoiseIntensity;

                return float4(col, 1);
            }
            ENDCG
        }
    }
}
