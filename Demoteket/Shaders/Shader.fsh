//
//  Shader.fsh
//  Demoteket
//
//  Created by Daniel Andersen on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
