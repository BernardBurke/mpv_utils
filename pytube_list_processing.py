#!/usr/bin/python3
from pytube import Playlist
import argparse
from pathlib import Path
parser = argparse.ArgumentParser()                                               


arg_parser = argparse.ArgumentParser( description = "Please provide an input file and work directory" )
arg_parser.add_argument( "source_file" )
arg_parser.add_argument( "target_dir" )
arg_parser.add_argument( "itag" )

arguments = arg_parser.parse_args()

source = arguments.source_file
target = arguments.target_dir

source_file = Path(source)
target_dir = Path(target)


if not source_file.exists():
	print(f"Please provide a source file {source}")
	exit(1)

if not target_dir.exists():
	print("Please provide a target directory {target}")
	exit(1)

if arguments.itag is not None:
	itag = arguments.itag
else:
    itag = "251"





#print( "Copying [{}] to [{}]".format(source, target) )

def ProcessList(list):
	p = Playlist(list)
	print(f"Processing list {list} and saving in {target_dir} using {itag}")
	for v in p.videos:
		print(f"Processing {v}")
		try:
			stream = v.streams.get_by_itag(itag)
			stream.download(target_dir)
		except KeyboardInterrupt: 
			exit()
		except:
			pass

print(source_file)

with open(source_file) as f:


    [ProcessList(line) for line in f.readlines()]
