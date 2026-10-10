#include "../main.h"
#include "../gui/gui.h"
#include "../game/game.h"

#include "Plugin.h"
#include "../settings.h"
extern CSettings* pSettings;

#include "include/util/KeyFilter.h"
#include "include/util/Timer.h"

#include "Record.h"
#include "Playback.h"
#include "Network.h"
//#include "BlackList.h"
#include "PluginConfig.h"
#include "MicroIcon.h"
#include "SpeakerList.h"
#include "GlobalStream.h"
#include "StreamAtPoint.h"
#include "StreamAtVehicle.h"
#include "StreamAtPlayer.h"
#include "StreamAtObject.h"

extern UI* pUI;
extern CGame* pGame;

bool Plugin::OnPluginLoad() noexcept
{
    LogVoice("[Cidade Grande SA-MP] VoIP client ready\n");

    if(!CVoiceRender::Init())
    {
        LogVoice("[sv:err:plugin] : failed to init render module");
        return false;
    }

    CVoiceRender::AddDeviceInitCallback(Plugin::OnDeviceInit);
    CVoiceRender::AddRenderCallback(Plugin::OnRender);
    CVoiceRender::AddDeviceFreeCallback(Plugin::OnDeviceFree);

    return true;
}

bool Plugin::OnSampLoad() noexcept
{
    if(!Samp::Init())
    {
        LogVoice("[sv:err:plugin] : failed to init samp");
        CVoiceRender::Free();
        return false;
    }

    Samp::AddLoadCallback(Plugin::OnInitGame);
    Samp::AddExitCallback(Plugin::OnExitGame);

    if(!Network::Init())
    {
        LogVoice("[sv:err:plugin] : failed to init network");
        CVoiceRender::Free();
        Samp::Free();
        return false;
    }

    Network::AddConnectCallback(Plugin::ConnectHandler);
    Network::AddSvConnectCallback(Plugin::PluginConnectHandler);
    Network::AddSvInitCallback(Plugin::PluginInitHandler);
    Network::AddDisconnectCallback(Plugin::DisconnectHandler);

    if(!Playback::Init())
    {
        LogVoice("[sv:err:plugin] : failed to init playback");
        CVoiceRender::Free();
        Samp::Free();
        Network::Free();
        return false;
    }

    return true;
}

void Plugin::OnInitGame() noexcept
{
    // ~ none
}

void Plugin::OnExitGame() noexcept
{
    Network::Free();

    Plugin::streamTable.clear();

    Record::Free();
    Playback::Free();
}

int MicType = 1;
static bool bcgPTT=false;
static int bcgPTTKey=66;
static int bcgActiveKey=66;
void Plugin::SetPTT(int key,bool down){if(key!=66)return;bcgPTTKey=66;bcgPTT=down;if(!down&&pUI&&pUI->voicebutton())pUI->voicebutton()->setRecording(false);}


void Plugin::MainLoop()
{
    if(!Samp::IsLoaded()) return;
    const bool launcherVoice=!pSettings||pSettings->GetReadOnly().bVoiceChatEnable;
    PluginConfig::SetMicroEnable(launcherVoice);
    PluginConfig::SetSoundEnable(launcherVoice);

    while(const auto controlPacket = Network::ReceiveControlPacket())
    {
        Plugin::ControlPacketHandler(*&*controlPacket);
    }

    while(const auto voicePacket = Network::ReceiveVoicePacket())
    {
        const auto& voicePacketRef = *voicePacket;

        const auto iter = Plugin::streamTable.find(voicePacketRef->stream);
        if(iter == Plugin::streamTable.end()) continue;

        iter->second->Push(*&voicePacketRef);
    }
    
    for(const auto& stream : Plugin::streamTable)
        stream.second->Tick();

    Playback::Tick();
    Record::Tick();

    if(recordBusy&&(muteStatus||!PluginConfig::GetMicroEnable())){recordBusy=false;recordStatus=false;Record::StopRecording();Network::EndSequence();bcgPTT=false;}
    const int key=bcgPTT?bcgPTTKey:66;
    bool requested=bcgPTT||(pUI&&pUI->voicebutton()&&pUI->voicebutton()->recording());
    requested=requested&&!muteStatus&&PluginConfig::GetMicroEnable()&&KeyFilter::IsKeyAvailable(key);
    if(!recordBusy&&recordStatus&&(!requested||key!=bcgActiveKey)){
        SV::ReleaseKeyPacket packet{static_cast<uint8_t>(bcgActiveKey)};
        Network::SendControlPacket(SV::ControlPacketType::releaseKey,&packet,sizeof packet);
        recordStatus=false;Record::StopRecording();Network::EndSequence();
    }
    if(!recordBusy&&requested&&!recordStatus&&Record::StartRecording()){
        bcgActiveKey=key;recordStatus=true;
        SV::PressKeyPacket packet{static_cast<uint8_t>(key)};
        if(!Network::SendControlPacket(SV::ControlPacketType::pressKey,&packet,sizeof packet)){recordStatus=false;Record::StopRecording();}
    }
    uint8_t frameBuffer[Network::kMaxVoiceDataSize];
    if(const auto frameSize = Record::GetFrame(frameBuffer, sizeof(frameBuffer)))
    {
        if(!Network::SendVoicePacket(frameBuffer, frameSize))
            LogVoice("[sv:err:plugin] : failed to send voice packet");

        if(!Plugin::recordStatus)
        {
            Record::StopRecording();
            Network::EndSequence();
        }
    }
}

