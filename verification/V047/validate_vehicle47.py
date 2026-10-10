import struct, json, hashlib, shutil
from pathlib import Path
from collections import Counter
root=Path('project/BCG_V044_SOURCE_OTIMIZADA')
def chunks(d):
 out=[];i=0
 while i<len(d):
  k,n,v=struct.unpack_from('<III',d,i);assert i+12+n<=len(d);out.append((k,v,d[i+12:i+12+n]));i+=12+n
 assert i==len(d);return out
def geom(d):
 c=chunks(d);s=c[0][2];f,t,n,m=struct.unpack_from('<4I',s);uv=(f>>16)&255;uv=uv or (2 if f&128 else 1 if f&4 else 0);o=16
 arrays=[]
 if f&8:arrays.append((o,4));o+=n*4
 for _ in range(uv):arrays.append((o,8));o+=n*8
 tris=[struct.unpack_from('<4H',s,o+8*i) for i in range(t)];o+=8*t;sphere=s[o:o+24];p,q=struct.unpack_from('<2I',s,o+16);o+=24
 if p:arrays.append((o,12));o+=n*12
 if q:arrays.append((o,12));o+=n*12
 assert o==len(s)
 attrs=[b''.join(s[a+i*z:a+(i+1)*z] for a,z in arrays) for i in range(n)]
 ext=next(x[2] for x in c if x[0]==3);bm=next(x[2] for x in chunks(ext) if x[0]==0x50e);fl,nm,tot=struct.unpack_from('<3I',bm);assert fl==0 and tot==t*3
 i=12;actual=[]
 for _ in range(nm):
  count,mat=struct.unpack_from('<2I',bm,i);i+=8;inds=struct.unpack_from('<'+'I'*count,bm,i);i+=4*count
  for j in range(0,count,3):actual.append((inds[j+1],inds[j],mat,inds[j+2]))
 assert i==len(bm)
 def canon(t):
  b,a,m,c=t;return min((a,b,c),(b,c,a),(c,a,b))
 assert Counter(map(canon,actual))==Counter(map(canon,tris)), (actual[:3],tris[:3])
 assert all(max(a,b,c)<n for b,a,mat,c in tris)
 return attrs,sphere,c
count=0
def compare(a,b):
 global count
 ca,cb=chunks(a),chunks(b);assert len(ca)==len(cb)
 for x,y in zip(ca,cb):
  assert x[:2]==y[:2]
  if x[0] in (16,26):compare(x[2],y[2])
  elif x[0]==15:
   aa,sa,pa=geom(x[2]);ab,sb,pb=geom(y[2]);assert sa==sb and set(ab)<=set(aa)
   assert [p for p in pa if p[0] not in (1,3)]==[p for p in pb if p[0] not in (1,3)]
   count+=1
  else:assert x==y
import sys
for name in ['landstal','rancher','sadler']:
 compare((root/'mods_v043/carros'/f'{name}.dff').read_bytes(),(root/'app/src/main/assets/bcg_vehicles43'/f'{name}.dff').read_bytes())
print('PASS:',count,'geometries; vertex attributes, frames, materials and collisions preserved')
