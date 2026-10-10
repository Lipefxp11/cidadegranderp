#include "encoding.h"
#include <cstring>
#include <algorithm>
namespace {
const unsigned special[32]={0x20ac,0x81,0x201a,0x192,0x201e,0x2026,0x2020,0x2021,0x2c6,0x2030,0x160,0x2039,0x152,0x8d,0x17d,0x8f,0x90,0x2018,0x2019,0x201c,0x201d,0x2022,0x2013,0x2014,0x2dc,0x2122,0x161,0x203a,0x153,0x9d,0x17e,0x178};
void append(std::string& s,unsigned u){if(u<128)s+=char(u);else if(u<2048){s+=char(0xc0|(u>>6));s+=char(0x80|(u&63));}else{s+=char(0xe0|(u>>12));s+=char(0x80|((u>>6)&63));s+=char(0x80|(u&63));}}
}
std::string Encoding::cp2utf(const std::string& s){std::string out;for(unsigned char c:s)append(out,c>=128&&c<160?special[c-128]:c);return out;}
std::string Encoding::utf2cp(const std::string& s){std::string out;for(size_t i=0;i<s.size();){unsigned u=(unsigned char)s[i++];if(u>=128){unsigned n=u<224?1:u<240?2:3;u&=(1u<<(6-n))-1;bool valid=true;while(n--){if(i>=s.size()||((unsigned char)s[i]&0xc0)!=0x80){valid=false;break;}u=(u<<6)|((unsigned char)s[i++]&63);}if(!valid)u='?';}if(u<128||(u>=160&&u<=255))out+=char(u);else{auto pos=std::find(std::begin(special),std::end(special),u);out+=pos==std::end(special)?'?':char(128+(pos-special));}}return out;}
void Encoding::convert_windows1251_to_utf8(char* dst,const char* src,unsigned int len){auto s=cp2utf(std::string(src,len));std::memcpy(dst,s.c_str(),s.size()+1);}
bool Encoding::convert_utf8_to_windows1251(const char* src,char* dst,size_t n){auto s=utf2cp(src);if(n==0)return false;size_t len=std::min(n-1,s.size());std::memcpy(dst,s.data(),len);dst[len]=0;return len==s.size();}
