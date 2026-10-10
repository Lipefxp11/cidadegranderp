#if defined _bcg_phone38_included
    #endinput
#endif
#define _bcg_phone38_included
new DB:BCG38DB;
new BCG38Nonce[MAX_PLAYERS], BCG38Seq[MAX_PLAYERS], BCG38StageN[MAX_PLAYERS], BCG38StageCount[MAX_PLAYERS];
new BCG38Tick[MAX_PLAYERS];
new BCG38Until[MAX_PLAYERS], BCG38Target[MAX_PLAYERS], BCG38Instance;
new bool:BCG38Unlocked[MAX_PLAYERS];
new bool:BCG38MoneyReady = true;
new bool:BCG38PhotosDirty[MAX_PLAYERS];
new BCG38FeedVersion=1,BCG38LastFeed[MAX_PLAYERS];
new BCG38Stage[MAX_PLAYERS][8193], BCG38Kind[MAX_PLAYERS][16];
stock BCG38Exec(const bcg38Query[])
{
    if(!BCG38DB) return 0;
    static bcg38MutableQuery[17000];
    new bcg38QueryLength = strlen(bcg38Query);
    if(bcg38QueryLength >= sizeof bcg38MutableQuery) return 0;
    for(new bcg38Copy; bcg38Copy <= bcg38QueryLength; bcg38Copy++)
        bcg38MutableQuery[bcg38Copy] = bcg38Query[bcg38Copy];
    new DBResult:bcg38Result = db_query(BCG38DB, bcg38MutableQuery);
    if(!bcg38Result) return 0;
    db_free_result(bcg38Result);
    return 1;
}
stock BCG38Init()
{
    BCG38DB = db_open("bcg_phone38.db");
    if(!BCG38DB) { print("[BCG PHONE] Falha ao abrir banco SQLite."); return 0; }
    if(!BCG38Exec("PRAGMA synchronous=FULL")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS users(number INTEGER PRIMARY KEY AUTOINCREMENT,owner TEXT UNIQUE NOT NULL,pin TEXT DEFAULT '',salt TEXT DEFAULT '',fail INTEGER DEFAULT 0,blocked INTEGER DEFAULT 0)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS private_data(owner TEXT PRIMARY KEY,data TEXT NOT NULL)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY,sender INTEGER,recipient INTEGER,body TEXT,stamp INTEGER)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS posts(id INTEGER PRIMARY KEY,owner TEXT,data TEXT,stamp INTEGER)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS likes(owner TEXT,post INTEGER,PRIMARY KEY(owner,post))")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS photos(owner TEXT,slot INTEGER,data TEXT,PRIMARY KEY(owner,slot))")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS comments(id INTEGER PRIMARY KEY,owner TEXT,post INTEGER,body TEXT,stamp INTEGER)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS following(owner TEXT,target TEXT,PRIMARY KEY(owner,target))")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS ledger(id INTEGER PRIMARY KEY,owner TEXT,peer TEXT,amount INTEGER,stamp INTEGER)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS meta(instance INTEGER)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    if(!BCG38Exec("CREATE TABLE IF NOT EXISTS money_journal(id INTEGER PRIMARY KEY,sender TEXT,recipient TEXT,sender_after INTEGER,recipient_after INTEGER,done INTEGER DEFAULT 0)")) { db_close(BCG38DB);BCG38DB=DB:0;print("[BCG PHONE] Falha ao preparar SQLite.");return 0; }
    new DBResult:bcg38Result = db_query(BCG38DB, "SELECT instance FROM meta LIMIT 1");
    if(db_num_rows(bcg38Result)) BCG38Instance = db_get_field_int(bcg38Result, 0);
    db_free_result(bcg38Result);
    if(!BCG38Instance) { new bcg38Query[80]; BCG38Instance = random(2000000000)+1; format(bcg38Query,sizeof bcg38Query,"INSERT INTO meta VALUES(%d)",BCG38Instance); BCG38Exec(bcg38Query); }
    BCG38MoneyReady = BCG38RecoverMoney() != 0;
    return 1;
}
stock BCG38WriteBalance(const bcg38Name[],bcg38Balance)
{
    new bcg38Path[80];format(bcg38Path,sizeof bcg38Path,"Contas/%s.txt",bcg38Name);
    if(!DOF2_FileExists(bcg38Path)) return 0;
    DOF2_SetInt(bcg38Path,"Banco",bcg38Balance);
    return DOF2_WriteFile();
}
stock BCG38RecoverMoney()
{
    new DBResult:bcg38Result=db_query(BCG38DB,"SELECT id,sender,recipient,sender_after,recipient_after FROM money_journal WHERE done=0 ORDER BY id");
    if(!bcg38Result) return 0;
    new bcg38OK=1;
    for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++)
    {
        new bcg38Sender[MAX_PLAYER_NAME],bcg38Recipient[MAX_PLAYER_NAME],bcg38Query[100];
        db_get_field(bcg38Result,1,bcg38Sender,sizeof bcg38Sender);db_get_field(bcg38Result,2,bcg38Recipient,sizeof bcg38Recipient);
        if(!BCG38WriteBalance(bcg38Sender,db_get_field_int(bcg38Result,3)) || !BCG38WriteBalance(bcg38Recipient,db_get_field_int(bcg38Result,4))) { bcg38OK=0;break; }
        format(bcg38Query,sizeof bcg38Query,"UPDATE money_journal SET done=1 WHERE id=%d",db_get_field_int(bcg38Result,0));
        if(!BCG38Exec(bcg38Query))
        {
            bcg38OK=0;
            break;
        }
        db_next_row(bcg38Result);
    }
    db_free_result(bcg38Result);
    if(!bcg38OK) print("[BCG PHONE] Recuperacao bancaria pendente. Transferencias bloqueadas.");
    return bcg38OK;
}
stock BCG38Reset(playerid)
{
    BCG38Nonce[playerid] = BCG38Seq[playerid] = BCG38StageN[playerid] = BCG38StageCount[playerid] = BCG38Until[playerid] = 0;
    BCG38Unlocked[playerid] = false;BCG38Tick[playerid]=0;BCG38PhotosDirty[playerid]=true;BCG38LastFeed[playerid]=0;
    BCG38Stage[playerid][0] = BCG38Kind[playerid][0] = EOS;
    return 1;
}
stock BCG38Escape(const bcg38Input[], bcg38Output[], bcg38Size)
{
    new bcg38Write;
    for(new bcg38Read; bcg38Input[bcg38Read] != EOS; bcg38Read++)
    {
        if(bcg38Write + 2 >= bcg38Size) return 0;
        if(bcg38Input[bcg38Read] == '\'') bcg38Output[bcg38Write++] = '\'';
        bcg38Output[bcg38Write++] = bcg38Input[bcg38Read];
    }
    bcg38Output[bcg38Write] = EOS;
    return 1;
}
stock BCG38Owner(playerid, bcg38Output[], bcg38Size)
{
    new bcg38Name[MAX_PLAYER_NAME]; GetPlayerName(playerid,bcg38Name,sizeof bcg38Name);
    return BCG38Escape(bcg38Name,bcg38Output,bcg38Size);
}
stock BCG38Digit(bcg38Char)
{
    if(bcg38Char >= '0' && bcg38Char <= '9') return bcg38Char-'0';
    if(bcg38Char >= 'a' && bcg38Char <= 'f') return bcg38Char-'a'+10;
    return -1;
}
stock BCG38Decode(const bcg38Hex[], bcg38Output[], bcg38Size)
{
    new bcg38Length = strlen(bcg38Hex);
    if(bcg38Length % 2 || bcg38Length / 2 >= bcg38Size) return 0;
    for(new bcg38Read; bcg38Read < bcg38Length; bcg38Read += 2)
    {
        new bcg38High=BCG38Digit(bcg38Hex[bcg38Read]), bcg38Low=BCG38Digit(bcg38Hex[bcg38Read+1]);
        if(bcg38High < 0 || bcg38Low < 0 || !(bcg38High*16+bcg38Low)) return 0;
        bcg38Output[bcg38Read/2]=bcg38High*16+bcg38Low;
    }
    bcg38Output[bcg38Length/2]=EOS;
    return 1;
}
stock BCG38Record(playerid,const bcg38Kind[],bcg38Row,const bcg38Data[])
{
    new bcg38Hex[81],bcg38Packet[144],bcg38Read,bcg38Part,bcg38Length=strlen(bcg38Data);
    static const bcg38Digits[]="0123456789abcdef";
    while(bcg38Read < bcg38Length)
    {
        new bcg38Write;
        for(new bcg38Count;bcg38Count<40 && bcg38Read<bcg38Length;bcg38Count++,bcg38Read++)
        {
            new bcg38Byte=bcg38Data[bcg38Read]&255;
            bcg38Hex[bcg38Write++]=bcg38Digits[bcg38Byte/16];bcg38Hex[bcg38Write++]=bcg38Digits[bcg38Byte%16];
        }
        bcg38Hex[bcg38Write]=EOS;
        format(bcg38Packet,sizeof bcg38Packet,"[BCG:UI]P38|data|%d|%s|%d|%d|%s",BCG38Nonce[playerid],bcg38Kind,bcg38Row,bcg38Part++,bcg38Hex);
        SendClientMessage(playerid,-1,bcg38Packet);
    }
    format(bcg38Packet,sizeof bcg38Packet,"[BCG:UI]P38|end|%d|%s|%d|%d",BCG38Nonce[playerid],bcg38Kind,bcg38Row,bcg38Part);
    SendClientMessage(playerid,-1,bcg38Packet);
    return 1;
}
stock BCG38Error(playerid,const bcg38Text[]) { return BCG38Record(playerid,"error",0,bcg38Text); }
stock BCG38Number(playerid)
{
    new bcg38Owner[50],bcg38Query[130]; BCG38Owner(playerid,bcg38Owner,sizeof bcg38Owner);
    format(bcg38Query,sizeof bcg38Query,"SELECT number FROM users WHERE owner='%s'",bcg38Owner);
    new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query),bcg38Number;
    if(db_num_rows(bcg38Result)) bcg38Number=db_get_field_int(bcg38Result,0);
    db_free_result(bcg38Result); return bcg38Number;
}
stock BCG38EnsureNumber(playerid)
{
    if(!BCG38DB) return 0;
    new owner[50], query[160];BCG38Owner(playerid, owner, sizeof(owner));
    format(query, sizeof(query), "INSERT OR IGNORE INTO users(owner) VALUES('%s')", owner);
    if(!BCG38Exec(query)) return 0;
    return BCG38Number(playerid);
}
stock BCG38TargetPlayer(bcg38Number)
{
    if(bcg38Number <= 0) return INVALID_PLAYER_ID;
    new bcg38Query[120],bcg38Name[MAX_PLAYER_NAME]; format(bcg38Query,sizeof bcg38Query,"SELECT owner FROM users WHERE number=%d",bcg38Number);
    new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query);
    if(db_num_rows(bcg38Result)) db_get_field(bcg38Result,0,bcg38Name,sizeof bcg38Name);
    db_free_result(bcg38Result);
    if(!bcg38Name[0]) return INVALID_PLAYER_ID;
    for(new bcg38Player;bcg38Player<MAX_PLAYERS;bcg38Player++)
        if(IsPlayerConnected(bcg38Player) && Pdados[bcg38Player][pLogged] && !strcmp(Nome(bcg38Player),bcg38Name,false)) return bcg38Player;
    return INVALID_PLAYER_ID;
}
stock BCG38Snapshot(playerid)
{
    if(!BCG38Unlocked[playerid]) return 0;
    new bcg38Owner[50],bcg38Query[550],bcg38Value[128],bcg38Number=BCG38Number(playerid);
    static bcg38Large[8193];
    BCG38Owner(playerid,bcg38Owner,sizeof bcg38Owner);
    BCG38Record(playerid,"refresh",0,"");
    format(bcg38Value,sizeof bcg38Value,"%s|%d|%d|%d",Nome(playerid),bcg38Number,Pdados[playerid][Banco],GetPlayerMoney(playerid));
    BCG38Record(playerid,"account",0,bcg38Value);
    format(bcg38Query,sizeof bcg38Query,"SELECT data FROM private_data WHERE owner='%s'",bcg38Owner);
    new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query);
    if(db_num_rows(bcg38Result)) { db_get_field(bcg38Result,0,bcg38Large,sizeof bcg38Large); BCG38Record(playerid,"private",0,bcg38Large); }
    db_free_result(bcg38Result);
    if(BCG38PhotosDirty[playerid])
    {
        BCG38Record(playerid,"clearphotos",0,"");
        format(bcg38Query,sizeof bcg38Query,"SELECT slot,data FROM photos WHERE owner='%s' ORDER BY slot LIMIT 25",bcg38Owner);
        bcg38Result=db_query(BCG38DB,bcg38Query);
        for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++) { db_get_field(bcg38Result,1,bcg38Large,sizeof bcg38Large);BCG38Record(playerid,"photo",db_get_field_int(bcg38Result,0),bcg38Large);db_next_row(bcg38Result); }
        db_free_result(bcg38Result);
        BCG38PhotosDirty[playerid]=false;
    }
    format(bcg38Query,sizeof bcg38Query,"SELECT sender,recipient,body,stamp FROM messages WHERE sender=%d OR recipient=%d ORDER BY id DESC LIMIT 50",bcg38Number,bcg38Number);
    bcg38Result=db_query(BCG38DB,bcg38Query);
    for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++)
    {
        new bcg38Sender=db_get_field_int(bcg38Result,0),bcg38Recipient=db_get_field_int(bcg38Result,1),bcg38Body[1025];
        db_get_field(bcg38Result,2,bcg38Body,sizeof bcg38Body);
        format(bcg38Large,sizeof bcg38Large,"%d|%d|%d|%s",bcg38Sender==bcg38Number?bcg38Recipient:bcg38Sender,bcg38Sender==bcg38Number,db_get_field_int(bcg38Result,3),bcg38Body);
        BCG38Record(playerid,"message",bcg38Row,bcg38Large);db_next_row(bcg38Result);
    }
    db_free_result(bcg38Result);
    if(BCG38LastFeed[playerid]!=BCG38FeedVersion)
    {
        BCG38Record(playerid,"clearposts",0,"");
        bcg38Result=db_query(BCG38DB,"SELECT id,owner,data FROM posts ORDER BY id DESC LIMIT 20");
        for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++)
        {
            new bcg38ID=db_get_field_int(bcg38Result,0);db_get_field(bcg38Result,1,bcg38Value,sizeof bcg38Value);BCG38Record(playerid,"author",bcg38ID,bcg38Value);
            db_get_field(bcg38Result,2,bcg38Large,sizeof bcg38Large);BCG38Record(playerid,"post",bcg38ID,bcg38Large);db_next_row(bcg38Result);
        }
        db_free_result(bcg38Result);
        BCG38LastFeed[playerid]=BCG38FeedVersion;
    }
    format(bcg38Query,sizeof bcg38Query,"SELECT post,COUNT(*),MAX(owner='%s') FROM likes GROUP BY post LIMIT 100",bcg38Owner);
    bcg38Result=db_query(BCG38DB,bcg38Query);
    for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++){ format(bcg38Value,sizeof bcg38Value,"%d|%d",db_get_field_int(bcg38Result,1),db_get_field_int(bcg38Result,2));BCG38Record(playerid,"likes",db_get_field_int(bcg38Result,0),bcg38Value);db_next_row(bcg38Result); }
    db_free_result(bcg38Result);
    bcg38Result=db_query(BCG38DB,"SELECT post,owner,body FROM comments ORDER BY id DESC LIMIT 50");
    for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++){ new bcg38Body[1025];db_get_field(bcg38Result,1,bcg38Value,sizeof bcg38Value);db_get_field(bcg38Result,2,bcg38Body,sizeof bcg38Body);format(bcg38Large,sizeof bcg38Large,"%s|%s",bcg38Value,bcg38Body);BCG38Record(playerid,"comment",db_get_field_int(bcg38Result,0),bcg38Large);db_next_row(bcg38Result); }
    db_free_result(bcg38Result);
    format(bcg38Query,sizeof bcg38Query,"SELECT target FROM following WHERE owner='%s' LIMIT 50",bcg38Owner);bcg38Result=db_query(BCG38DB,bcg38Query);
    for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++){ db_get_field(bcg38Result,0,bcg38Value,sizeof bcg38Value);BCG38Record(playerid,"following",bcg38Row,bcg38Value);db_next_row(bcg38Result); }
    db_free_result(bcg38Result);
    format(bcg38Query,sizeof bcg38Query,"SELECT peer,amount,stamp FROM ledger WHERE owner='%s' ORDER BY id DESC LIMIT 30",bcg38Owner);
    bcg38Result=db_query(BCG38DB,bcg38Query);
    for(new bcg38Row;bcg38Row<db_num_rows(bcg38Result);bcg38Row++)
    {
        db_get_field(bcg38Result,0,bcg38Value,sizeof bcg38Value);format(bcg38Large,sizeof bcg38Large,"%s|%d|%d",bcg38Value,db_get_field_int(bcg38Result,1),db_get_field_int(bcg38Result,2));
        BCG38Record(playerid,"ledger",bcg38Row,bcg38Large);db_next_row(bcg38Result);
    }
    db_free_result(bcg38Result);BCG38Record(playerid,"ready",0,"");return 1;
}
stock BCG38Open(playerid)
{
    if(!BCG38DB) return SendClientMessage(playerid,-1,"[CELULAR] Banco indisponivel. Confira o log [BCG PHONE], scriptfiles e permissoes.");
    if(!BCG36Client[playerid]) return SendClientMessage(playerid,-1,"[CELULAR] Interface nao reconhecida. Reconecte com o APK V043 para iniciar a interface.");
    if(!Pdados[playerid][pLogged] || GetPVarInt(playerid,"BCG_NOVA_CONTA")) return 0;
    if(Pdados[playerid][Celular]!=1) return SendClientMessage(playerid,-1,"[CELULAR] Compre seu aparelho no shopping.");
    new bcg38Owner[50],bcg38Query[200],bcg38Pin[65],bcg38Packet[144];BCG38Owner(playerid,bcg38Owner,sizeof bcg38Owner);
    format(bcg38Query,sizeof bcg38Query,"INSERT OR IGNORE INTO users(owner) VALUES('%s')",bcg38Owner);BCG38Exec(bcg38Query);
    format(bcg38Query,sizeof bcg38Query,"SELECT pin FROM users WHERE owner='%s'",bcg38Owner);
    new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query);db_get_field(bcg38Result,0,bcg38Pin,sizeof bcg38Pin);db_free_result(bcg38Result);
    BCG38Reset(playerid);BCG38Nonce[playerid]=random(2000000000)+1;BCG38Unlocked[playerid]=!bcg38Pin[0];
    format(bcg38Packet,sizeof bcg38Packet,"[BCG:UI]P38|hello|%d|%s|%d|%d|%d",BCG38Nonce[playerid],Nome(playerid),BCG38Number(playerid),bcg38Pin[0]!=EOS,BCG38Instance);
    SendClientMessage(playerid,-1,bcg38Packet);if(BCG38Unlocked[playerid]) BCG38Snapshot(playerid);return 1;
}
stock BCG38Request(playerid,const bcg38Payload[])
{
    if(!BCG38DB || !BCG38Nonce[playerid] || !BCG36Client[playerid] || !Pdados[playerid][pLogged] || Pdados[playerid][Celular]!=1 || GetPVarInt(playerid,"BCG_NOVA_CONTA")) return 1;
    new bcg38Nonce,bcg38Seq,bcg38Verb[16],bcg38HexA[85],bcg38HexB[85],bcg38ArgA[43],bcg38ArgB[43];
    new bcg38MutablePayload[145], bcg38PayloadLength = strlen(bcg38Payload);
    if(bcg38PayloadLength >= sizeof bcg38MutablePayload) return 1;
    for(new bcg38Copy; bcg38Copy <= bcg38PayloadLength; bcg38Copy++)
        bcg38MutablePayload[bcg38Copy] = bcg38Payload[bcg38Copy];
    if(sscanf(bcg38MutablePayload,"p<|>iis[16]s[85]s[85]",bcg38Nonce,bcg38Seq,bcg38Verb,bcg38HexA,bcg38HexB)) return 1;
    if(bcg38Nonce!=BCG38Nonce[playerid] || bcg38Seq<=BCG38Seq[playerid] || bcg38Seq<=0) return 1;
    if(!BCG38Decode(bcg38HexA,bcg38ArgA,sizeof bcg38ArgA) || !BCG38Decode(bcg38HexB,bcg38ArgB,sizeof bcg38ArgB)) return 1;
    BCG38Seq[playerid]=bcg38Seq;
    if(!strcmp(bcg38Verb,"close")) return BCG38Reset(playerid);
    if(strcmp(bcg38Verb,"chunk") && strcmp(bcg38Verb,"commit")) {
        new bcg38Now=GetTickCount();if(BCG38Tick[playerid] && bcg38Now-BCG38Tick[playerid]<120) return 1;BCG38Tick[playerid]=bcg38Now;
    }
    new bcg38Owner[50];BCG38Owner(playerid,bcg38Owner,sizeof bcg38Owner);
    static bcg38Query[17000],bcg38Escaped[16388];
    if(!strcmp(bcg38Verb,"unlock") || !strcmp(bcg38Verb,"setpin"))
    {
        if(strlen(bcg38ArgA)!=6) return BCG38Error(playerid,"Use seis digitos.");
        for(new bcg38Char;bcg38Char<6;bcg38Char++) if(bcg38ArgA[bcg38Char]<'0'||bcg38ArgA[bcg38Char]>'9') return 1;
        format(bcg38Query,sizeof bcg38Query,"SELECT pin,salt,fail,blocked FROM users WHERE owner='%s'",bcg38Owner);
        new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query),bcg38Stored[65],bcg38Salt[40],bcg38Hash[65],bcg38Fail=db_get_field_int(bcg38Result,2),bcg38Blocked=db_get_field_int(bcg38Result,3);
        db_get_field(bcg38Result,0,bcg38Stored,sizeof bcg38Stored);db_get_field(bcg38Result,1,bcg38Salt,sizeof bcg38Salt);db_free_result(bcg38Result);
        if(!strcmp(bcg38Verb,"setpin"))
        {
            if(!BCG38Unlocked[playerid]) return 1;
            format(bcg38Salt,sizeof bcg38Salt,"%d-%d-%d",random(2000000000),gettime(),BCG38Instance);SHA256_PassHash(bcg38ArgA,bcg38Salt,bcg38Hash,sizeof bcg38Hash);
            format(bcg38Query,sizeof bcg38Query,"UPDATE users SET pin='%s',salt='%s',fail=0,blocked=0 WHERE owner='%s'",bcg38Hash,bcg38Salt,bcg38Owner);BCG38Exec(bcg38Query);return BCG38Record(playerid,"pin",0,"1");
        }
        if(bcg38Blocked>gettime()) return BCG38Error(playerid,"Aguarde um minuto antes de tentar novamente.");
        SHA256_PassHash(bcg38ArgA,bcg38Salt,bcg38Hash,sizeof bcg38Hash);
        if(bcg38Stored[0] && strcmp(bcg38Stored,bcg38Hash))
        {
            bcg38Fail++;format(bcg38Query,sizeof bcg38Query,"UPDATE users SET fail=%d,blocked=%d WHERE owner='%s'",bcg38Fail%5,bcg38Fail>=5?gettime()+60:0,bcg38Owner);BCG38Exec(bcg38Query);return BCG38Error(playerid,"Codigo incorreto.");
        }
        format(bcg38Query,sizeof bcg38Query,"UPDATE users SET fail=0,blocked=0 WHERE owner='%s'",bcg38Owner);BCG38Exec(bcg38Query);BCG38Unlocked[playerid]=true;BCG38PhotosDirty[playerid]=true;BCG38LastFeed[playerid]=0;return BCG38Snapshot(playerid);
    }
    if(!BCG38Unlocked[playerid]) return 1;
    if(!strcmp(bcg38Verb,"lock")) { BCG38Unlocked[playerid]=false;BCG38StageN[playerid]=BCG38StageCount[playerid]=0;return BCG38Record(playerid,"locked",0,""); }
    if(!strcmp(bcg38Verb,"sync")) return BCG38Snapshot(playerid);
    if(!strcmp(bcg38Verb,"begin"))
    {
        if(strcmp(bcg38ArgA,"private") && strcmp(bcg38ArgA,"message") && strcmp(bcg38ArgA,"post") && strcmp(bcg38ArgA,"photo") && strcmp(bcg38ArgA,"comment")) return 1;
        new bcg38Target,bcg38Count;if(sscanf(bcg38ArgB,"p<:>ii",bcg38Target,bcg38Count)||bcg38Count<1||bcg38Count>256) return 1;
        format(BCG38Kind[playerid],16,"%s",bcg38ArgA);BCG38Target[playerid]=bcg38Target;BCG38StageCount[playerid]=bcg38Count;BCG38StageN[playerid]=0;BCG38Stage[playerid][0]=EOS;BCG38Until[playerid]=gettime()+75;return 1;
    }
    if(!strcmp(bcg38Verb,"chunk"))
    {
        if(!BCG38StageCount[playerid] || gettime()>BCG38Until[playerid] || strval(bcg38ArgA)!=BCG38StageN[playerid] || BCG38StageN[playerid]>=BCG38StageCount[playerid]) return 1;
        if(strlen(BCG38Stage[playerid])+strlen(bcg38ArgB)>8192) return 1;
        strcat(BCG38Stage[playerid],bcg38ArgB,8193);BCG38StageN[playerid]++;return 1;
    }
    if(!strcmp(bcg38Verb,"commit"))
    {
        if(!BCG38StageCount[playerid] || BCG38StageN[playerid]!=BCG38StageCount[playerid] || gettime()>BCG38Until[playerid]) return BCG38Error(playerid,"Pedido incompleto. Tente novamente.");
        if(!BCG38Escape(BCG38Stage[playerid],bcg38Escaped,sizeof bcg38Escaped)) return 1;
        if(!strcmp(BCG38Kind[playerid],"private")) format(bcg38Query,sizeof bcg38Query,"INSERT OR REPLACE INTO private_data VALUES('%s','%s')",bcg38Owner,bcg38Escaped);
        else if(!strcmp(BCG38Kind[playerid],"photo")) {
            if(BCG38Target[playerid]<0 || BCG38Target[playerid]>24) return 1;
            format(bcg38Query,sizeof bcg38Query,"INSERT OR REPLACE INTO photos VALUES('%s',%d,'%s')",bcg38Owner,BCG38Target[playerid],bcg38Escaped);
        }
        else if(!strcmp(BCG38Kind[playerid],"comment")) {
            if(strlen(BCG38Stage[playerid])>1024) return 1;
            format(bcg38Query,sizeof bcg38Query,"INSERT INTO comments(owner,post,body,stamp) SELECT '%s',%d,'%s',%d WHERE EXISTS(SELECT 1 FROM posts WHERE id=%d)",bcg38Owner,BCG38Target[playerid],bcg38Escaped,gettime(),BCG38Target[playerid]);
        }
        else if(!strcmp(BCG38Kind[playerid],"post")) format(bcg38Query,sizeof bcg38Query,"INSERT INTO posts(owner,data,stamp) VALUES('%s','%s',%d)",bcg38Owner,bcg38Escaped,gettime());
        else
        {
            if(strlen(BCG38Stage[playerid])>1024 || BCG38Target[playerid]==BCG38Number(playerid)) return BCG38Error(playerid,"Confira o destinatario e a mensagem.");
            new bcg38ExistsQuery[100];format(bcg38ExistsQuery,sizeof bcg38ExistsQuery,"SELECT number FROM users WHERE number=%d",BCG38Target[playerid]);
            new DBResult:bcg38Result=db_query(BCG38DB,bcg38ExistsQuery),bcg38Exists=db_num_rows(bcg38Result);db_free_result(bcg38Result);
            if(!bcg38Exists) return BCG38Error(playerid,"Numero nao cadastrado.");
            format(bcg38Query,sizeof bcg38Query,"INSERT INTO messages(sender,recipient,body,stamp) VALUES(%d,%d,'%s',%d)",BCG38Number(playerid),BCG38Target[playerid],bcg38Escaped,gettime());
        }
        if(!BCG38Exec(bcg38Query)) return BCG38Error(playerid,"Nao foi possivel salvar.");
        if(!strcmp(BCG38Kind[playerid],"photo")) BCG38PhotosDirty[playerid]=true;
        if(!strcmp(BCG38Kind[playerid],"post")) BCG38FeedVersion++;
        if(!strcmp(BCG38Kind[playerid],"message")) { BCG38Record(playerid,"sent",0,""); new bcg38Peer=BCG38TargetPlayer(BCG38Target[playerid]);if(bcg38Peer!=INVALID_PLAYER_ID) {
            SendClientMessage(bcg38Peer,-1,"[BCG:UI]NOTICE|info|[Praca] Voce recebeu uma nova mensagem no celular.");
            if(BCG38Unlocked[bcg38Peer]) BCG38Snapshot(bcg38Peer);
        } }
        BCG38StageN[playerid]=BCG38StageCount[playerid]=0;BCG38Stage[playerid][0]=EOS;return BCG38Snapshot(playerid);
    }
    if(!strcmp(bcg38Verb,"transfer"))
    {
        new bcg38Peer=BCG38TargetPlayer(strval(bcg38ArgA)),bcg38Amount=strval(bcg38ArgB);
        if(bcg38Peer==INVALID_PLAYER_ID || bcg38Peer==playerid || bcg38Amount<=0 || bcg38Amount>1000000 || Pdados[playerid][Banco]<bcg38Amount || Pdados[bcg38Peer][Banco]>2146483647) return BCG38Error(playerid,"Confira saldo, valor e destinatario online.");
        if(!BCG38MoneyReady) return BCG38Error(playerid,"Banco temporariamente indisponivel.");
        new bcg38SenderAfter=Pdados[playerid][Banco]-bcg38Amount,bcg38RecipientAfter=Pdados[bcg38Peer][Banco]+bcg38Amount;
        if(!BCG38Exec("BEGIN IMMEDIATE")) return BCG38Error(playerid,"Banco ocupado. Tente novamente.");
        new bcg38PeerOwner[50];BCG38Owner(bcg38Peer,bcg38PeerOwner,sizeof bcg38PeerOwner);
        format(bcg38Query,sizeof bcg38Query,"INSERT INTO money_journal(sender,recipient,sender_after,recipient_after) VALUES('%s','%s',%d,%d)",bcg38Owner,bcg38PeerOwner,bcg38SenderAfter,bcg38RecipientAfter);
        if(!BCG38Exec(bcg38Query)) { BCG38Exec("ROLLBACK");return BCG38Error(playerid,"Transferencia nao realizada."); }
        new DBResult:bcg38JournalResult=db_query(BCG38DB,"SELECT last_insert_rowid()"),bcg38Journal=db_get_field_int(bcg38JournalResult,0);db_free_result(bcg38JournalResult);
        format(bcg38Query,sizeof bcg38Query,"INSERT INTO ledger(owner,peer,amount,stamp) VALUES('%s','%s',%d,%d),('%s','%s',%d,%d)",bcg38Owner,bcg38PeerOwner,-bcg38Amount,gettime(),bcg38PeerOwner,bcg38Owner,bcg38Amount,gettime());
        if(!BCG38Exec(bcg38Query) || !BCG38Exec("COMMIT")) { BCG38Exec("ROLLBACK");return BCG38Error(playerid,"Transferencia nao realizada."); }
        Pdados[playerid][Banco]=bcg38SenderAfter;Pdados[bcg38Peer][Banco]=bcg38RecipientAfter;
        if(!BCG38WriteBalance(Nome(playerid),bcg38SenderAfter) || !BCG38WriteBalance(Nome(bcg38Peer),bcg38RecipientAfter)) BCG38MoneyReady=false;
        else { format(bcg38Query,sizeof bcg38Query,"UPDATE money_journal SET done=1 WHERE id=%d",bcg38Journal);if(!BCG38Exec(bcg38Query)) BCG38MoneyReady=false; }
        if(!BCG38MoneyReady) { print("[BCG PHONE] Falha de persistencia bancaria. Encerrando para recuperar journal.");GameModeExit();return 1; }
        if(BCG38Unlocked[bcg38Peer]) BCG38Snapshot(bcg38Peer);return BCG38Snapshot(playerid);
    }
    if(!strcmp(bcg38Verb,"delphoto")) { new bcg38Slot=strval(bcg38ArgA);if(bcg38Slot<0||bcg38Slot>24)return 1;format(bcg38Query,sizeof bcg38Query,"DELETE FROM photos WHERE owner='%s' AND slot=%d",bcg38Owner,bcg38Slot);if(BCG38Exec(bcg38Query))BCG38PhotosDirty[playerid]=true;return BCG38Snapshot(playerid); }
    if(!strcmp(bcg38Verb,"like")) {
        new bcg38Post=strval(bcg38ArgA);
        format(bcg38Query,sizeof bcg38Query,"SELECT 1 FROM likes WHERE owner='%s' AND post=%d",bcg38Owner,bcg38Post);
        new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query),bcg38Exists=db_num_rows(bcg38Result);db_free_result(bcg38Result);
        if(bcg38Exists)format(bcg38Query,sizeof bcg38Query,"DELETE FROM likes WHERE owner='%s' AND post=%d",bcg38Owner,bcg38Post);
        else format(bcg38Query,sizeof bcg38Query,"INSERT OR IGNORE INTO likes SELECT '%s',%d WHERE EXISTS(SELECT 1 FROM posts WHERE id=%d)",bcg38Owner,bcg38Post,bcg38Post);
        BCG38Exec(bcg38Query);return BCG38Snapshot(playerid);
    }
    if(!strcmp(bcg38Verb,"follow")) {
        new bcg38Other[85];if(!BCG38Escape(bcg38ArgA,bcg38Other,sizeof bcg38Other)||!strcmp(bcg38Owner,bcg38Other))return 1;
        format(bcg38Query,sizeof bcg38Query,"SELECT 1 FROM following WHERE owner='%s' AND target='%s'",bcg38Owner,bcg38Other);
        new DBResult:bcg38Result=db_query(BCG38DB,bcg38Query),bcg38Exists=db_num_rows(bcg38Result);db_free_result(bcg38Result);
        if(bcg38Exists)format(bcg38Query,sizeof bcg38Query,"DELETE FROM following WHERE owner='%s' AND target='%s'",bcg38Owner,bcg38Other);
        else format(bcg38Query,sizeof bcg38Query,"INSERT OR IGNORE INTO following SELECT '%s','%s' WHERE EXISTS(SELECT 1 FROM users WHERE owner='%s')",bcg38Owner,bcg38Other,bcg38Other);
        BCG38Exec(bcg38Query);return BCG38Snapshot(playerid);
    }
    if(!strcmp(bcg38Verb,"call"))
    {
        new bcg38Peer=BCG38TargetPlayer(strval(bcg38ArgA));if(bcg38Peer==INVALID_PLAYER_ID||bcg38Peer==playerid||Pdados[bcg38Peer][Celular]!=1) return BCG38Error(playerid,"Destinatario indisponivel.");
        if(BCGCelularLigacao[playerid]!=INVALID_PLAYER_ID||BCGCelularLigacao[bcg38Peer]!=INVALID_PLAYER_ID) return BCG38Error(playerid,"Linha ocupada.");
        new bcg38Params[12];format(bcg38Params,sizeof bcg38Params,"%d",bcg38Peer);cmd_ligar(playerid,bcg38Params);return BCG38Record(playerid,"call",0,bcg38ArgA);
    }
    if(!strcmp(bcg38Verb,"answer")) { cmd_atender(playerid,"");return 1; }
    if(!strcmp(bcg38Verb,"hangup")) { cmd_desligar(playerid,"");return BCG38Record(playerid,"ended",0,""); }
    if(!strcmp(bcg38Verb,"gps"))
    {
        switch(strval(bcg38ArgA)) { case 0:SetPlayerCheckpoint(playerid,1685.44,-2332.46,13.55,4.0);case 1:SetPlayerCheckpoint(playerid,-1975.35,137.93,27.69,4.0);case 2:SetPlayerCheckpoint(playerid,1691.54,1448.0,10.76,4.0);default:return 1; }
        return BCG38Record(playerid,"notice",0,"Destino marcado no mapa do jogo.");
    }
    if(!strcmp(bcg38Verb,"gpsoff")) { DisablePlayerCheckpoint(playerid);return 1; }
    if(!strcmp(bcg38Verb,"drivers"))
    {
        for(new bcg38Player;bcg38Player<MAX_PLAYERS;bcg38Player++) if(IsPlayerConnected(bcg38Player)&&Pdados[bcg38Player][pLogged]&&Pdados[bcg38Player][Trabalho]==6&&Pdados[bcg38Player][Celular]==1)
        { new bcg38Driver[80];format(bcg38Driver,sizeof bcg38Driver,"%d|%s",BCG38Number(bcg38Player),Nome(bcg38Player));BCG38Record(playerid,"driver",bcg38Player,bcg38Driver); }
        return BCG38Record(playerid,"drivers",0,"");
    }
    return BCG38Error(playerid,"Pedido nao reconhecido.");
}
CMD:bcgphone38(playerid,params[]) { BCG38Request(playerid,params);return 1; }
