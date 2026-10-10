"""BCG derivative CJ variant. Preserves skin, UV, topology and frame chunks.
Requires the user's original PLAYER.IMG and native DXT database; no source DATA is distributed.
"""
import argparse,hashlib,json,struct
from pathlib import Path
import numpy as np
from PIL import Image

def sha(b):return hashlib.sha256(b).hexdigest()
def chunks(b):
 p=0
 while p<len(b):
  t,n,v=struct.unpack_from('<III',b,p);assert p+12+n<=len(b)
  yield t,v,b[p+12:p+12+n];p+=12+n
 assert p==len(b)
def pack(t,v,b):return struct.pack('<III',t,len(b),v)+b

def unpad_model(data):
 p=0
 while p<len(data):
  if not any(data[p:]):return data[:p]
  if p+12>len(data):raise ValueError('Truncated model chunk header')
  kind,size,version=struct.unpack_from('<III',data,p)
  if kind==0 or p+12+size>len(data):raise ValueError('Invalid model chunk')
  p+=12+size
 return data

def warp(v):
 z=v[:,2];out=v.copy()
 # Small rest-pose changes only; one continuous deformation for all pieces.
 torso=np.exp(-((z-.29)/.19)**2);waist=np.exp(-((z-.04)/.105)**2)
 out[:,1]*=1+.045*torso-.018*waist
 out[:,0]*=1+.055*torso
 head=np.clip((z-.56)/.08,0,1);out[:,1]*=1+.035*head
 nose=np.exp(-((z-.662)/.023)**2)*np.clip((v[:,0]-.065)/.055,0,1)
 out[:,0]-=.008*nose
 return out

def sculpt(b,audit):
 def visit(b):
  out=[]
  for t,ver,p in chunks(b):
   if t==15:
    parts=list(chunks(p));kind,sv,s=parts[0];assert kind==1
    f,nt,nv,nm=struct.unpack_from('<IIII',s);assert not f&0x1000000 and nm==1
    sets=(f>>16)&255 or (2 if f&128 else 1 if f&4 else 0)
    pos=16+(4*nv if f&8 else 0)+8*nv*sets;tri=np.frombuffer(s,'<u2',nt*4,pos).reshape(-1,4)[:,[1,0,3]]
    m=pos+nt*8;hp,hn=struct.unpack_from('<II',s,m+16);assert hp
    pos=m+24;v=np.frombuffer(s,'<f4',nv*3,pos).reshape(-1,3);new=warp(v)
    assert np.isfinite(new).all() and len(s)==pos+12*nv*(1+bool(hn))
    dst=bytearray(s);dst[pos:pos+nv*12]=new.astype('<f4').tobytes()
    center=new.mean(0);radius=np.linalg.norm(new-center,axis=1).max();struct.pack_into('<4f',dst,m,*center,float(radius))
    if hn:
     # Transform original vertex normals with local inverse-transpose Jacobian;
     # preserves authored smoothing and split vertices.
     eps=1e-4;j=[]
     for axis in range(3):
      plus=v.copy();minus=v.copy();plus[:,axis]+=eps;minus[:,axis]-=eps;j.append((warp(plus)-warp(minus))/(2*eps))
     jac=np.stack(j,axis=2);norm=np.frombuffer(s,'<f4',nv*3,pos+12*nv).reshape(-1,3)
     norms=np.linalg.solve(np.swapaxes(jac,1,2),norm[...,None])[...,0];norms/=np.maximum(np.linalg.norm(norms,axis=1)[:,None],1e-9)
     dst[pos+nv*12:pos+nv*24]=norms.astype('<f4').tobytes()
    parts[0]=(kind,sv,bytes(dst));p=b''.join(pack(*part) for part in parts);audit['vertices']+=nv;audit['triangles']+=nt
   elif t in (16,26):p=visit(p)
   out.append(pack(t,ver,p))
  return b''.join(out)
 return visit(b)

