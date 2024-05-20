import sys
import re
import argparse
import ffmpeg
import os


def shift_subtitles(input_file, output_file, time_offset_str):
    time_offset = convert_timestamp_to_milliseconds(time_offset_str)

    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if re.match(r"\d\d:\d\d:\d\d,\d\d\d --> \d\d:\d\d:\d\d,\d\d\d", line):
                start, end = line.split(" --> ")
                start_time = convert_to_milliseconds(start)
                end_time = convert_to_milliseconds(end)
                shifted_start = convert_to_timestamp(start_time + time_offset)
                shifted_end = convert_to_timestamp(end_time + time_offset)
                outfile.write(f"{shifted_start} --> {shifted_end}\n")
            else:
                outfile.write(line)

def convert_to_milliseconds(timestamp):
    h, m, s_ms = timestamp.split(':')
    s, ms = s_ms.split(',')
    return int(h) * 3600000 + int(m) * 60000 + int(s) * 1000 + int(ms)

def convert_to_timestamp(milliseconds):
    ms = int(milliseconds)
    s, ms = divmod(ms, 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

def convert_timestamp_to_milliseconds(timestamp_str):
    parts = timestamp_str.split(':')
    if len(parts) == 3:  # Format: HH:MM:SS
        h, m, s = map(int, parts)
        return h * 3600000 + m * 60000 + s * 1000
    else:
        raise ValueError("Invalid timestamp format. Use HH:MM:SS")


# This function takes the .srt/vtt file and finds the related audio file in the same directory
def get_audio_file(input_file):
    audio_file = None
    # Look for a related audio file in the same directory as the input subtitle file
    # File types are .mp3, m4a, .wav, .flac, .ogg, .opus .webm .mp4, .mkv
    # For example, if the input file is "subtitle.srt", the audio file would be "subtitle.mp3" if the 
    # mp3 file exists (or m4a if the m4a file exists, etc.)
    # So, take the input file, remove the .srt extension and try each audio file extension
    # and check if that file exists.
    # If the audio file is found, return the audio file name. If not found, return None.
    input_file_without_extension = input_file.replace(".srt", "").replace(".vtt", "")
    input_file_directory = os.path.dirname(input_file)
    # for each audio file extension, check if the file exists
    # make a list of audio file types .mp3, m4a, .wav, .flac, .ogg, .opus .webm .mp4, .mkv
    audio_file_extensions = [".mp3", ".m4a", ".wav", ".flac", ".ogg", ".opus", ".webm", ".mp4", ".mkv"]
    for extension in audio_file_extensions:
        audio_file = f"{input_file_without_extension}{extension}"
        if os.path.exists(audio_file):
            break
        else:
            audio_file = None
    return audio_file




if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Shift subtitle timings.")
    parser.add_argument("input_file", help="Input subtitle file (.srt or .vtt)")
    parser.add_argument("output_file", help="Output subtitle file")
    parser.add_argument("time_offset", help="Time offset in HH:MM:SS format (e.g., 00:01:30)")

    args = parser.parse_args()

    # call get_audio_file function to get the audio file name. If it returns a valid filename,
    # then continue, otherwise print an error and exit
    audio_file = get_audio_file(args.input_file)
    if audio_file is None:
        print("Could not find the related audio file.")
        sys.exit(1)
    # get the length of the audio file in milliseconds
    audio_file_info = ffmpeg.probe(audio_file)
    audio_duration = int(float(audio_file_info['format']['duration']) * 1000)
    print(f"Audio File: {audio_file}  duration: {audio_duration} ms")
    # Calculate the time difference between the audio duration and the time_offset
    time_offset = convert_timestamp_to_milliseconds(args.time_offset)
    time_difference = audio_duration - time_offset
    print(f"Time difference: {time_difference} ms")
    # if the time difference is negative, print an error and exit
    if time_difference < 0:
        print("Time offset is greater than the audio duration.")
        sys.exit(1)

# extract the audio sections - destination is in /tmp/ with filename the same as the audio_file
    audio_output = f"/tmp/{os.path.basename(audio_file)}"
    input_stream = ffmpeg.input(audio_file)
    audio_stream = input_stream.audio.filter('atrim', start=args.time_offset).filter('asetpts', 'PTS-STARTPTS')
    audio_output = ffmpeg.output(audio_stream, audio_output, acodec='copy')
    ffmpeg.run(audio_output)
    print(f"Extracted audio file: {audio_output}")


    output_srt_file = f"/tmp/{os.path.basename(args.output_file)}"
    shift_subtitles(args.input_file, output_srt_file, args.time_offset)
    print(f"Shifted subtitle file: {output_srt_file}")
    
    # shift_subtitles(args.input_file, args.output_file, args.time_offset)
# # FFmpeg-Python commands
#     input_stream = ffmpeg.input(media_file)

#     audio_stream = input_stream.audio.filter('atrim', start=args.time_offset).filter('asetpts', 'PTS-STARTPTS')
#     audio_output = ffmpeg.output(audio_stream, args.output_file + "_audio.m4a", acodec='copy')

#     # Subtitle Extraction (FFmpeg-Python method)
#     subtitle_stream = ffmpeg.input(args.input_file)
#     subtitle_output = ffmpeg.output(subtitle_stream, args.output_file + "_subtitles.srt", ss=args.time_offset)

#     # Execute FFmpeg
#     ffmpeg.run(audio_output)
#     ffmpeg.run(subtitle_output)
