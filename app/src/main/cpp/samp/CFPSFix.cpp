#include "CFPSFix.h"
// Android's scheduler selects suitable cores. Avoid overwriting affinity every second.
void CFPSFix::Routine() {}
CFPSFix::CFPSFix() {}
CFPSFix::~CFPSFix() {}
void CFPSFix::PushThread(pid_t tid) { (void)tid; }
