// Copyright (c) 2012, Daniel Andersen (dani_ande@yahoo.dk)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

precision lowp float;

varying vec2 v_Coordinates;

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform vec2 screenSizeInv;
uniform vec2 offscreenSizeInv;
uniform float refractionConstant;

void main()
{
    vec4 displacementColor = texture2D(texture0, v_Coordinates) - vec4(0.5, 0.5, 0.5, 0.0);
    vec2 displacement = vec2(displacementColor.r, displacementColor.g);
    //vec2 tex1 = vec2(gl_FragCoord.x * (1.0 / 1024.0), gl_FragCoord.y * (1.0 / 768.0));
    //vec2 tex1 = vec2(gl_FragCoord.x * (1.0 / 480.0), gl_FragCoord.y * (1.0 / 320.0)) + (displacement * 0.03);
    vec2 tex1 = vec2(gl_FragCoord.x * screenSizeInv.y, gl_FragCoord.y * screenSizeInv.x) + (displacement * 0.03);
    vec2 tex2 = tex1 + vec2(-offscreenSizeInv.x, 0.0);
    vec2 tex3 = tex1 + vec2( offscreenSizeInv.x, 0.0);
    vec2 tex4 = tex1 + vec2(0.0, -offscreenSizeInv.y);
    vec2 tex5 = tex1 + vec2(0.0,  offscreenSizeInv.y);
    
    float refraction = min((gl_FragCoord.y * refractionConstant) + (1.0 - texture2D(texture0, v_Coordinates).b) * 0.5, 1.0);
    vec4 floorColor = vec4(0.1, 0.09, 0.075, 1.0);

    float a = min(texture2D(texture0, v_Coordinates).b + 0.15, 1.0);

    vec4 color = ((texture2D(texture1, tex2) * 0.25) + (texture2D(texture1, tex3) * 0.25) + (texture2D(texture1, tex4) * 0.25) + (texture2D(texture1, tex4) * 0.25)) * 0.8;
	gl_FragColor = (refraction * color) + ((1.0 - refraction) * floorColor);
}
