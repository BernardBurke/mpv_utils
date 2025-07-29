#!/usr/bin/env python3

import sys
import os

def interleave_files(input_files):
    """
    Interleaves lines from multiple input files.
    Ceases and exits normally when ANY input file reaches EOF during a read round,
    or when a maximum loop count is reached.

    The maximum loop count defaults to 1000 and can be overridden by
    the 'MAX_LOOP_COUNT' environment variable.

    Args:
        input_files: A list of file paths.

    Yields:
        Lines read from the input files in interleaved order.
    """
    # Define default max loop count
    DEFAULT_MAX_LOOP_COUNT = 300
    
    # Get max loop count from environment variable, if set
    try:
        max_loop_count = int(os.environ.get('MAX_LOOP_COUNT', DEFAULT_MAX_LOOP_COUNT))
        if max_loop_count <= 0:
            print("Warning: MAX_LOOP_COUNT environment variable must be a positive integer. Using default.", file=sys.stderr)
            max_loop_count = DEFAULT_MAX_LOOP_COUNT
    except ValueError:
        print("Warning: Invalid value for MAX_LOOP_COUNT environment variable. Using default.", file=sys.stderr)
        max_loop_count = DEFAULT_MAX_LOOP_COUNT

    file_handles = []
    current_round = 0 # Initialize a counter for the current interleaving round

    try:
        # Open all files
        for f_path in input_files:
            file_handles.append(open(f_path, 'r'))

        while True:
            # Check if the maximum loop count has been reached
            if current_round >= max_loop_count:
                print(f"Info: Reached maximum loop count ({max_loop_count}). Stopping interleaving.", file=sys.stderr)
                break # Exit the main while loop

            lines_in_this_round = []
            an_eof_was_hit = False

            # Read one line from each file
            for f_handle in file_handles:
                line = f_handle.readline().strip()

                if not line: # If a file returns an empty string, it's EOF
                    an_eof_was_hit = True
                    break # Stop reading from other files in this round and exit the inner loop

                lines_in_this_round.append(line)

            if an_eof_was_hit:
                break # Exit the main while loop, ending the generator

            # If we reached here, all files yielded a line in this round.
            # Yield all the lines collected in this round.
            for line in lines_in_this_round:
                yield line
            
            current_round += 1 # Increment the round counter after a successful round

    finally:
        # Ensure all opened file handles are closed
        for f_handle in file_handles:
            if not f_handle.closed:
                f_handle.close()

# The rest of your script (process_and_add_header and __main__ block) remains the same.
# For completeness, here's the full script again:

def process_and_add_header(input_files, output_file_path):
    """
    Interleaves the content and adds the EDL header if necessary.

    Args:
        input_files: A list of input file paths.
        output_file_path: The path to the output file.
    """
    is_edl_mode = all(f.lower().endswith(".edl") for f in input_files)

    if any(f.lower().endswith(".edl") for f in input_files) and not is_edl_mode:
        print("Error: If any input file is .edl, all input files must be .edl.", file=sys.stderr)
        sys.exit(1)

    with open(output_file_path, 'w') as outfile:
        if is_edl_mode:
            outfile.write("# mpv EDL v0\n")
        
        for line in interleave_files(input_files):
            outfile.write(line + '\n')

    print(f"Interleaved content written to: {output_file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: interleave.py output_file input_file1 input_file2 [input_file3 ...]", file=sys.stderr)
        sys.exit(1)

    output_file_path = sys.argv[1]
    input_file_paths = sys.argv[2:]

    process_and_add_header(input_file_paths, output_file_path)