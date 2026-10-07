"""Validate the installed sprite texture and its frame isolation (Pillow required)."""
import json
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1] / 'pets' / 'tired-brian'
manifest = json.loads((root / 'pet.json').read_text(encoding='utf-8'))
assert manifest['spriteVersionNumber'] == 1
assert manifest['spritesheetPath'] == 'spritesheet.png'
im = Image.open(root / 'spritesheet.png')
assert im.mode == 'RGBA' and im.size == (1536, 1872)
for row in range(9):
    for col in range(8):
        cell = im.crop((col*192, row*208, (col+1)*192, (row+1)*208)).getchannel('A')
        assert cell.getbbox(), (row, col, 'empty frame')
        for box in [(0,0,192,10),(0,198,192,208),(0,0,10,208),(182,0,192,208)]:
            assert cell.crop(box).getextrema() == (0,0), (row, col, 'neighbor-frame bleed')
print('PASS: RGBA 1536x1872; all 72 frames populated; all boundaries have 10px transparent padding.')
