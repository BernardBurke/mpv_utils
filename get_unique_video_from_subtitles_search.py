import os
import sys

def find_video_file(subtitle_path):
  """
  Finds the related video file for a given subtitle file.

  Args:
    subtitle_path: The full path to the subtitle file.

  Returns:
    The full path to the video file, or None if not found.
  """
  subtitle_dir, subtitle_filename = os.path.split(subtitle_path)
  subtitle_base, subtitle_ext = os.path.splitext(subtitle_filename)

  video_extensions = [".mp4", ".mkv", ".avi", ".webm"]
  for ext in video_extensions:
    video_filename = subtitle_base + ext
    video_path = os.path.join(subtitle_dir, video_filename)
    if os.path.exists(video_path):
      return video_path  # Return the full path here
  return None

def main():
  """
  Reads an input file containing subtitle file paths, removes duplicates,
  and finds the related video files.
  """
  if len(sys.argv) != 2:
    print("Usage: python script.py <input_file>")
    sys.exit(1)

  input_file = sys.argv[1]
  subtitle_files = set()

  with open(input_file, "r") as f:
    for line in f:
      try:
        subtitle_path = line.strip().split(":")[0]
        subtitle_files.add(subtitle_path)
      except IndexError:
        print(f"Warning: Skipping invalid line: {line.strip()}")

  for subtitle_path in subtitle_files:
    video_path = find_video_file(subtitle_path)
    if video_path:
      print(video_path)

if __name__ == "__main__":
  main()
