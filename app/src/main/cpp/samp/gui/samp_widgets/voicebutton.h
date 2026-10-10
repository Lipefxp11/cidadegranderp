#pragma once
#include "game/game.h"
#include "game/util.h"
#include "main.h"
#include "settings.h"
#include "util/CUtil.h"
#include "voice/Plugin.h"
extern CSettings* pSettings;
class VoiceButton : public Button {
public:
    VoiceButton() : Button("MIC", UISettings::fontSize() / 2) {
        m_texture_micro_on = (RwTexture*)CUtil::LoadTextureFromDB("samp", "micro_active");
        m_texture_micro_off = (RwTexture*)CUtil::LoadTextureFromDB("samp", "micro_passive");
    }
    void draw(ImGuiRenderer* renderer) override {
        if (pSettings && !pSettings->GetReadOnly().bVoiceChatEnable) return;
        auto texture = recording() ? m_texture_micro_on : m_texture_micro_off;
        if (texture && texture->raster)
            renderer->drawImage(absolutePosition(), absolutePosition() + size(), texture->raster);
        else Button::draw(renderer);
    }
    // Track the microphone finger independently from the movement thumb.
    bool handleTouch(const ImVec2& pos, int action, int finger) {
        if (action == 2 && visible() && contains(pos) && m_finger < 0) {
            if (pSettings && !pSettings->GetReadOnly().bVoiceChatEnable) return false;
            m_finger = finger; touchPushEvent(); return true;
        }
        if (finger != m_finger || m_finger < 0) return false;
        if (action == 1) touchPopEvent();
        return true;
    }
    void touchEvent(const ImVec2&, TouchType) override {}
    void touchPushEvent() override { setRecording(true); Plugin::SetPTT(66, true); }
    void touchPopEvent() override { setRecording(false); Plugin::SetPTT(66, false); }
    void setRecording(bool value) {
        m_recording = value; if (!value) m_finger = -1;
        setCaptionColor(value ? ImColor(0.3f, 1.0f, 0.5f) : ImColor(1.0f, 1.0f, 1.0f));
    }
    bool recording() const { return m_recording; }
private:
    bool m_recording = false;
    int m_finger = -1;
    RwTexture* m_texture_micro_on = nullptr;
    RwTexture* m_texture_micro_off = nullptr;
};
