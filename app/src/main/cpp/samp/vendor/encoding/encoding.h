#pragma once
#include <string>
class Encoding {
public:
    static std::string cp2utf(const std::string& text);
    static std::string utf2cp(const std::string& text);
    // Kept for existing call sites; the SA-MP Portuguese profile uses CP1252.
    static void convert_windows1251_to_utf8(char* dst,const char* src,unsigned int len);
private:
    static bool convert_utf8_to_windows1251(const char* src,char* dst,size_t n);
};
