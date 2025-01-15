# main.py
import subtitles_helper

if __name__ == "__main__":
  subtitles_helper.create_database()
  subtitles_helper.ingest_srt_file("my_subtitles.srt")  # Replace with your SRT file

  search_term = "example"  # Replace with your search term
  results = subtitles_helper.search_subtitles(search_term)

  if results:
    for filename, start_time, end_time in results:
      print(f"Found '{search_term}' in {filename} at {start_time} to {end_time}")
  else:
    print(f"No results found for '{search_term}'")


  # Example query to find subtitles containing the word "hello" in any case
  results = subtitles_helper.search_subtitles("hello")

  if results:
    for filename, start_time, end_time in results:
      print(f"Found 'hello' in {filename} at {start_time} to {end_time}")
  else:
    print("No results found for 'hello'")