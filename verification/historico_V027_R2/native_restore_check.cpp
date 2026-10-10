#include <cassert>
#include <string>
#include <iostream>
#include "vendor/encoding/encoding.h"
#include "voice/VoicePacket.cpp"
int main(){auto encoded=Encoding::utf2cp("Ação: João, Olá! R$ 100 €");assert(Encoding::cp2utf(encoded)=="Ação: João, Olá! R$ 100 €");assert(Encoding::utf2cp("/celular")=="/celular");assert(Encoding::utf2cp("/testarmic")=="/testarmic");assert(Encoding::utf2cp("abc")=="abc");assert(Encoding::utf2cp("😀")=="?");assert(CalcCrc32cHash("123456789",9)==0xe3069283);alignas(VoicePacket) unsigned char buffer[sizeof(VoicePacket)]={};auto packet=reinterpret_cast<VoicePacket*>(buffer);packet->svrkey=0xffa17ba2;packet->length=0;packet->CalcHash();assert(packet->CheckHeader());packet->stream=4;assert(!packet->CheckHeader());std::cout<<"Native encoding and voice CRC: 8 checks passed\n";}
