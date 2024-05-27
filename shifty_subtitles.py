import sys
import re
import argparse
import ffmpeg
import os

print(f'This is not in use - please use the non shify version')
sys.exit(1)

def shift_subtitles(input_file, output_file, time_offset_str, cut_length_ms=None):
    """Shifts subtitles in an SRT file based on a time offset, optionally trimming.

    Args:
        input_file (str): Path to the input SRT file.
        output_file (str): Path to save the shifted subtitles.
        time_offset_str (str): Time offset in HH:MM:SS format.
        cut_length_ms (int, optional): Cut length in milliseconds. If None, the entire rest of the subtitle is included.
    """

    def time_str_to_ms(time_str):
        # allow for the case where the time_str has milliseconds after a comma eg 00:15:20,121
        parts = time_str.split(':')
        if ',' in parts[2]:
            s, ms = parts[2].split(',')
        else:
            s = parts[2]
            ms = 0
        h, m, s = map(int, [parts[0], parts[1], s])
        ms = int(ms)
        return h * 3600000 + m * 60000 + s * 1000 + ms

    time_offset_ms = time_str_to_ms(time_offset_str)

    with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
        for line in f_in:
            if "-->" in line:
                start_time, end_time = line.strip().split(" --> ")

                start_ms = time_str_to_ms(start_time)
                end_ms = time_str_to_ms(end_time)

                shifted_start = max(0, start_ms - time_offset_ms)
                shifted_end = max(0, end_ms - time_offset_ms)
                print(f'shifted_start: {shifted_start}, shifted_end: {shifted_end}, cut_length_ms: {cut_length_ms}')
                if cut_length_ms is not None and shifted_end > cut_length_ms:
                    continue  # Skip this subtitle if it goes beyond the cut length

                shifted_start_str = f"{shifted_start // 3600000:02d}:{(shifted_start % 3600000) // 60000:02d}:{(shifted_start % 60000) // 1000:02d}"
                shifted_end_str = f"{shifted_end // 3600000:02d}:{(shifted_end % 3600000) // 60000:02d}:{(shifted_end % 60000) // 1000:02d}"

                f_out.write(f"{shifted_start_str} --> {shifted_end_str}\n")
            else:
                f_out.write(line)

def format_time_offset(time_offset_str):
    h, m, s = time_offset_str.split(":")
    return f"{h}{m}{s}"


def get_audio_file(input_file):
    input_file_without_extension = input_file.replace(".srt", "").replace(".vtt", "")
    input_file_directory = os.path.dirname(input_file)
    audio_file_extensions = [".mp3", ".m4a", ".wav", ".flac", ".ogg", ".opus", ".webm", ".mp4", ".mkv"]
    for extension in audio_file_extensions:
        audio_file = f"{input_file_without_extension}{extension}"
        if os.path.exists(audio_file):
            break
        else:
            audio_file = None
    return audio_file


def extract_audio_segment(input_file, start_time, end_time, output_file):
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


def convert_timestamp_to_milliseconds(timestamp_str):
    parts = timestamp_str.split(':')
    if len(parts) == 3:
        h, m, s = map(int, parts)
        return h * 3600000 + m * 60000 + s * 1000
    else:
        raise ValueError("Invalid timestamp format. Use HH:MM:SS")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Shift and cut subtitle timings.")
    parser.add_argument("input_file", help="Input subtitle file (.srt or .vtt)")
    parser.add_argument("time_offset", help="Time offset in HH:MM:SS format (e.g., 00:01:30)")
    parser.add_argument("-l", "--cut_length", type=int, help="Cut length in seconds (optional)") 

    args = parser.parse_args()

    if 'PERE' not in os.environ:
        print("PERE environment variable not set.")
        sys.exit(1)
    if not os.path.isdir(os.environ['PERE']):
        print("PERE directory does not exist.")
        sys.exit(1)

    output_directory = os.environ['PERE']

    audio_file = get_audio_file(args.input_file)
    if audio_file is None:
        print("Could not find the related audio file.")
        sys.exit(1)

    audio_file_info = ffmpeg.probe(audio_file)
    audio_duration = int(float(audio_file_info['format']['duration']) * 1000)
    time_offset = convert_timestamp_to_milliseconds(args.time_offset)
    # if cut_length is provided, calculate the time_difference as time_offset + cut_length.
    # check that the time difference is not greater than the audio duration. If it is, print an error and exit.
    if args.cut_length:
        time_difference = time_offset + args.cut_length * 1000
        if time_difference > audio_duration:
            print("Time offset + cut length is greater than the audio duration.")
            sys.exit(1)
    else:
        time_difference = audio_duration - time_offset



    if time_difference < 0:
        print("Time offset is greater than the audio duration.")
        sys.exit(1)
    
    time_offset_formatted = format_time_offset(args.time_offset)
    cut_length_suffix = f"-cut{args.cut_length}" if args.cut_length else ""
    audio_output = f"{output_directory}/{os.path.basename(audio_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.{audio_file.rsplit('.', 1)[1]}"  
    output_srt_file = f"{output_directory}/{os.path.basename(args.input_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.srt" 

    cut_length_ms = args.cut_length * 1000 if args.cut_length else None
    print(f'Cut length in milliseconds: {cut_length_ms} ms and time difference: {time_difference} ms') 
    # Pause waiting on a Y to continue
    input("Press Enter to continue...")
    shift_subtitles(args.input_file, output_srt_file, args.time_offset, cut_length_ms)

    extract_audio_segment(audio_file, args.time_offset, time_difference, audio_output)
