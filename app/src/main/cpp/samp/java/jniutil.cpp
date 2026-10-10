#include "jniutil.h"
#include "BCGBridge.h"
#include "game/game.h"
extern CGame *pGame;

JNIEnv* CJavaWrapper::GetEnv()
{
    JNIEnv* env = nullptr;
    int getEnvStat = javaVM->GetEnv((void**)& env, JNI_VERSION_1_4);

    if (getEnvStat == JNI_EDETACHED)
    {
        Log("GetEnv: not attached");
        if (javaVM->AttachCurrentThread(&env, NULL) != 0)
        {
            Log("Failed to attach");
            return nullptr;
        }
    }
    if (getEnvStat == JNI_EVERSION)
    {
        Log("GetEnv: version not supported");
        return nullptr;
    }

    if (getEnvStat == JNI_ERR)
    {
        Log("GetEnv: JNI_ERR");
        return nullptr;
    }

    return env;
}

CJavaWrapper::CJavaWrapper(JNIEnv *env, jobject activity)
{
    this->activity = env->NewGlobalRef(activity);

    jclass clas = env->GetObjectClass(activity);
    if(!clas)
    {
        Log("no clas");
        return;
    }

    s_uiEvent = env->GetMethodID(clas, "onUiEvent", "([B)V");
    s_showLoadingScreen = env->GetMethodID(clas, "showLoadingScreen", "()V");
    s_hideLoadingScreen = env->GetMethodID(clas, "hideLoadingScreen", "()V");
    s_connectionStatus = env->GetMethodID(clas, "onConnectionStatus", "(ILjava/lang/String;)V");
    s_connectionNotice = env->GetMethodID(clas, "onConnectionNotice", "(Ljava/lang/String;)V");

    s_setPauseState = env->GetMethodID(clas, "setPauseState", "(Z)V");
    
    s_ShowDialog = env->GetMethodID(clas, "showDialog", "(II[B[B[B[B)V");

    s_exitGame = env->GetMethodID(clas, "exitGame", "()V");

    s_showEditObject = env->GetMethodID(clas, "showEditObject", "()V");
    s_hideEditObject = env->GetMethodID(clas, "hideEditObject", "()V");

    env->DeleteLocalRef(clas);
}

void CJavaWrapper::ShowLoadingScreen()
{
    JNIEnv* p=GetEnv();
    if(!p || !activity)return;
    p->CallVoidMethod(activity, s_showLoadingScreen);
    EXCEPTION_CHECK(p);
}

void CJavaWrapper::HideLoadingScreen()
{
    JNIEnv* p=GetEnv();
    if(!p || !activity)return;
    p->CallVoidMethod(activity, s_hideLoadingScreen);
    EXCEPTION_CHECK(p);
}

void CJavaWrapper::ConnectionStatus(int phase, const char* message)
{
    JNIEnv* env=GetEnv();
    if(!env || !activity || !s_connectionStatus)return;
    jstring text=env->NewStringUTF(message ? message : "");
    if(!text)return;
    env->CallVoidMethod(activity,s_connectionStatus,phase,text);
    env->DeleteLocalRef(text);
    EXCEPTION_CHECK(env);
}
void CJavaWrapper::ConnectionNotice(const char* message)
{
    JNIEnv* env=GetEnv();
    if(!env || !activity || !s_connectionNotice)return;
    jstring text=env->NewStringUTF(message ? message : "");
    if(!text)return;
    env->CallVoidMethod(activity,s_connectionNotice,text);
    env->DeleteLocalRef(text);
    EXCEPTION_CHECK(env);
}
void CJavaWrapper::SetPauseState(bool pause)
{
    JNIEnv* p;
    javaVM->GetEnv((void**)&p, JNI_VERSION_1_6);
    p->CallVoidMethod(activity, s_setPauseState, pause);
    EXCEPTION_CHECK(p);
}

void CJavaWrapper::ShowDialog(int dialogStyle, int dialogID, char* title, char* text, char* button1, char* button2)
{
    BCGBridge::Dialog(dialogID);
    JNIEnv* env = GetEnv();

    if (!env)
    {
        Log("No env");
        return;
    }

    std::string sTitle(title);
    std::string sText(text);
    std::string sButton1(button1);
    std::string sButton2(button2);

    jbyteArray jstrTitle = as_byte_array((unsigned char*)sTitle.c_str(), sTitle.length());
    jbyteArray jstrText = as_byte_array((unsigned char*)sText.c_str(), sText.length());
    jbyteArray jstrButton1 = as_byte_array((unsigned char*)sButton1.c_str(), sButton1.length());
    jbyteArray jstrButton2 = as_byte_array((unsigned char*)sButton2.c_str(), sButton2.length());

    env->CallVoidMethod(activity, s_ShowDialog, dialogID, dialogStyle, jstrTitle, jstrText, jstrButton1, jstrButton2);

    env->DeleteLocalRef(jstrTitle);
    env->DeleteLocalRef(jstrText);
    env->DeleteLocalRef(jstrButton1);
    env->DeleteLocalRef(jstrButton2);

    EXCEPTION_CHECK(env);
}

void CJavaWrapper::exitGame() {

    JNIEnv* env;
    javaVM->GetEnv((void**)&env, JNI_VERSION_1_6);

    if (!env)
    {
        Log("No env");
        return;
    }

    env->CallVoidMethod(this->activity, this->s_exitGame);
}

void CJavaWrapper::ShowEditObject() {

    JNIEnv* env;
    javaVM->GetEnv((void**)&env, JNI_VERSION_1_6);

    if (!env)
    {
        Log("No env");
        return;
    }

    env->CallVoidMethod(this->activity, this->s_showEditObject);
}

void CJavaWrapper::HideEditObject() {

    JNIEnv* env;
    javaVM->GetEnv((void**)&env, JNI_VERSION_1_6);

    if (!env)
    {
        Log("No env");
        return;
    }

    env->CallVoidMethod(this->activity, this->s_hideEditObject);
}

void CJavaWrapper::UiEvent(const char* json){JNIEnv* env=GetEnv();if(!env||!activity||!s_uiEvent)return;jbyteArray bytes=as_byte_array((unsigned char*)json,strlen(json));if(!bytes)return;env->CallVoidMethod(activity,s_uiEvent,bytes);env->DeleteLocalRef(bytes);EXCEPTION_CHECK(env);}
