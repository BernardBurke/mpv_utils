import sqlite3
import os
import argparse
import re
import sys

# Define the progress reporting interval
PROGRESS_INTERVAL = 10000

def create_database():
    """Creates a new in-memory SQLite database and a table for storing EDL records."""
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE records (
            full_record TEXT NOT NULL
        )
    ''')
    conn.commit()
    return conn

def load_edls_to_db(input_dir):
    """
    Reads all .edl files in a directory and its subdirectories,
    and loads the valid records into the database.
    """
    conn = create_database()
    cursor = conn.cursor()

    print(f"Loading EDL records from '{input_dir}' into an in-memory database...")
    
    # Pattern to match 'file_path,start,length' lines
    pattern = re.compile(r"^\S+,[0-9]+,[0-9]+")
    
    record_count = 0
    
    for root, _, files in os.walk(input_dir):
        for filename in files:
            if filename.endswith('.edl'):
                filepath = os.path.join(root, filename)
                try:
                    with open(filepath, 'r') as f:
                        for line in f:
                            line = line.strip()
                            if pattern.match(line):
                                cursor.execute("INSERT INTO records (full_record) VALUES (?)", (line,))
                                record_count += 1
                                if record_count % PROGRESS_INTERVAL == 0:
                                    print(f"Loaded {record_count} records...")
                except IOError as e:
                    print(f"Warning: Could not read file {filepath} - {e}")
    
    conn.commit()
    print(f"Finished loading a total of {record_count} records.")
    return conn

def display_popular_records(conn, output_file=None):
    """
    Queries the database to find and display the most common records
    in descending order of count.
    """
    cursor = conn.cursor()
    
    # Redirect output if a file is specified
    if output_file:
        sys.stdout = open(output_file, 'w')

    print("Most popular records:")
    
    cursor.execute('''
        SELECT
            full_record,
            COUNT(full_record) AS count
        FROM
            records
        GROUP BY
            full_record
        ORDER BY
            count DESC;
    ''')

    for record, count in cursor.fetchall():
        print(f"{record},title={count}")
    
    # Restore stdout if it was redirected
    if output_file:
        sys.stdout.close()
        sys.stdout = sys.__stdout__
        print(f"Output written to {output_file}")


def main():
    """Main function to handle command-line arguments and script logic."""
    # Define a custom fallback order for the input directory
    default_input = os.getenv('EDL_INPUT') or os.getenv('HI') or os.path.expanduser('~')

    parser = argparse.ArgumentParser(description="Analyze mpv EDL files.")
    parser.add_argument('--input_dir', 
                        default=default_input,
                        help="Directory to scan for .edl files. Defaults to $EDL_INPUT, then $HI, then your home directory.")
    parser.add_argument('--output_file',
                        default=None,
                        help="Path to the output file. Defaults to stdout.")
    
    args = parser.parse_args()

    # The in-memory database is used, so no temporary directory is needed for a file.
    
    conn = load_edls_to_db(args.input_dir)
    display_popular_records(conn, args.output_file)
    conn.close()

if __name__ == '__main__':
    main()