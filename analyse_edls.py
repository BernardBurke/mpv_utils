import sqlite3
import os
import argparse
import re
import sys
from contextlib import contextmanager

# Define the progress reporting interval
PROGRESS_INTERVAL = 10000

# --- Database Management ---

def connect_db(db_path=":memory:"):
    """Creates a connection to the SQLite database."""
    print(f"Connecting to database: {'in-memory' if db_path == ':memory:' else db_path}")
    return sqlite3.connect(db_path)

def create_edl_table(cursor):
    """Creates the table for storing EDL records if it doesn't exist."""
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS edl_records (
            id INTEGER PRIMARY KEY,
            full_record TEXT NOT NULL,
            filepath TEXT NOT NULL
        )
    ''')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_full_record ON edl_records (full_record);')

# --- File Processing ---

def find_files(root_dir, extension):
    """Generator that finds and yields all files with a given extension."""
    for root, _, files in os.walk(root_dir):
        for filename in files:
            if filename.endswith(extension):
                yield os.path.join(root, filename)

def load_edls_to_db(conn, input_dir):
    """
    Reads all .edl files in a directory and its subdirectories,
    and loads the valid records into the database.
    """
    cursor = conn.cursor()
    create_edl_table(cursor)

    print(f"Loading EDL records from '{input_dir}'...")
    
    # Pattern to match 'file_path,start,length' lines
    pattern = re.compile(r"^\S+,[0-9\.]+,[0-9\.]+")
    
    record_count = 0
    
    for filepath in find_files(input_dir, '.edl'):
        try:
            with open(filepath, 'r', errors='ignore') as f:
                for line in f:
                    line = line.strip()
                    if pattern.match(line):
                        cursor.execute("INSERT INTO edl_records (full_record, filepath) VALUES (?, ?)", (line, filepath))
                        record_count += 1
                        if record_count % PROGRESS_INTERVAL == 0:
                            print(f"Loaded {record_count} records...")
        except IOError as e:
            print(f"Warning: Could not read file {filepath} - {e}", file=sys.stderr)
    
    conn.commit()
    print(f"Finished loading a total of {record_count} records.")

# --- Analysis & Output ---

@contextmanager
def smart_open(filename=None):
    """Context manager to handle writing to stdout or a file."""
    if filename and filename != '-':
        fh = open(filename, 'w')
    else:
        fh = sys.stdout

    try:
        yield fh
    finally:
        if fh is not sys.stdout:
            fh.close()

def display_popular_records(conn, output_file=None):
    """
    Queries the database to find and display the most common records
    in descending order of count.
    """
    cursor = conn.cursor()
    
    query = '''
        SELECT
            full_record,
            COUNT(full_record) AS count
        FROM
            edl_records
        GROUP BY
            full_record
        ORDER BY
            count DESC;
    '''
    
    with smart_open(output_file) as f:
        f.write("Most popular records:\n")
        try:
            cursor.execute(query)
            for record, count in cursor.fetchall():
                f.write(f"{record},title={count}\n")
        except sqlite3.OperationalError as e:
            print(f"Error running query: {e}. The table might not exist or be empty.", file=sys.stderr)

    if output_file and output_file != '-':
        print(f"Output written to {output_file}")

# --- Main ---

def main():
    """Main function to handle command-line arguments and script logic."""
    # Define a custom fallback order for the input directory
    default_input = os.getenv('EDL_INPUT') or os.getenv('HI') or os.path.expanduser('~')

    parser = argparse.ArgumentParser(
        description="Analyze media files and metadata from your library.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        '--input_dir', 
        default=default_input,
        help="Directory to scan for files. \nDefaults to $EDL_INPUT, then $HI, then home dir."
    )
    parser.add_argument(
        '--db_file',
        default=":memory:",
        help="Path to the SQLite database file. \nDefaults to an in-memory database."
    )
    parser.add_argument(
        '--output_file',
        default=None,
        help="Path to the output file. Defaults to stdout."
    )
    
    args = parser.parse_args()
    
    conn = connect_db(args.db_file)
    try:
        # For now, we only have one mode, but this is where you'd add more.
        load_edls_to_db(conn, args.input_dir)
        display_popular_records(conn, args.output_file)
    finally:
        conn.close()
        print("Database connection closed.")

if __name__ == '__main__':
    main()