package com.gta.launcher.activity;
import org.junit.Test;import static org.junit.Assert.*;import java.io.*;import java.nio.*;import java.nio.file.*;
public class Character49Test {
 @Test public void completeBodyVariantsAreRequired()throws Exception {
  ByteBuffer b=ByteBuffer.allocate(72).order(ByteOrder.LITTLE_ENDIAN);
  for(int i=0;i<3;i++){b.putInt(16).putInt(12).putInt(0x1803ffff).put(new byte[12]);}
  Character49.validateModel(b.array());
  for(int length:new int[]{24,48,71}) {
   try{Character49.validateModel(java.util.Arrays.copyOf(b.array(),length));fail("Missing body variant accepted");}catch(IOException expected){}
  }
 }
 @Test public void malformedModelLengthIsRejected()throws Exception {
  ByteBuffer b=ByteBuffer.allocate(24).order(ByteOrder.LITTLE_ENDIAN);b.putInt(16).putInt(-1).putInt(0x1803ffff);
  try{Character49.validateModel(b.array());fail("Unsigned overflowing model size accepted");}catch(IOException expected){}
 }

 @Test public void textureReplacementPreservesAliasesAndFollowingEntries()throws Exception {
  Path dir=Files.createTempDirectory("bcg49");File dat=dir.resolve("source.dat").toFile(),toc=dir.resolve("source.toc").toFile(),out=dir.resolve("out.dat").toFile(),ot=dir.resolve("out.toc").toFile();
  byte[] original=new byte[96];for(int i=0;i<original.length;i++)original[i]=(byte)i;Files.write(dat.toPath(),original);
  ByteBuffer b=ByteBuffer.allocate(24).order(ByteOrder.LITTLE_ENDIAN);for(int v:new int[]{96,0,16,16,48,80})b.putInt(v);Files.write(toc.toPath(),b.array());
  byte[] patch=new byte[40];java.util.Arrays.fill(patch,(byte)201);Character49.replaceTexture(dat,toc,out,ot,16,32,patch);
  byte[] changed=Files.readAllBytes(out.toPath());assertEquals(104,changed.length);assertArrayEquals(java.util.Arrays.copyOfRange(original,0,16),java.util.Arrays.copyOfRange(changed,0,16));assertArrayEquals(patch,java.util.Arrays.copyOfRange(changed,16,56));assertArrayEquals(java.util.Arrays.copyOfRange(original,48,96),java.util.Arrays.copyOfRange(changed,56,104));
  ByteBuffer offsets=ByteBuffer.wrap(Files.readAllBytes(ot.toPath())).order(ByteOrder.LITTLE_ENDIAN);for(int v:new int[]{104,0,16,16,56,88})assertEquals(v,offsets.getInt());assertArrayEquals(original,Files.readAllBytes(dat.toPath()));
 }
 @Test public void validationUsesOriginalCharacterData()throws Exception {
  Path root=Files.createTempDirectory("bcg49validate");File backup=root.resolve(".bcg49-original-0").toFile();Files.write(backup.toPath(),new byte[]{1});assertEquals(backup,Character49.validationFile(root.toFile(),"texdb/PLAYER.IMG"));
 }
 @Test public void absentTextureSentinelsSurviveGrowingAndShrinkingPatches()throws Exception {
  for(int size:new int[]{16,40}) {
   Path dir=Files.createTempDirectory("toc53");File dat=dir.resolve("original.dat").toFile(),toc=dir.resolve("original.toc").toFile(),out=dir.resolve("result.dat").toFile(),index=dir.resolve("result.toc").toFile();
   Files.write(dat.toPath(),new byte[96]);ByteBuffer source=ByteBuffer.allocate(28).order(ByteOrder.LITTLE_ENDIAN);for(int value:new int[]{96,-1,0,16,-2,48,80})source.putInt(value);Files.write(toc.toPath(),source.array());
   Character49.replaceTexture(dat,toc,out,index,16,32,new byte[size]);ByteBuffer result=ByteBuffer.wrap(Files.readAllBytes(index.toPath())).order(ByteOrder.LITTLE_ENDIAN);
   for(int value:new int[]{96+size-32,-1,0,16,-2,48+size-32,80+size-32})assertEquals(value,result.getInt());
   assertArrayEquals(source.array(),Files.readAllBytes(toc.toPath()));
  }
 }
 @Test public void invalidIndexCannotWritePartialOutputs()throws Exception {
  Path dir=Files.createTempDirectory("toc53invalid");File dat=dir.resolve("source.dat").toFile(),toc=dir.resolve("source.toc").toFile(),out=dir.resolve("out.dat").toFile(),index=dir.resolve("out.toc").toFile();Files.write(dat.toPath(),new byte[96]);
  ByteBuffer b=ByteBuffer.allocate(12).order(ByteOrder.LITTLE_ENDIAN);b.putInt(96).putInt(16).putInt(200);Files.write(toc.toPath(),b.array());
  try{Character49.replaceTexture(dat,toc,out,index,16,32,new byte[40]);fail("Invalid offset accepted");}catch(IOException expected){}
  assertFalse(out.exists());assertFalse(index.exists());
 }
}
