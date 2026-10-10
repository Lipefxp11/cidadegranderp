#include "../../app/src/main/cpp/samp/RoadGraph48.h"
#include <cassert>
#include <chrono>
#include <iostream>
int main(int argc,char**argv){RoadGraph48::Graph g;assert(argc==2&&g.Load(argv[1]));assert(g.nodes.size()==21560);assert(g.Route(-1,0).empty());assert(g.Nearest(9999,9999,0)==-1);auto begin=std::chrono::steady_clock::now();size_t found=0;for(int i=0;i<100;i++){auto a=(i*211)%g.nodes.size(),b=(i*719+900)%g.nodes.size();auto r=g.Route(a,b);if(r.empty())continue;found++;assert(r.front()==a&&r.back()==b);for(size_t j=1;j<r.size();j++){auto& n=g.nodes[r[j-1]];assert(std::find(g.links.begin()+n.first,g.links.begin()+n.first+n.degree,r[j])!=g.links.begin()+n.first+n.degree);}}assert(found>50);std::cout<<"PASS: "<<found<<"/100 road routes, edge continuity, invalid input. 100 searches ms="<<std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now()-begin).count()<<"\n";}
