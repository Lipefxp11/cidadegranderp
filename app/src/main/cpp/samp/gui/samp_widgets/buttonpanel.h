#pragma once

class ButtonPanel : public Layout
{
public:
    ButtonPanel();

    void performLayout() override;

    Button* m_bH;
    OButton* m_bOpen;
    Button* m_bTab;
    Button* m_bAlt;
    Widget* m_bSV;

private:
    Button* m_bEsc;
    Button* m_bY;
    Button* m_bN;
};
