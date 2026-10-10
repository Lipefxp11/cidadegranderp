#pragma once

// Capture the entire native chat gesture. Never synthesize an UP at (0,0).
class BCGTouchCapture {
    bool captured[16]{};
public:
    bool Consume(int type, int finger, bool chatHit) {
        if (finger < 0 || finger >= 16) return chatHit;
        if (type == 2) captured[finger] = chatHit;
        const bool owned = captured[finger];
        if (type == 1) captured[finger] = false;
        return owned;
    }
    void Reset() { for (bool& value : captured) value = false; }
};
