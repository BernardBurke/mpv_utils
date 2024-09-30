import os

try:
    import ffmpeg
except ImportError:
    ffmpeg = None

# This function takes a timestamp in HH:MM:SS format and converts it to milliseconds
def convert_timestamp_to_milliseconds(timestamp_str):
    parts = timestamp_str.split(':')
    if len(parts) == 3:  # Format: HH:MM:SS
        h, m, s = map(int, parts)
        return h * 3600000 + m * 60000 + s * 1000
    else:
        raise ValueError("Invalid timestamp format. Use HH:MM:SS")



# This function takes the .srt/vtt file and finds the related media file in the same directory
def get_media_file(input_file):
    print(f"Input file: {input_file}")
    media_file = None
    # Look for a related media file in the same directory as the input file
    # File types can be media or video (mp3, m4a, wav, flac, ogg, opus, webm, mp4, mkv, avi, etc.)
    # For example, if the input file is "subtitle.srt", the media file would be "subtitle.mp3" if the 
    # mp3 file exists (or m4a if the m4a file exists, etc.)
    # So, take the input file, remove the extension and try each media file extension
    # and check if that file exists.
    # If the media file is found, return the media file name. If not found, return None.
    input_file_without_extension = os.path.splitext(input_file)[0]
    input_file_directory = os.path.dirname(input_file)
    # List of media file extensions
    media_file_extensions = [".mp3", ".m4a", ".wav", ".flac", ".ogg", ".opus", ".webm", ".mp4", ".mkv", ".avi"]
    for extension in media_file_extensions:
        media_file = f"{input_file_without_extension}{extension}"
        if os.path.exists(media_file):
            break
        else:
            media_file = None
    return media_file

def extract_media_segment(input_file, start_time, end_time, output_file):
    """Extracts a segment of media (audio or video) from an input file without re-encoding.

    Args:
        input_file (str): Path to the input media file.
        start_time (str): Start time in HH:MM:SS format or seconds (int).
        end_time (str): End time in HH:MM:SS format or duration in seconds (int).
        output_file (str): Path to save the extracted segment.
    """

    # If end_time is an integer, assume it's a duration and calculate the actual end time
    if isinstance(end_time, int):
        input_duration = float(ffmpeg.probe(input_file)['format']['duration'])
        end_time = str(input_duration - (int(start_time) if isinstance(start_time, int) else convert_timestamp_to_milliseconds(start_time) / 1000))

    try:
        (
            ffmpeg
            .input(input_file, ss=start_time, to=end_time)
            .output(output_file, c='copy')
            .run()
        )
        print(f"Media segment successfully extracted to {output_file}")
    except ffmpeg.Error as e:
        print(f"Error extracting media segment: {e.stderr}")

def get_audio_type(audio_file):
    """Gets the internal codec name of the audio file."""
    audio_file_info = ffmpeg.probe(audio_file)
    return audio_file_info['streams'][0]['codec_name']

def check_media_file_type(media_file, expected_type):
    """Checks if the media file type matches the expected type and converts it if necessary."""
    audio_type = get_audio_type(media_file)
    print(f"Audio type: {audio_type} for {expected_type}")
    if audio_type != expected_type.lstrip('.'):  # Remove leading dot from expected_type
        output_media_file = f"/tmp/{os.path.basename(media_file).rsplit('.', 1)[0]}.{audio_type}"
        print(f"Converting {media_file} to {output_media_file}")
        try:
            (
                ffmpeg
                .input(media_file)
                .output(output_media_file, c='copy')
                .run()
            )
            print(f"Media file successfully converted to {output_media_file}")
        except ffmpeg.Error as e:
            print(f"Error converting media file: {e.stderr}")
        return output_media_file
    else:
        return media_file

