# read a subtitles file and convert it to EDL (mpv) format
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