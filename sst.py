import sys
import re
import argparse
import ffmpeg
import os
import re

# Add the directory from the environment variable to the system path
module_path = os.environ.get('MPVU')
if module_path and os.path.isdir(module_path):
    sys.path.append(module_path)
else:
    print("MPVU environment variable not set or directory does not exist.")
    sys.exit(1)

# Now you can import the module
import media_file_helper



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


def convert_to_timestamp(milliseconds):
    ms = int(milliseconds)
    s, ms = divmod(ms, 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d}.{ms:03d}"



def format_time_offset(time_offset_str):
    h, m, s = time_offset_str.split(":")
    return f"{h}{m}{s}"




if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Shift subtitle timings.")
    parser.add_argument("input_file", help="Input subtitle file (.srt or .vtt)")
    # parser.add_argument("output_file", help="Output subtitle file")
    parser.add_argument("time_offset", help="Time offset in HH:MM:SS format (e.g., 00:01:30)")
    parser.add_argument("-l","--media_length", type=int, help="Media length in seconds")

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
    

    # if the input file is .vtt, use ffmpeg to convert it to .srt and save in the same directory as .vtt
    if args.input_file.endswith('.vtt'):
        output_srt_file = f"{os.path.splitext(args.input_file)[0]}.srt"
        print(f"Converting {args.input_file} to {output_srt_file}")
        try:
            (
                ffmpeg
                .input(args.input_file)
                .output(output_srt_file)
                .run()
            )
            print(f"Subtitle file successfully converted to {output_srt_file}")
        except ffmpeg.Error as e:
            print(f"Error converting subtitle file: {e.stderr}")
        args.input_file = output_srt_file
    # call get_media_file function to get the media file name. If it returns a valid filename,
    # then continue, otherwise print an error and exit
    media_file = media_file_helper.get_media_file(args.input_file)
    if media_file is None:
        print("Could not find the related media file.")
        sys.exit(1)
    # get the media file type from the filename
    media_file_type = os.path.splitext(media_file)[1]
    # call check_media_file_type to check the media file type and convert if necessary
    # only call check_media_file_type if the media file type is not video
    if media_file_type not in ['.mp4', '.mkv']:
        media_file = media_file_helper.check_media_file_type(media_file, media_file_type)
    # get the length of the media file in milliseconds
    media_file_info = ffmpeg.probe(media_file)
    media_duration = int(float(media_file_info['format']['duration']) * 1000)
    #media_duration = int(float(media_file_info['format']['duration']))
    print(f"media File: {media_file}  duration: {media_duration} ms")
    # Calculate the time difference between the media duration and the time_offset
    time_offset = media_file_helper.convert_timestamp_to_milliseconds(args.time_offset)
    print(f"Time offset: {time_offset} ms")
    if args.media_length:
        time_difference = time_offset + args.media_length * 1000
        if time_difference > media_duration:
            print("Cut length is greater than the media duration.")
            sys.exit(1)
        else:
            print(f"Time difference: {time_difference} ms") 
            #prompt for yes or no to continue
            time_difference = convert_to_timestamp(time_difference)
            print(f'Time difference: {time_difference}')
            #input("Press Enter to continue...")
    else:
        time_difference = media_duration - time_offset
        print(f"Time difference: {time_difference} ms")
        # if the time difference is negative, print an error and exit
        if time_difference < 0:
            print("Time offset is greater than the media duration.")
            sys.exit(1)

# extract the media sections - destination is in /tmp/ with filename the same as the media_file
    media_output = f"{output_directory}/{os.path.basename(media_file)}"
    print(f"Extracting media file: {media_file} from {args.time_offset} to {media_output}")

    time_offset_formatted = format_time_offset(args.time_offset)
    cut_length_suffix = f"-cut{args.media_length}" if args.media_length else ""
    media_output = f"{output_directory}/{os.path.basename(media_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.{media_file.rsplit('.', 1)[1]}"  
    #output_srt_file = f"{output_directory}/{os.path.basename(args.input_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.srt" 
    output_srt_file = f"{output_directory}/{os.path.basename(args.input_file).rsplit('.', 1)[0]}_{time_offset_formatted}{cut_length_suffix}.{args.input_file.rsplit('.', 1)[1]}"  
    print(f"media output file: {media_output} output_srt file: {output_srt_file}")

    media_file_helper.extract_media_segment(media_file, args.time_offset, time_difference, media_output)

    # output_srt_file = f"{output_directory}/{os.path.basename(args.input_file)}"
    shift_subtitles(args.input_file, output_srt_file, args.time_offset)
    print(f"Shifted subtitle file: {output_srt_file}")
    