void Plugin::ConnectHandler(const std::string& serverIp, const uint16_t serverPort)
{
    // ~ none
}

void Plugin::PluginConnectHandler(SV::ConnectPacket& connectStruct)
{
    connectStruct.signature = SV::kSignature;
    connectStruct.version = SV::kVersion;
    connectStruct.micro = Record::HasMicro();
}

bool Plugin::PluginInitHandler(const SV::PluginInitPacket& initPacket)
{
    Plugin::muteStatus = initPacket.mute;

    if(!Record::Init(initPacket.bitrate))
    {
        LogVoice("[sv:inf:plugin:packet:init] : failed init record");
    }

    return true;
}

void Plugin::ControlPacketHandler(const ControlPacket& controlPacket)
{
    switch(controlPacket.packet)
    {
        case SV::ControlPacketType::muteEnable:
        {
            if(controlPacket.length != 0) break;

            LogVoice("[sv:dbg:plugin:muteenable]");

            Plugin::muteStatus = true;
            Plugin::recordStatus = false;
            Plugin::recordBusy = false;
        } 
        break;
        case SV::ControlPacketType::muteDisable:
        {
            if(controlPacket.length != 0) break;

            LogVoice("[sv:dbg:plugin:mutedisable]");

            Plugin::muteStatus = false;
        } 
        break;
        case SV::ControlPacketType::startRecord:
        {
            if(controlPacket.length != 0) break;

            LogVoice("[sv:dbg:plugin:startrecord]");

            if(Plugin::muteStatus) break;

            Plugin::recordBusy = true;
            Plugin::recordStatus = true;

            Record::StartRecording();
        } 
        break;
        case SV::ControlPacketType::stopRecord:
        {
            if(controlPacket.length != 0) break;

            LogVoice("[sv:dbg:plugin:stoprecord]");

            if(Plugin::muteStatus) break;

            Plugin::recordStatus = false;
            Plugin::recordBusy = false;
        } 
        break;
        case SV::ControlPacketType::addKey:
        {
            const auto& stData = *reinterpret_cast<const SV::AddKeyPacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:addkey] : keyid(0x%hhx)", stData.keyId);
            
            KeyFilter::AddKey(stData.keyId);
        } 
        break;
        case SV::ControlPacketType::removeKey:
        {
            const auto& stData = *reinterpret_cast<const SV::RemoveKeyPacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:removekey] : keyid(0x%hhx)", stData.keyId);
            
            KeyFilter::RemoveKey(stData.keyId);
        } 
        break;
        case SV::ControlPacketType::removeAllKeys:
        {
            if(controlPacket.length) break;

            LogVoice("[sv:dbg:plugin:removeallkeys]");

            KeyFilter::RemoveAllKeys();
        } 
        break;
        case SV::ControlPacketType::createGStream:
        {
            const auto& stData = *reinterpret_cast<const SV::CreateGStreamPacket*>(controlPacket.data);
            if(controlPacket.length < sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:creategstream] : stream(%p), color(0x%x), name(%s)",
                stData.stream, stData.color, stData.color ? stData.name : "");

            const auto& streamPtr = Plugin::streamTable[stData.stream] =
                MakeGlobalStream(stData.color, stData.name);

            streamPtr->AddPlayCallback(SpeakerList::OnSpeakerPlay);
            streamPtr->AddStopCallback(SpeakerList::OnSpeakerStop);
        } 
        break;
        case SV::ControlPacketType::createLPStream:
        {
            const auto& stData = *reinterpret_cast<const SV::CreateLPStreamPacket*>(controlPacket.data);
            if(controlPacket.length < sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:createlpstream] : "
                "stream(%p), dist(%.2f), pos(%.2f;%.2f;%.2f), color(0x%x), name(%s)",
                stData.stream, stData.distance, stData.position.x, stData.position.y, stData.position.z,
                stData.color, stData.color ? stData.name : "");

            const auto& streamPtr = Plugin::streamTable[stData.stream] =
                MakeStreamAtPoint(stData.color, stData.name, stData.distance, stData.position);

            streamPtr->AddPlayCallback(SpeakerList::OnSpeakerPlay);
            streamPtr->AddStopCallback(SpeakerList::OnSpeakerStop);
        } 
        break;
        case SV::ControlPacketType::createLStreamAtVehicle:
        {
            const auto& stData = *reinterpret_cast<const SV::CreateLStreamAtPacket*>(controlPacket.data);
            if(controlPacket.length < sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:createlstreamatvehicle] : "
                "stream(%p), dist(%.2f), vehicle(%hu), color(0x%x), name(%s)",
                stData.stream, stData.distance, stData.target,
                stData.color, stData.color ? stData.name : "");

            const auto& streamPtr = Plugin::streamTable[stData.stream] =
                MakeStreamAtVehicle(stData.color, stData.name, stData.distance, stData.target);

            streamPtr->AddPlayCallback(SpeakerList::OnSpeakerPlay);
            streamPtr->AddStopCallback(SpeakerList::OnSpeakerStop);
        } 
        break;
        case SV::ControlPacketType::createLStreamAtPlayer:
        {
            const auto& stData = *reinterpret_cast<const SV::CreateLStreamAtPacket*>(controlPacket.data);
            if(controlPacket.length < sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:createlstreamatplayer] : "
                "stream(%p), dist(%.2f), player(%hu), color(0x%x), name(%s)",
                stData.stream, stData.distance, stData.target,
                stData.color, stData.color ? stData.name : "");

            const auto& streamPtr = Plugin::streamTable[stData.stream] =
                MakeStreamAtPlayer(stData.color, stData.name, stData.distance, stData.target);

            streamPtr->AddPlayCallback(SpeakerList::OnSpeakerPlay);
            streamPtr->AddStopCallback(SpeakerList::OnSpeakerStop);
        } 
        break;
        case SV::ControlPacketType::createLStreamAtObject:
        {
            const auto& stData = *reinterpret_cast<const SV::CreateLStreamAtPacket*>(controlPacket.data);
            if(controlPacket.length < sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:createlstreamatobject] : "
                "stream(%p), dist(%.2f), object(%hu), color(0x%x), name(%s)",
                stData.stream, stData.distance, stData.target,
                stData.color, stData.color ? stData.name : "");

            const auto& streamPtr = Plugin::streamTable[stData.stream] =
                MakeStreamAtObject(stData.color, stData.name, stData.distance, stData.target);

            streamPtr->AddPlayCallback(SpeakerList::OnSpeakerPlay);
            streamPtr->AddStopCallback(SpeakerList::OnSpeakerStop);
        } 
        break;
        case SV::ControlPacketType::updateLStreamDistance:
        {
            const auto& stData = *reinterpret_cast<const SV::UpdateLStreamDistancePacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:updatelpstreamdistance] : stream(%p), dist(%.2f)",
                stData.stream, stData.distance);

            const auto iter = Plugin::streamTable.find(stData.stream);
            if(iter == Plugin::streamTable.end()) break;

            static_cast<LocalStream*>(iter->second.get())->SetDistance(stData.distance);
        } 
        break;
        case SV::ControlPacketType::updateLPStreamPosition:
        {
            const auto& stData = *reinterpret_cast<const SV::UpdateLPStreamPositionPacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:updatelpstreamcoords] : stream(%p), pos(%.2f;%.2f;%.2f)",
                stData.stream, stData.position.x, stData.position.y, stData.position.z);

            const auto iter = Plugin::streamTable.find(stData.stream);
            if(iter == Plugin::streamTable.end()) break;

            static_cast<StreamAtPoint*>(iter->second.get())->SetPosition(stData.position);
        } 
        break;
        case SV::ControlPacketType::deleteStream:
        {
            const auto& stData = *reinterpret_cast<const SV::DeleteStreamPacket*>(controlPacket.data);
            if (controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:deletestream] : stream(%p)", stData.stream);

            Plugin::streamTable.erase(stData.stream);
        } 
        break;
        case SV::ControlPacketType::setStreamParameter:
        {
            const auto& stData = *reinterpret_cast<const SV::SetStreamParameterPacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:streamsetparameter] : stream(%p), parameter(%hhu), value(%.2f)",
                stData.stream, stData.parameter, stData.value);

            const auto iter = Plugin::streamTable.find(stData.stream);
            if(iter == Plugin::streamTable.end()) break;

            iter->second->SetParameter(stData.parameter, stData.value);
        } 
        break;
        case SV::ControlPacketType::slideStreamParameter:
        {
            const auto& stData = *reinterpret_cast<const SV::SlideStreamParameterPacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:streamslideparameter] : "
                "stream(%p), parameter(%hhu), startvalue(%.2f), endvalue(%.2f), time(%u)",
                stData.stream, stData.parameter, stData.startvalue, stData.endvalue, stData.time);

            const auto iter = Plugin::streamTable.find(stData.stream);
            if(iter == Plugin::streamTable.end()) break;

            iter->second->SlideParameter(stData.parameter, stData.startvalue, stData.endvalue, stData.time);
        } 
        break;
        case SV::ControlPacketType::createEffect:
        {
            const auto& stData = *reinterpret_cast<const SV::CreateEffectPacket*>(controlPacket.data);
            if(controlPacket.length < sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:effectcreate] : "
                "stream(%p), effect(%p), number(%hhu), priority(%d)",
                stData.stream, stData.effect, stData.number, stData.priority);

            const auto iter = Plugin::streamTable.find(stData.stream);
            if(iter == Plugin::streamTable.end()) break;

            iter->second->EffectCreate(stData.effect, stData.number, stData.priority,
                stData.params, controlPacket.length - sizeof(stData));
        } 
        break;
        case SV::ControlPacketType::deleteEffect:
        {
            const auto& stData = *reinterpret_cast<const SV::DeleteEffectPacket*>(controlPacket.data);
            if(controlPacket.length != sizeof(stData)) break;

            LogVoice("[sv:dbg:plugin:effectdelete] : stream(%p), effect(%p)",
                stData.stream, stData.effect);

            const auto iter = Plugin::streamTable.find(stData.stream);
            if(iter == Plugin::streamTable.end()) break;

            iter->second->EffectDelete(stData.effect);
        } 
        break;
    }
}

