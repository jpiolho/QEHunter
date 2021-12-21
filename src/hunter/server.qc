void() Hunter_HideHost_Think =
{
    msg_entity = self.owner;

    WriteByte(MSG_ONE,SVC_UPDATENAME);
    WriteByte(MSG_ONE,0);
    WriteString(MSG_ONE,"");
}

float() Hunter_GetServerOptions =
{
    return cvar("saved2");
}

float() Hunter_IsHostMode =
{
    return Hunter_GetServerOptions() & SERVERSETTINGS_HOSTMODE;
}