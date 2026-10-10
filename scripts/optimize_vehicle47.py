"""Reduce supported unskinned RW geometries with meshoptimizer 0.22.

Preserves frame hierarchy, materials, collision chunks and original vertex
attributes. Fails closed for native geometry, morph animations and unknown
geometry plugins. Requires a host shared build of meshoptimizer (MIT).
"""
import argparse,ctypes as C,json,struct
from pathlib import Path

def chunks(data):
    cursor=0
    while cursor<len(data):
        assert cursor+12<=len(data), 'Incomplete RW header'
        kind,size,version=struct.unpack_from('<III',data,cursor)
        end=cursor+12+size
        assert end<=len(data), 'Incomplete RW chunk'
        yield kind,version,data[cursor+12:end]
        cursor=end

def pack(kind,version,data):
    return struct.pack('<III',kind,len(data),version)+data

def optimize(data,lib,report):
    def geometry(payload):
        parts=list(chunks(payload));assert parts[0][0]==1
        source=parts[0][2]
        flags,triangle_count,vertex_count,morphs=struct.unpack_from('<IIII',source)
        assert not flags&0x1000000 and morphs==1 and vertex_count<=65535
        texsets=(flags>>16)&255
        if not texsets:texsets=2 if flags&128 else 1 if flags&4 else 0
        cursor=16;arrays=[]
        if flags&8:arrays.append((cursor,4));cursor+=vertex_count*4
        for _ in range(texsets):arrays.append((cursor,8));cursor+=vertex_count*8
        triangle_offset=cursor;cursor+=triangle_count*8
        morph_offset=cursor;has_positions,has_normals=struct.unpack_from('<II',source,cursor+16);cursor+=24
        assert has_positions
        position_offset=cursor;arrays.append((cursor,12));cursor+=vertex_count*12
        normal_offset=cursor if has_normals else None
        if has_normals:arrays.append((cursor,12));cursor+=vertex_count*12
        assert cursor==len(source),'Unsupported geometry struct'
        extensions=[(i,tuple(chunks(part[2]))) for i,part in enumerate(parts) if part[0]==3]
        assert len(extensions)==1
        extension_index,plugins=extensions[0]
        assert all(kind==0x50e or (kind==0x253f2fd and plugin==b'\0'*4) for kind,version,plugin in plugins), 'Unsupported vertex-indexed plugin'
        meshes=[plugin for kind,version,plugin in plugins if kind==0x50e];assert len(meshes)==1
        mesh_flags,mesh_count,total_indices=struct.unpack_from('<III',meshes[0]);assert mesh_flags==0
        cursor=12;mesh_indices=[]
        for _ in range(mesh_count):
            count,material=struct.unpack_from('<II',meshes[0],cursor);cursor+=8
            indices=list(struct.unpack_from('<'+'I'*count,meshes[0],cursor));cursor+=count*4
            assert count%3==0 and all(i<vertex_count for i in indices)
            mesh_indices.append((material,indices))
        assert cursor==len(meshes[0]) and sum(len(i) for m,i in mesh_indices)==total_indices==triangle_count*3
        positions=(C.c_float*(vertex_count*3)).from_buffer_copy(source[position_offset:position_offset+vertex_count*12])
        attributes=[]
        # Texture coordinates and normals are kept in the simplification metric.
        if has_normals:attributes.append((normal_offset,3,0.2))
        uv_start=16+(vertex_count*4 if flags&8 else 0)
        for i in range(texsets):attributes.append((uv_start+i*vertex_count*8,2,1.0))
        if flags&8:
            raise ValueError('Prelit geometry requires a color-aware simplification policy')
        width=sum(n for off,n,w in attributes)
        attribute_data=(C.c_float*(vertex_count*width))()
        for i in range(vertex_count):
            column=0
            for offset,count,weight in attributes:
                values=struct.unpack_from('<'+'f'*count,source,offset+i*count*4)
                for v in values:attribute_data[i*width+column]=v;column+=1
        weights=(C.c_float*width)(*[w for off,n,w in attributes for _ in range(n)])
        simplified=[];max_error=0
        for material,indices in mesh_indices:
            src=(C.c_uint*len(indices))(*indices);dst=(C.c_uint*len(indices))();error=C.c_float()
            target=max(3,int(len(indices)*0.4)//3*3)
            count=lib.meshopt_simplifyWithAttributes(dst,src,len(indices),positions,vertex_count,12,attribute_data,width*4,weights,width,None,target,0.003,0,C.byref(error))
            assert 0<count<=len(indices) and count%3==0
            kept=list(dst[:count]);assert all(i<vertex_count for i in kept)
            simplified.append((material,kept));max_error=max(max_error,error.value)
        used=sorted({index for material,indices in simplified for index in indices});remap={old:new for new,old in enumerate(used)}
        new_triangles=[];new_meshes=[]
        for material,indices in simplified:
            mapped=[remap[i] for i in indices];new_meshes.append((material,mapped))
            for i in range(0,len(mapped),3):
                a,b,c=mapped[i:i+3];new_triangles.append(struct.pack('<HHHH',b,a,material,c))
        new_count=len(new_triangles)
        out=struct.pack('<IIII',flags,new_count,len(used),1)
        for offset,stride in arrays:
            if offset<triangle_offset:out+=b''.join(source[offset+i*stride:offset+(i+1)*stride] for i in used)
        out+=b''.join(new_triangles)+source[morph_offset:morph_offset+24]
        for offset,stride in arrays:
            if offset>morph_offset:out+=b''.join(source[offset+i*stride:offset+(i+1)*stride] for i in used)
        binary=struct.pack('<III',0,mesh_count,new_count*3)
        for material,indices in new_meshes:binary+=struct.pack('<II',len(indices),material)+struct.pack('<'+'I'*len(indices),*indices)
        parts[0]=(parts[0][0],parts[0][1],out)
        parts[extension_index]=(3,parts[extension_index][1],b''.join(pack(kind,version,binary if kind==0x50e else plugin) for kind,version,plugin in plugins))
        report.append({'triangles_before':triangle_count,'triangles_after':new_count,'vertices_before':vertex_count,'vertices_after':len(used),'relative_error':max_error})
        return b''.join(pack(*part) for part in parts)
    def visit(payload,parent=0):
        out=[]
        for kind,version,part in chunks(payload):
            if kind==15:part=geometry(part)
            elif kind in {16,26}:part=visit(part,kind)
            out.append(pack(kind,version,part))
        return b''.join(out)
    return visit(data)

def main():
    p=argparse.ArgumentParser();p.add_argument('library');p.add_argument('source');p.add_argument('output');args=p.parse_args()
    lib=C.CDLL(str(Path(args.library).resolve()))
    lib.meshopt_simplifyWithAttributes.restype=C.c_size_t
    lib.meshopt_simplifyWithAttributes.argtypes=[C.POINTER(C.c_uint),C.POINTER(C.c_uint),C.c_size_t,C.POINTER(C.c_float),C.c_size_t,C.c_size_t,C.POINTER(C.c_float),C.c_size_t,C.POINTER(C.c_float),C.c_size_t,C.c_void_p,C.c_size_t,C.c_float,C.c_uint,C.POINTER(C.c_float)]
    source=Path(args.source).read_bytes();report=[];output=optimize(source,lib,report)
    assert len(output)<=len(source)
    target=Path(args.output);target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(output)
    target.with_suffix('.audit.json').write_text(json.dumps({'bytes_before':len(source),'bytes_after':len(output),'geometries':report},indent=2))
    print(target.name,len(source),'->',len(output),'triangles',sum(x['triangles_before'] for x in report),'->',sum(x['triangles_after'] for x in report))
if __name__=='__main__':main()
