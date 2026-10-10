import struct,json
from pathlib import Path
containers={16,26,15,8,7,6,3,14,20}
for f in (Path(__file__).resolve().parents[2]/'app/src/main/assets/bcg_vehicles43').glob('*.dff'):
 b=f.read_bytes();textures=[];ids={}
 def walk(start,end,parent=0):
  p=start
  while p+12<=end:
   t,n,v=struct.unpack_from('<III',b,p);q=p+12+n
   if q>end:return
   ids[t]=ids.get(t,0)+1
   if parent==6 and t==2:textures.append(b[p+12:q].split(b'\0')[0].decode('ascii','replace'))
   if t in containers:walk(p+12,q,t)
   p=q
 walk(0,len(b));print(f.name,'textures',sorted(set(textures)),'native texture blocks',ids.get(21,0),'collision extension',ids.get(0x253f2fa,0))
