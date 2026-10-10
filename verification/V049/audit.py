import json,struct,hashlib,sys
from pathlib import Path
sys.path.insert(0,'project/BCG_V044_SOURCE_OTIMIZADA/scripts')
from create_avatar49 import chunks
root=Path('project/BCG_V044_SOURCE_OTIMIZADA/app/src/main/assets/bcg_character49');m=json.loads((root/'manifest.json').read_text());image=Path('build47/player.img').read_bytes();original={}
for i in range(struct.unpack_from('<I',image,4)[0]):
 off,n,_,name=struct.unpack_from('<IHH24s',image,8+32*i);name=name.split(b'\0')[0].decode();b=image[off*2048:(off+n)*2048];original[name]=b[:12+struct.unpack_from('<I',b,4)[0]]
def compare(a,b):
 aa=list(chunks(a));bb=list(chunks(b));assert len(aa)==len(bb)
 for (t,v,p),(tt,vv,q) in zip(aa,bb):
  assert(t,v,len(p))==(tt,vv,len(q))
  if t in (16,26):compare(p,q)
  elif t==15:
   cp=list(chunks(p));cq=list(chunks(q));assert cp[1:]==cq[1:] # all material, bone weights, plugins unchanged
   s=cp[0][2];u=cq[0][2];f,nt,nv,nm=struct.unpack_from('<IIII',s);sets=(f>>16)&255 or (2 if f&128 else 1 if f&4 else 0);end=16+(4*nv if f&8 else 0)+8*nv*sets+nt*8
   assert s[:end]==u[:end] # counts, colors, UVs and triangle connectivity unchanged
   assert s[end+16:end+24]==u[end+16:end+24]
  else:assert p==q
for item in m['models']:
 b=(root/item['file']).read_bytes();assert len(b)==item['size'] and hashlib.sha256(b).hexdigest()==item['sha256'];compare(original[item['file']],b)
raw=(root/'face49.native').read_bytes();a,fmt,w,h,n,rle=struct.unpack_from('<HHHHII',raw);assert fmt==0x83f0 and rle==0 and len(raw)==12+n
expected=0;x,y=w,h&0x7fff
while True:
 expected+=max(1,(x+3)//4)*max(1,(y+3)//4)*8
 if x==y==1:break
 x=max(1,x//2);y=max(1,y//2)
assert len(raw)==16+expected
report={'models_checked':len(m['models']),'same_bones_weights_uv_triangles':True,'texture_mips_valid':True,'added_vertices':0,'added_triangles':0,'android_runtime_tested':False}
Path('project/BCG_V044_SOURCE_OTIMIZADA/verification/V049/geometry-audit.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
