#pragma once
#include <string>
namespace BCGBridge {
bool Ready();
bool ModalOpen();
bool GameMenuOpen();
void GameMenu(bool open);
void ConfirmServerUI();
bool ControlDown(int key);
bool OpenChat();
bool ChatOpen();
void CloseChat();
void ResetSession();
void Marker(unsigned id,float x,float y,unsigned color,unsigned type);
void RemoveMarker(unsigned id);
void Queue(int op,int a,int b,int c,const std::string& text);
void Process();
void Emit(const std::string& json);
std::string Quote(const std::string& value);
void Dialog(int id);
}
