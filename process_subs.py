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



if not source_file.exists():
	print(f"Please provide a source file {source}")
	exit(1)

if not playlist_file.exists():
    print(f"Please provide a playlist file {playlist}")
    exit(1)

if not target_dir.exists():
	print("Please provide a target directory {target}")
	exit(1)
 
file_playlist = open(playlist_file,"r")

subs = pysrt.open(source_file)

index = 1

for  sub in subs:
    # print(sub.text)
    # print(sub.start.minutes)
    start_seconds=((sub.start.hours * 60 + sub.start.minutes) * 60 + sub.start.seconds) * 1000 + sub.start.milliseconds 
    # print(start_seconds)
    end_seconds=((sub.end.hours * 60 + sub.end.minutes) * 60 + sub.end.seconds) * 1000 + sub.end.milliseconds 
    # print(end_seconds)
    rounded_seconds = round((end_seconds - start_seconds) /1000, 2)
    image_file = file_playlist.readline().rstrip('\n')
    print()        
    print(f'[slide {index}]')
    print(f'filename={image_file}')
    print('angle=0')
    print(f'duration={rounded_seconds}')
    print('transition_id=-1')
    print('speed=4')
    print('no_points=0')
    print()
    index = index + 1