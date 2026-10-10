import re,sqlite3
from pathlib import Path
source=(Path(__file__).resolve().parents[2]/'server/pawno/include/bcg_phone38.inc').read_text()
db=sqlite3.connect(':memory:')
for sql in re.findall(r'BCG38Exec\("(CREATE TABLE[^"\n]*)"\)',source):db.execute(sql)
for owner in ('Jogador_Um','Jogador_Dois'):db.execute('INSERT INTO users(owner) VALUES(?)',(owner,))
db.execute('INSERT INTO private_data VALUES(?,?)',('Jogador_Um','segredo'))
db.execute('INSERT INTO photos VALUES(?,?,?)',('Jogador_Um',0,'foto_privada'))
db.execute('INSERT INTO messages(sender,recipient,body,stamp) VALUES(1,2,?,1)',('entre os dois',))
db.execute('INSERT INTO users(owner) VALUES(?)',('Jogador_Tres',))
assert db.execute('SELECT data FROM private_data WHERE owner=?',('Jogador_Dois',)).fetchall()==[]
assert db.execute('SELECT data FROM photos WHERE owner=?',('Jogador_Dois',)).fetchall()==[]
assert db.execute('SELECT body FROM messages WHERE sender=3 OR recipient=3').fetchall()==[]
db.commit()
balances={'Jogador_Um':900,'Jogador_Dois':100}
db.execute('BEGIN IMMEDIATE')
db.execute('INSERT INTO money_journal(sender,recipient,sender_after,recipient_after) VALUES(?,?,?,?)',('Jogador_Um','Jogador_Dois',800,200))
db.execute('INSERT INTO ledger(owner,peer,amount,stamp) VALUES(?,?,?,1)',('Jogador_Um','Jogador_Dois',-100))
db.execute('INSERT INTO ledger(owner,peer,amount,stamp) VALUES(?,?,?,1)',('Jogador_Dois','Jogador_Um',100));db.commit()
# A process fails after only the sender account file was updated.
balances['Jogador_Um']=800
for row in db.execute('SELECT id,sender,recipient,sender_after,recipient_after FROM money_journal WHERE done=0'):
 i,s,r,a,b=row;balances[s]=a;balances[r]=b;db.execute('UPDATE money_journal SET done=1 WHERE id=?',(i,))
assert sum(balances.values())==1000 and balances=={'Jogador_Um':800,'Jogador_Dois':200}
assert db.execute('SELECT SUM(amount) FROM ledger').fetchone()[0]==0
assert db.execute('SELECT COUNT(*) FROM money_journal WHERE done=0').fetchone()[0]==0
# Failed transaction does not create a second ledger or journal entry.
db.execute('SAVEPOINT failed')
db.execute('INSERT INTO money_journal(sender,recipient,sender_after,recipient_after) VALUES(?,?,?,?)',('Jogador_Um','Jogador_Dois',700,300))
db.execute('ROLLBACK TO failed');db.execute('RELEASE failed')
assert db.execute('SELECT COUNT(*) FROM money_journal').fetchone()[0]==1
print('SQLite: esquema, dados privados, mensagens, journal de recuperação, conservação de saldo e rollback passaram (modelo SQL; Pawn não compilado).')
