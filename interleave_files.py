#!/usr/bin/env python3

import sys
import itertools

def interleave_files(input_files):
    """
    Interleaves lines from multiple input files, stopping as soon as any file
    reaches the end.

    Args:
        input_files: A list of file paths.

    Yields:
        Lines read from the input files in interleaved order.
    """
    file_handles = [open(f, 'r') for f in input_files]
    try:
        while True:
            lines = []
            all_files_have_data = True
            for f in file_handles:
                line = f.readline().strip()
                if line:
                    lines.append(line)
                else:
                    all_files_have_data = False
                    break  # Exit the inner loop as soon as one file is EOF

            if not all_files_have_data:
                break  # Exit the outer loop if any file reached EOF

            yield from lines  # Yield the lines read in this round
    finally:
        for f in file_handles:
            f.close()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: interleave.py output_file input_file1 input_file2 [input_file3 ...]")
        sys.exit(1)

    output_file_path = sys.argv[1]
    input_file_paths = sys.argv[2:]

    with open(output_file_path, 'w') as outfile:
        for line in interleave_files(input_file_paths):
            outfile.write(line + '\n')

    print(f"Interleaved content written to: {output_file_path}")
