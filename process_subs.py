import pysrt
import argparse
from pathlib import Path
parser = argparse.ArgumentParser()                                               


arg_parser = argparse.ArgumentParser( description = "Please provide an input file and work directory" )
arg_parser.add_argument( "source_file" )
arg_parser.add_argument( "playlist_file" )

arg_parser.add_argument( "target_dir" )

arguments = arg_parser.parse_args()

source = arguments.source_file
playlist = arguments.playlist_file
target = arguments.target_dir

source_file = Path(source)
playlist_file = Path(playlist)
target_dir = Path(target)

media_pair = None


if not source_file.exists():
	print(f"Please provide a source file {source}")
	exit(1)
 
if source_file.with_suffix('.mp3').exists():
    media_pair = source_file.with_suffix('.mp3')

if source_file.with_suffix('.m4a').exists():
    media_pair = source_file.with_suffix('.m4a')

if source_file.with_suffix('.mpga').exists():
    media_pair = source_file.with_suffix('.mpga')

if source_file.with_suffix('.wav').exists():
    media_pair = source_file.with_suffix('.wav')
    
if media_pair is None:
    print(f'No media file found for {source_file}')
    exit(1)

    

if not playlist_file.exists():
    print(f"Please provide a playlist file {playlist}")
    exit(1)

if not target_dir.exists():
	print("Please provide a target directory {target}")
	exit(1)
 
file_playlist = open(playlist_file,"r")

subs = pysrt.open(source_file)

with open(playlist_file,"r") as fp:
    max_playlist_lines = len(fp.readlines())

max_subtitles = len(subs)

if max_playlist_lines > max_subtitles:
    max_cycles = max_subtitles
else:
    max_cycles = max_playlist_lines
    
counter = 1
total_seconds = 0

previous_start = None

print('#Imagination 2.0 Slideshow Project - http://imagination.sf.net')
print('')
print('[slideshow settings]')
print('video codec=x264')
print('video width=1920')
print('video height=1080')
print('fps=25 (PAL)')
print('aspect ratio=Old TV 4:3')
print('bitrate=1500k')
print('blank slide=false')
print('background color=0;0;0;')
print('distort images=true')
print(f'number of slides={max_cycles}')
print('')

for  sub in subs:
    # print(sub.text)
    # print(sub.start.minutes)
    start_seconds=((sub.start.hours * 60 + sub.start.minutes) * 60 + sub.start.seconds) * 1000 + sub.start.milliseconds 
    # print(start_seconds)
    end_seconds=((sub.end.hours * 60 + sub.end.minutes) * 60 + sub.end.seconds) * 1000 + sub.end.milliseconds 
    if previous_start is None:
        rounded_seconds = round((end_seconds) /1000, 2)
        previous_start = end_seconds
    else:
        rounded_seconds = round((start_seconds - previous_start) /1000, 2)
        previous_start = start_seconds



    # print(end_seconds)
    # rounded_seconds = round((end_seconds - start_seconds) /1000, 2)
    # rounded_seconds = (end_seconds - start_seconds) / 1000
    total_seconds = total_seconds + rounded_seconds
    image_file = file_playlist.readline().rstrip('\n')
    if not image_file:
        break
    print()        
    print(f'[slide {counter}]')
    print(f'filename={image_file}')
    print('angle=0')
    print(f'duration={rounded_seconds}')
    print('transition_id=-1')
    print('speed=4')
    print('no_points=0')
    print()
    counter = counter + 1
    if counter > max_cycles:
        break
    
print()
print('[music]')
print('fadeout duration=0')
print('number=1')
#print("music_1=/mnt/d/grls/audio/emma_patreon/dad's gift.mp3")
print(f'music_1={media_pair}')
print()
    
# print(f'Total seconds {total_seconds/60}')
# print(len(subs))