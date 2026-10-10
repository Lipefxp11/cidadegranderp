import importlib.util,struct,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('avatar',Path(__file__).resolve().parents[2]/'scripts/create_avatar49.py');avatar=importlib.util.module_from_spec(spec);spec.loader.exec_module(avatar)
class ClumpTest(unittest.TestCase):
 def test_preserve_three_consecutive_clumps(self):
  original=b''.join(struct.pack('<III',16,12,0x1803ffff)+bytes([i])*12 for i in range(3));self.assertEqual(avatar.unpad_model(original+b'\0'*200),original);self.assertEqual(len(list(avatar.chunks(avatar.unpad_model(original+b'\0'*200)))),3)
 def test_corrupt_or_truncated_tail_rejected(self):
  first=struct.pack('<III',16,12,0x1803ffff)+b'a'*12
  for tail in [b'bad',struct.pack('<III',16,50,0x1803ffff)+b'a',b'\0'*12+b'x']:
   with self.assertRaises(ValueError):avatar.unpad_model(first+tail)
if __name__=='__main__':unittest.main()
