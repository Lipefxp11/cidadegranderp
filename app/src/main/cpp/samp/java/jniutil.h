#pragma once

#include "main.h"

#define EXCEPTION_CHECK(env) \
	if ((env)->ExceptionCheck()) \ 
	{ \
		(env)->ExceptionDescribe(); \
		(env)->ExceptionClear(); \
		return; \
	}

class CJavaWrapper
{
public:
    CJavaWrapper(JNIEnv *env, jobject activity);
    ~CJavaWrapper() {};
    JNIEnv* GetEnv();
    
    const char* GetClipboardString();
    void SetPauseState(bool pause);
    void ShowLoadingScreen();
    void HideLoadingScreen();
    void ConnectionStatus(int phase, const char* message);
    void ConnectionNotice(const char* message);
    void UiEvent(const char* json);
    jmethodID s_uiEvent=nullptr;

	void exitGame();

    jbyteArray as_byte_array(unsigned char* buf, int len) {
        JNIEnv* p = GetEnv();
        if (!p) return nullptr;
		jbyteArray array = p->NewByteArray (len);
		if (!array) return nullptr;
		p->SetByteArrayRegion (array, 0, len, reinterpret_cast<jbyte*>(buf));
		return array;
	}

    void ShowDialog(int dialogStyle, int dialogID, char* title, char* text, char* button1, char* button2);

	void ShowEditObject();
	void HideEditObject();

    jobject activity;
    jmethodID s_setPauseState;
    jmethodID s_showLoadingScreen;
    jmethodID s_hideLoadingScreen;
    jmethodID s_connectionStatus;
    jmethodID s_connectionNotice;
    jmethodID s_ShowDialog;
    jmethodID s_showInputLayout;
    jmethodID s_hideInputLayout;
	jmethodID s_exitGame;
	jmethodID s_showEditObject;
	jmethodID s_hideEditObject;
};

extern CJavaWrapper* pJavaWrapper;
