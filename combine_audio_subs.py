import os
import glob
import ffmpeg

def combine_audio_with_subtitles(wildcard_pattern, output_filename="combined_output.mkv"):
    """Combines audio files matching the wildcard pattern, including subtitles."""

    audio_files = glob.glob(wildcard_pattern)

    if not audio_files:
        print("No audio files found matching the pattern.")
        return

    # Build FFmpeg input streams
    inputs = []
    for audio_file in audio_files:
        base_name = os.path.splitext(audio_file)[0]
        subtitle_files = glob.glob(f"{base_name}.[sv]tt")

        audio_stream = ffmpeg.input(audio_file)
        inputs.append(audio_stream) 
        if subtitle_files:
            subtitle_stream = ffmpeg.input(subtitle_files[0])
            inputs.append(subtitle_stream)

    # Concatenate audio and subtitle streams
    joined = ffmpeg.concat(*inputs, v=0, a=1)  

    # Re-encode to allow for copying subtitles
    joined = joined.output(output_filename, scodec="mov_text") 

    joined.run() 

    print(f"Combined audio and subtitles saved to {output_filename}")

# Example usage
if __name__ == "__main__":
    wildcard_pattern = input("Enter wildcard pattern for audio files (e.g., *.mp3): ")
    combine_audio_with_subtitles(wildcard_pattern)
