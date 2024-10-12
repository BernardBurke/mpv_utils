# this script reals an MPV EDL file and an associated subtitle file and creates a new EDL file based on the subtitles timing.
# This means... the offset and length of each event in the EDL file will be replaced by the timing of the subtitles.
# The subtitles file must be in the SRT format.


import re

def parse_edl(edl_file):
    """Parses an MPV EDL file and returns a list of filenames."""
    filenames = []
    with open(edl_file, 'r') as f:
        for line in f:
            if not line.startswith('#'):  # Skip header line
                filename = line.split(',')[0].strip()
                filenames.append(filename)
    return filenames

def parse_srt(srt_file):
    """Parses an SRT subtitle file and returns a list of subtitle timings."""
    timings = []
    with open(srt_file, 'r') as f:
        for line in f:
            match = re.match(r'^(\d+:\d+:\d+,\d+) --> (\d+:\d+:\d+,\d+)$', line)
            if match:
                start_time = convert_srt_time_to_milliseconds(match.group(1)) // 1000  # Convert to seconds
                end_time = convert_srt_time_to_milliseconds(match.group(2)) // 1000
                timings.append((start_time, end_time - start_time))  # Store start time and duration
    return timings

def convert_srt_time_to_milliseconds(srt_time):
    """Converts an SRT timestamp (HH:MM:SS,mmm) to milliseconds."""
    h, m, s, ms = map(int, re.split(r'[:,]' , srt_time))
    return (h * 3600 + m * 60 + s) * 1000 + ms

def create_new_edl(filenames, timings, output_edl_file):
    """Creates a new EDL file with chapter markers based on subtitle timings."""
    with open(output_edl_file, 'w') as f:
        f.write("# mpv EDL v0\n")  # Write EDL header
        for i, filename in enumerate(filenames):
            if i < len(timings):
                start_time, duration = timings[i]
                f.write(f"{filename},{start_time},{duration}\n")

if __name__ == "__main__":
    edl_file = input("Enter the path to the MPV EDL file: ").strip()
    srt_file = input("Enter the path to the SRT subtitle file: ").strip()
    output_edl_file = input("Enter the desired path for the new EDL file: ").strip()

    filenames = parse_edl(edl_file)
    timings = parse_srt(srt_file)

    create_new_edl(filenames, timings, output_edl_file)

    print("New EDL file with chapter markers created successfully!")