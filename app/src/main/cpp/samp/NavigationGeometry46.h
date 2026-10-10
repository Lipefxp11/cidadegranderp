#pragma once
#include <algorithm>
#include <cmath>
namespace Navigation46 {
// Parametric circle clipping preserves street segments at the minimap boundary.
template<class Point> bool ClipRadarSegment(Point& a,Point& b) {
    if(!std::isfinite(a.x)||!std::isfinite(a.y)||!std::isfinite(b.x)||!std::isfinite(b.y)) return false;
    const float dx=b.x-a.x,dy=b.y-a.y,A=dx*dx+dy*dy;
    if(A<0.000001f) return false;
    const float B=2*(a.x*dx+a.y*dy),C=a.x*a.x+a.y*a.y-0.94f*0.94f;
    const float discriminant=B*B-4*A*C;
    if(discriminant<0) return false;
    const float root=std::sqrt(discriminant);
    const float lo=std::max(0.f,(-B-root)/(2*A)),hi=std::min(1.f,(-B+root)/(2*A));
    if(lo>=hi) return false;
    b={a.x+hi*dx,a.y+hi*dy}; a={a.x+lo*dx,a.y+lo*dy}; return true;
}
}