def bc1(im):
 a=np.asarray(im.convert('RGB'),dtype=np.int32);h,w=a.shape[:2];a=np.pad(a,((0,(-h)%4),(0,(-w)%4),(0,0)),mode='edge');result=bytearray()
 for y in range(0,a.shape[0],4):
  for x in range(0,a.shape[1],4):
   p=a[y:y+4,x:x+4].reshape(16,3);lo=p.min(0);hi=p.max(0)
   def c565(c):return int((c[0]*31//255)<<11|(c[1]*63//255)<<5|(c[2]*31//255))
   c0,c1=c565(hi),c565(lo)
   if c0<=c1:c0=min(65535,c1+1);c1=max(0,c0-1)
   def rgb(c):return np.array([(c>>11)*255//31,((c>>5)&63)*255//63,(c&31)*255//31])
   q0,q1=rgb(c0),rgb(c1);palette=np.array([q0,q1,(2*q0+q1)//3,(q0+2*q1)//3]);idx=((p[:,None]-palette)**2).sum(2).argmin(1);bits=sum(int(k)<<(2*i) for i,k in enumerate(idx));result+=struct.pack('<HHI',c0,c1,bits)
 return result

def main():
 p=argparse.ArgumentParser();p.add_argument('img');p.add_argument('database');p.add_argument('face');p.add_argument('out');args=p.parse_args();out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
 image=Path(args.img).read_bytes();assert image[:4]==b'VER2';count=struct.unpack_from('<I',image,4)[0];models=[];audit={'vertices':0,'triangles':0,'models':0}
 for i in range(count):
  off,size,unused,name=struct.unpack_from('<IHH24s',image,8+32*i);name=name.split(b'\0')[0].decode();data=image[off*2048:(off+size)*2048]
  if not name.lower().endswith('.dff'):continue
  # PLAYER parts contain consecutive normal/fat/ripped clumps.
  # Only sector padding may be removed; truncating to the first clump loses variants.
  data=unpad_model(data)
  if len(list(chunks(data)))!=3:raise ValueError('PLAYER model requires normal/fat/ripped clumps: '+name)
  new=sculpt(data,audit);assert len(new)==len(data)
  (out/name).write_bytes(new);models.append({'file':name,'size':len(new),'sha256':sha(new)});audit['models']+=1
 assert {'head.dff','torso.dff','legs.dff','feet.dff'}<={m['file'] for m in models}
 database=Path(args.database);dat=(database/'player.dxt.dat').read_bytes();toc=(database/'player.dxt.toc').read_bytes();lines=(database/'player.txt').read_text().splitlines();index=next(i for i,l in enumerate(lines) if l.startswith('"wedge_face"'))
 offsets=struct.unpack('<'+'I'*(len(toc)//4),toc);offset=offsets[index];end=min(o for o in offsets[1:] if o>offset);old=dat[offset:end];hash16,fmt,w,h,size,rle=struct.unpack_from('<HHHHII',old);assert fmt==0x83f0 and w==128 and h&0x7fff==128 and end-offset==12+size
 face=Image.open(args.face).convert('RGB').resize((128,128),Image.Resampling.LANCZOS);face.save(out/'face49.png');payload=bytearray();mip=face
 while True:
  payload+=bc1(mip)
  if mip.size==(1,1):break
  mip=mip.resize((max(1,mip.width//2),max(1,mip.height//2)),Image.Resampling.LANCZOS)
 new=struct.pack('<HHHHII',hash16,fmt,w,h,len(payload)+4,0)+payload;(out/'face49.native').write_bytes(new)
 manifest={'schema':49,'baseImg':sha(image),'models':models,'face':{'file':'face49.native','size':len(new),'sha256':sha(new),'offset':offset,'oldSize':len(old),'baseDat':sha(dat),'baseToc':sha(toc)},'audit':audit,'description':'Derivative CJ rest-pose variant; same UV, bones, weights and topology. Default face texture only.'}
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2));print(json.dumps(audit))
if __name__=='__main__':main()
