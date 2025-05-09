#!/usr/bin/env python3

import sys
import os

def interleave_files(input_files):
    """
    Interleaves lines from multiple input files.

    Args:
        input_files: A list of file paths.

    Yields:
        Lines read from the input files in interleaved order.
    """
    file_handles = [open(f, 'r') for f in input_files]
    try:
        while True:
            lines = []
            has_data_in_this_round = False
            for f in file_handles:
                line = f.readline().strip()
                if line:
                    lines.append(line)
                    has_data_in_this_round = True
                else:
                    lines.append(None)

            if not has_data_in_this_round:
                break

            for line in lines:
                if line is not None:
                    yield line
    finally:
        for f in file_handles:
            if not f.closed:
                f.close()

def process_and_add_header(input_files, output_file_path):
    """
    Interleaves the content and adds the EDL header if necessary.

    Args:
        input_files: A list of input file paths.
        output_file_path: The path to the output file.
    """
    is_edl_mode = all(f.lower().endswith(".edl") for f in input_files)

    if any(f.lower().endswith(".edl") for f in input_files) and not is_edl_mode:
        print("Error: If any input file is .edl, all input files must be .edl.")
        sys.exit(1)

    interleaved_lines = list(interleave_files(input_files))

    with open(output_file_path, 'w') as outfile:
        if is_edl_mode:
            outfile.write("# mpv EDL v0\n")
        for line in interleaved_lines:
            outfile.write(line + '\n')

    print(f"Interleaved content written to: {output_file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: interleave.py output_file input_file1 input_file2 [input_file3 ...]")
        sys.exit(1)

    output_file_path = sys.argv[1]
    input_file_paths = sys.argv[2:]

    process_and_add_header(input_file_paths, output_file_path)