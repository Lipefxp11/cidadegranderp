"""Usage: python3 map_converter.py input.ipl output.inc. Only converts inst rows."""
import argparse,math
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('input');parser.add_argument('output');args=parser.parse_args();rows=[]
for line in Path(args.input).read_text().splitlines():
 a=[v.strip() for v in line.split(',')]
 if len(a)!=11:continue
 model=int(a[0]);x,y,z=map(float,a[3:6]);qx,qy,qz,qw=map(float,a[6:10]);n=math.sqrt(qx*qx+qy*qy+qz*qz+qw*qw)
 if n<1e-8:raise ValueError('Quaternion inválido')
 qx,qy,qz,qw=[v/n for v in (qx,qy,qz,qw)]
 rx=math.degrees(math.atan2(2*(qw*qx+qy*qz),1-2*(qx*qx+qy*qy)));ry=math.degrees(math.asin(max(-1,min(1,2*(qw*qy-qz*qx)))));rz=math.degrees(math.atan2(2*(qw*qz+qx*qy),1-2*(qy*qy+qz*qz)))
 rows.append(f'    CreateDynamicObject({model}, {x:.6f}, {y:.6f}, {z:.6f}, {rx:.6f}, {ry:.6f}, {rz:.6f}, -1, 0, -1, 300.0, 300.0);')
Path(args.output).write_text('stock BCG43LoadFavela()\n{\n'+'\n'.join(rows)+'\n    return 1;\n}\n');print(len(rows),'objetos convertidos')
