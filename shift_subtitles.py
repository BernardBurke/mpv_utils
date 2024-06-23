import sys
import re
import argparse
import ffmpeg
import os


import re

def shift_subtitles(input_file, output_file, time_offset_str):
    """Shifts subtitles in an SRT file based on a time offset.

    Args:
        input_file (str): Path to the input SRT file.
        output_file (str): Path to save the shifted subtitles.
        time_offset_str (str): Time offset in HH:MM:SS,mmm format.

    Returns:
        None: Writes the shifted subtitles to the output file.
    """

    def time_str_to_ms(time_str):
        """Converts a time string to milliseconds."""
        # print(f'time_str: {time_str}')
        time_parts = re.split(r"[:,]", time_str)
        h = int(time_parts[0])
        m = int(time_parts[1])
        s = int(time_parts[2])
        ms = int(time_parts[3]) if len(time_parts) > 3 else 0
        return h * 3600000 + m * 60000 + s * 1000 + ms

    time_offset_ms = time_str_to_ms(time_offset_str)

    with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
        for line in f_in:
            # Check if the line is a time range
            if "-->" in line:
                start_time, end_time = line.strip().split(" --> ")

                # Convert time ranges to milliseconds
                start_ms = time_str_to_ms(start_time)
                end_ms = time_str_to_ms(end_time)

                # Apply time offset and convert back to string
                shifted_start = max(0, start_ms - time_offset_ms)  # Ensure non-negative
                shifted_end = max(0, end_ms - time_offset_ms)

                shifted_start_str = f"{shifted_start // 3600000:02d}:{(shifted_start % 3600000) // 60000:02d}:{(shifted_start % 60000) // 1000:02d},{shifted_start % 1000:03d}"
                shifted_end_str = f"{shifted_end // 3600000:02d}:{(shifted_end % 3600000) // 60000:02d}:{(shifted_end % 60000) // 1000:02d},{shifted_end % 1000:03d}"

                # Write the shifted time range to the output file
                f_out.write(f"{shifted_start_str} --> {shifted_end_str}\n")
            else:
                # If not a time range, write the line directly
                f_out.write(line)



# def convert_to_milliseconds(timestamp):
#     h, m, s_ms = timestamp.split(':')
#     s, ms = s_ms.split(',')
#     return int(h) * 3600000 + int(m) * 60000 + int(s) * 1000 + int(ms)

def convert_to_timestamp(milliseconds):
    ms = int(milliseconds)
    s, ms = divmod(ms, 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d}.{ms:03d}"

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
            # check in internal type of the audio file and fixup the extension if necessary
            # the fixup involves copying the audio file to /tmp with a new extension that
            # matches the internal type
            audio_type = get_audio_type(audio_file)
            if extension != f".{audio_type}":
                new_audio_file = f"{input_file_without_extension}.{audio_type}"
                print(f"Fixing audio file extension: {audio_file} to {new_audio_file}")
                os.system(f"cp {audio_file} {new_audio_file}")
                audio_file = new_audio_file
            break
        else:
            audio_file = None
    return audio_file

import ffmpeg

def extract_audio_segment(input_file, start_time, end_time, output_file):
    """Extracts a segment of audio from an input file without re-encoding.

    Args:
        input_file (str): Path to the input audio file.
        start_time (str): Start time in HH:MM:SS format.
        end_time (str): End time in HH:MM:SS format.
        output_file (str): Path to save the extracted segment.
    """

    try:
        (
            ffmpeg
            .input(input_file, ss=start_time, to=end_time)
            .output(output_file, c='copy')
            .run()
        )
        print(f"Audio segment successfully extracted to {output_file}")
    except ffmpeg.Error as e:
        print(f"Error extracting audio segment: {e.stderr}")



def format_time_offset(time_offset_str):
    h, m, s = time_offset_str.split(":")
    return f"{h}{m}{s}"
# Example usage is the same

# this function returns the internal type of the audio file
# some of the audio files aren't named properly, so we need to check the internal type
def get_audio_type(audio_file):
    # get the audio file type
    audio_file_info = ffmpeg.probe(audio_file)
    audio_type = audio_file_info['streams'][0]['codec_name']
    return audio_type



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Shift subtitle timings.")
    parser.add_argument("input_file", help="Input subtitle file (.srt or .vtt)")
    # parser.add_argument("output_file", help="Output subtitle file")
    parser.add_argument("time_offset", help="Time offset in HH:MM:SS format (e.g., 00:01:30)")
    parser.add_argument("-l","--audio_length", type=int, help="Audio length in seconds")

    args = parser.parse_args()

    # check that the environment variable PERE exists and is a writeable directory - otherwise exit
    if 'PERE' not in os.environ:
        print("PERE environment variable not set.")
        sys.exit(1)
    if not os.path.isdir(os.environ['PERE']):
        print("PERE directory does not exist.")
        sys.exit(1)

    # create a variable to hold the output directory name = PERE
    output_directory = os.environ['PERE']
    

    # call get_audio_file function to get the audio file name. If it returns a valid filename,
    # then continue, otherwise print an error and exit
    audio_file = get_audio_file(args.input_file)
    if audio_file is None:
        print("Could not find the related audio file.")
        sys.exit(1)
    # get the length of the audio file in milliseconds
    audio_file_info = ffmpeg.probe(audio_file)
    audio_duration = int(float(audio_file_info['format']['duration']) * 1000)
    #audio_duration = int(float(audio_file_info['format']['duration']))
    print(f"Audio File: {audio_file}  duration: {audio_duration} ms")
    # Calculate the time difference between the audio duration and the time_offset
    time_offset = convert_timestamp_to_milliseconds(args.time_offset)
    print(f"Time offset: {time_offset} ms")
    if args.audio_length:
        time_difference = time_offset + args.audio_length * 1000
        if time_difference > audio_duration:
            print("Cut length is greater than the audio duration.")
            sys.exit(1)
        else:
            print(f"Time difference: {time_difference} ms") 
            #prompt for yes or no to continue
            time_difference = convert_to_timestamp(time_difference)
            print(f'Time difference: {time_difference}')
            input("Press Enter to continue...")
    else:
        time_difference = audio_duration - time_offset
        print(f"Time difference: {time_difference} ms")
        # if the time difference is negative, print an error and exit
        if time_difference < 0:
            print("Time offset is greater than the audio duration.")
            sys.exit(1)

# extract the audio sections - destination is in /tmp/ with filename the same as the audio_file
    audio_output = f"{output_directory}/{os.path.basename(audio_file)}"
    print(f"Extracting audio file: {audio_file} from {args.time_offset} to {audio_output}")

    time_offset_formatted = format_time_offset(args.time_offset)
    cut_length_suffix = f"-cut{args.audio_length}" if args.audio_length else ""
    audio_output = f"{output_directory}/{os.path.basename(audio_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.{audio_file.rsplit('.', 1)[1]}"  
    #output_srt_file = f"{output_directory}/{os.path.basename(args.input_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.srt" 
    output_srt_file = f"{output_directory}/{os.path.basename(args.input_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.{args.input_file.rsplit('.', 1)[1]}"  
    print(f"Audio output file: {audio_output} output_srt file: {output_srt_file}")

    extract_audio_segment(audio_file, args.time_offset, time_difference, audio_output)

    # output_srt_file = f"{output_directory}/{os.path.basename(args.input_file)}"
    shift_subtitles(args.input_file, output_srt_file, args.time_offset)
    print(f"Shifted subtitle file: {output_srt_file}")
    
