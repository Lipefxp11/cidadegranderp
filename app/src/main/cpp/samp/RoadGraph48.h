#pragma once
#include <vector>
#include <cstdint>
#include <queue>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <algorithm>
#include <limits>
namespace RoadGraph48 {
struct Node {float x,y,z;uint32_t first;uint16_t degree,flags;};
static_assert(sizeof(Node)==20);
struct Graph {
 std::vector<Node> nodes;std::vector<uint32_t> links;
 bool Load(const char* path){
  nodes.clear();links.clear();FILE* f=std::fopen(path,"rb");if(!f)return false;
  char magic[8];uint32_t n=0,e=0;bool ok=fread(magic,1,8,f)==8&&memcmp(magic,"BCG48R01",8)==0&&fread(&n,4,1,f)==1&&fread(&e,4,1,f)==1&&n>0&&n<100000&&e<1000000;
  if(ok){nodes.resize(n);links.resize(e);ok=fread(nodes.data(),sizeof(Node),n,f)==n&&fread(links.data(),4,e,f)==e&&fgetc(f)==EOF;}
  fclose(f);
  if(ok)for(auto& p:nodes)if(!std::isfinite(p.x)||!std::isfinite(p.y)||!std::isfinite(p.z)||std::abs(p.x)>6000||std::abs(p.y)>6000||p.degree>15||uint64_t(p.first)+p.degree>e){ok=false;break;}
  if(ok)for(auto i:links)if(i>=n){ok=false;break;}
  if(!ok){nodes.clear();links.clear();}return ok;
 }
 float Distance(uint32_t a,uint32_t b)const {auto&A=nodes[a];auto&B=nodes[b];return std::hypot(A.x-B.x,A.y-B.y);}
 int Nearest(float x,float y,float z)const{
  int result=-1;float best=250.f*250.f;
  for(size_t i=0;i<nodes.size();i++){auto& p=nodes[i];if(!p.degree)continue;float dx=x-p.x,dy=y-p.y,dz=z-p.z;float score=dx*dx+dy*dy+std::min(dz*dz,10000.f)*.5f;if(score<best){best=score;result=i;}}
  return result;
 }
 std::vector<uint32_t> Route(int start,int end)const{
  if(start<0||end<0||size_t(start)>=nodes.size()||size_t(end)>=nodes.size())return {};
  std::vector<float> distance(nodes.size(),std::numeric_limits<float>::infinity());std::vector<int> parent(nodes.size(),-1);std::vector<bool> visited(nodes.size());
  using Entry=std::pair<float,uint32_t>;std::priority_queue<Entry,std::vector<Entry>,std::greater<Entry>> queue;
  distance[start]=0;queue.push({Distance(start,end),uint32_t(start)});size_t expanded=0;
  while(!queue.empty()&&expanded++<nodes.size()*2){auto [score,i]=queue.top();queue.pop();if(visited[i])continue;visited[i]=true;if(i==uint32_t(end))break;auto& p=nodes[i];
   for(uint32_t k=p.first;k<p.first+p.degree;k++){auto j=links[k];if(visited[j])continue;float candidate=distance[i]+Distance(i,j);if(candidate<distance[j]){distance[j]=candidate;parent[j]=i;queue.push({candidate+Distance(j,end),j});}}
  }
  if(!visited[end])return {};std::vector<uint32_t> result;for(int i=end;i>=0;i=parent[i]){result.push_back(i);if(i==start)break;if(result.size()>nodes.size())return {};}
  std::reverse(result.begin(),result.end());return result;
 }
};
}
