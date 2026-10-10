#include "../../app/src/main/cpp/samp/NavigationGeometry46.h"
#include <cassert>
#include <limits>
struct Point {float x,y;};
int main() {
    using Navigation46::ClipRadarSegment;
    Point a{-2,0},b{2,0}; assert(ClipRadarSegment(a,b));
    assert(std::abs(a.x+0.94f)<0.0001f&&std::abs(b.x-0.94f)<0.0001f);
    a={0,0};b={0.5f,0.5f};assert(ClipRadarSegment(a,b));assert(b.x==0.5f&&b.y==0.5f);
    a={2,2};b={3,3};assert(!ClipRadarSegment(a,b));
    a={0,0};b={2,0};assert(ClipRadarSegment(a,b));assert(a.x==0&&std::abs(b.x-0.94f)<0.0001f);
    a={0,0};b={0,0};assert(!ClipRadarSegment(a,b));
    a={std::numeric_limits<float>::quiet_NaN(),0};b={0,0};assert(!ClipRadarSegment(a,b));
    a={-2,0.95f};b={2,0.95f};assert(!ClipRadarSegment(a,b));
}
