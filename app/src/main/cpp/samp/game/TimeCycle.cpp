//
// Created by x1y2z on 20.09.2023.
//

#include "TimeCycle.h"
#include "../vendor/armhook/patch.h"

void CTimeCycle::InjectHooks() {
    CHook::Write(g_libGTASA + 0x8397D0, &CTimeCycle::m_CurrentColours);
    CHook::Write(g_libGTASA + 0x83A828, &CTimeCycle::m_BelowHorizonGrey);
}

#include <algorithm>
#include <cmath>
void CTimeCycle::ApplyCityLighting52(float boost){
 if(!std::isfinite(boost)||boost<=0.0f)return;
 boost=std::min(boost,0.20f);
 float* channels[]={&m_CurrentColours.m_fAmbientRed,&m_CurrentColours.m_fAmbientGreen,&m_CurrentColours.m_fAmbientBlue,&m_CurrentColours.m_fAmbientRed_Obj,&m_CurrentColours.m_fAmbientGreen_Obj,&m_CurrentColours.m_fAmbientBlue_Obj};
 for(float* channel:channels){if(std::isfinite(*channel)&&*channel>=0.0f&&*channel<=1.0f)*channel=std::min(1.0f,*channel+boost*0.35f*(1.0f-*channel)*(1.0f-*channel));}
}