void Plugin::DisconnectHandler()
{
    Plugin::SetPTT(66,false);Record::StopRecording();
    Plugin::streamTable.clear();

    Plugin::muteStatus = false;
    Plugin::recordStatus = false;
    Plugin::recordBusy = false;

    Record::Free();
}

void Plugin::OnDeviceInit()
{
    SpeakerList::Init();
	MicroIcon::Init();
}

void Plugin::OnRender()
{
    // Audio and RakNet processing run in ProcessFrame on the game thread.

    SpeakerList::Render();
}

void Plugin::OnDeviceFree()
{
    SpeakerList::Free();
    MicroIcon::Free();
}

bool Plugin::muteStatus { false };
bool Plugin::recordStatus { false };
bool Plugin::recordBusy { false };

std::map<uint32_t, StreamPtr> Plugin::streamTable;

void Plugin::ProcessFrame(){Timer::Tick();MainLoop();
    // Update listener position for 3D audio and apply changes
    if (pGame && pGame->FindPlayerPed()) {
        CPlayerPed* player = pGame->FindPlayerPed();
        const BASS_3DVECTOR* pos = reinterpret_cast<const BASS_3DVECTOR*>(&player->m_pPed->GetPosition());
        // Leave velocity/front/top as previously set/default for simplicity
        BASS_Set3DPosition(pos, nullptr, nullptr, nullptr);
    }
    BASS_Apply3D();
}
