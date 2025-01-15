import sqlite3
import re
import os
import sys


def check_env_variable():
  db_path = os.getenv("SUB_DB")
  if not db_path:
    print("Environment variable SUB_DB is not set.")
    sys.exit(1)
  if not os.path.isdir(db_path):
    print(f"The path {db_path} is not a directory.")
    sys.exit(1)
  if not os.access(db_path, os.W_OK):
    print(f"The directory {db_path} is not writable.")
    sys.exit(1)
  return db_path

def create_database(db_name="subtitles.db"):

  db_path = check_env_variable()
  db_name = os.path.join(db_path, "subtitles.db")

  if os.path.exists(db_name):
    response = input(f"The database {db_name} already exists. Do you want to overwrite it? (y/n): ")
    if response.lower() != 'y':
      print("Exiting without overwriting the database.")
      sys.exit(0)
  """
  Creates a SQLite database with a table to store subtitle data.
  """
  conn = sqlite3.connect(db_name)
  cursor = conn.cursor()

  cursor.execute("""
    CREATE TABLE IF NOT EXISTS subtitles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filename TEXT NOT NULL,
        media_file_type TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        text TEXT NOT NULL
    )
  """)
  conn.commit()
  conn.close()



def ingest_srt_file(filename, db_name="subtitles.db"):
  """
  Ingests an SRT file into the SQLite database.
  """
  db_path = check_env_variable()
  db_name = os.path.join(db_path, db_name)

  conn = sqlite3.connect(db_name)
  cursor = conn.cursor()

  with open(filename, 'r', encoding='utf-8') as f:
    lines = f.readlines()

  # Regular expression to parse SRT format
  pattern = r"(\d+)\n(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})\n(.*?)\n\n"

  matches = re.findall(pattern, "".join(lines), re.DOTALL)
  for match in matches:
    _, start_time, end_time, text = match
    cursor.execute("INSERT INTO subtitles (filename, start_time, end_time, text) VALUES (?, ?, ?, ?)",
                   (filename, start_time, end_time, text.strip()))

  conn.commit()
  conn.close()

def search_subtitles(query, db_name="subtitles.db"):
  """
  Searches the database for the given query and returns matching subtitles with their time offsets.
  """
  db_path = check_env_variable()
  db_name = os.path.join(db_path, db_name)
  conn = sqlite3.connect(db_name)
  cursor = conn.cursor()

  cursor.execute("SELECT filename, start_time, end_time FROM subtitles WHERE text LIKE ?", ('%' + query + '%',))
  results = cursor.fetchall()
  conn.close()
  return results

# Example usage
if __name__ == "__main__":
  create_database()
  ingest_srt_file("my_subtitles.srt")  # Replace with your SRT file

  search_term = "example"  # Replace with your search term
  results = search_subtitles(search_term)

  if results:
    for filename, start_time, end_time in results:
      print(f"Found '{search_term}' in {filename} at {start_time} to {end_time}")
  else:
    print(f"No results found for '{search_term}'")