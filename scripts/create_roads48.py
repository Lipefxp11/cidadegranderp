import struct,math,json,argparse
p=argparse.ArgumentParser();p.add_argument("image");p.add_argument("output");args=p.parse_args()
from pathlib import Path
nodes={};raw={}
with open(args.image,'rb') as f:
 assert f.read(4)==b'VER2';count=struct.unpack('<I',f.read(4))[0];entries=[struct.unpack('<II24s',f.read(32)) for _ in range(count)]
 for off,size,name in entries:
  name=name.split(b'\0')[0].decode()
  if not name.startswith('nodes') or not name.endswith('.dat'):continue
  area=int(name[5:-4]);f.seek(off*2048);d=f.read(size*2048);total,vehicle,ped,navi,links=struct.unpack_from('<5I',d);assert total==vehicle+ped
  linkoff=20+total*28+navi*14;assert linkoff+links*4<=len(d)
  for i in range(vehicle):
   p=20+i*28;x,y,z=struct.unpack_from('<3h',d,p+8);base,a,node=struct.unpack_from('<3H',d,p+16);flags=struct.unpack_from('<I',d,p+24)[0];degree=flags&15
   assert (a,node)==(area,i) and base+degree<=links
   if flags&0xa0:continue
   key=(area,i);nodes[key]=(x/8,y/8,z/8);raw[key]=[struct.unpack_from('<2H',d,linkoff+4*j) for j in range(base,base+degree)]
keys=sorted(nodes);index={k:i for i,k in enumerate(keys)};edges=[];out=[]
for k in keys:
 adjacency=[index[j] for j in raw[k] if j in index and j!=k];start=len(edges);edges+=adjacency;out.append((*nodes[k],start,len(adjacency),0))
path=Path(args.output);path.write_bytes(b'BCG48R01'+struct.pack('<2I',len(keys),len(edges))+b''.join(struct.pack('<3fIHH',*n) for n in out)+struct.pack('<'+'I'*len(edges),*edges))
path.with_suffix('.audit.json').write_text(json.dumps({'nodes':len(keys),'links':len(edges),'bytes':path.stat().st_size,'source':'DATA texdb/gta3.img nodes0..63.dat','water_and_switched_off_excluded':True},indent=2));print(len(keys),len(edges),path.stat().st_size)
