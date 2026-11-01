"""Synthesize original mono WAV assets, without samples or external dependencies."""
from pathlib import Path
import math, wave, array, random
ROOT=Path(__file__).resolve().parents[1]/'assets/audio'
ROOT.mkdir(parents=True,exist_ok=True)
RATE=16000
def render(name,duration,fn):
 samples=array.array('h',(int(max(-1,min(1,fn(i/RATE)))*24000) for i in range(int(RATE*duration))))
 with wave.open(str(ROOT/f'{name}.wav'),'wb') as w:
  w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE); w.writeframes(samples.tobytes())
def tone(t,f): return math.sin(2*math.pi*f*t)
def pluck(t,f): return 0 if t<0 else (tone(t,f)+.25*tone(t,2*f))*math.exp(-t*5)*min(1,t*120)
render('Menu',.32,lambda t: .32*pluck(t,880)+.2*pluck(t-.07,1320))
render('Hit',.22,lambda t: .5*math.exp(-t*24)*tone(t,180-250*t)+.12*math.exp(-t*35)*tone(t,1560))
render('LevelUp',1.8,lambda t: sum(.23*pluck(t-i*.14,f) for i,f in enumerate([440,550,660,880,1100])))
# An airy pentatonic motif over quiet harmonics, with fades for a seamless silence boundary.
notes=[220,330,440,550,660,440,330,275]
def ambient(t):
 envelope=min(1,t/1.5,(12-t)/1.5)
 pad=.04*tone(t,110)+.025*tone(t,165)+.018*tone(t,220)
 melody=sum(.08*pluck(t-i*1.3,f) for i,f in enumerate(notes))
 return max(0,envelope)*(pad+melody)
render('Ambient',12,ambient)
render('Machine',4,lambda t: min(1,t*4,(4-t)*4)*(.055*tone(t,55)+.025*tone(t,110)+.017*tone(t,440)*(1+tone(t,2))))
print('Generated five original WAV files.')
