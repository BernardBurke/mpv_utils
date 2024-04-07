import sys

# This python script will read an edl file and validate it.
# The file name is provided in the first parameter
# The script will read the file and validate the filename, the start time and length

# this function checks that there are exactly 2 commas in a record
def check_commas(record):
    if record.count(',') == 2:
        print(f'Valid number of commas in record: {record} {record.count(",")}')
        return True
    else:
        print(f'Invalid number of commas in record: {record} {record.count(",")}')
        return False  
    
def validate_edl_file(file_name):
    # Validate the filename
    if not file_name.endswith('.edl'):
        print("Invalid file format. Only .edl files are supported.")
        return False
    
    # Read the file
    try:
        with open(file_name, 'r') as file:
            # Validate the start time and length for each entry in the EDL file
            for line in file:
            # Skip lines starting with #
                if line.startswith('#'):
                    continue
                if  line.count(',') != 2:
                    comma_count = line.count(',')
                    print(f'Invalid entry format: {comma_count} commas found in record: {line}')
                    continue
                entry = line.strip().split(',')
                fname, start_time, length = entry[0], entry[1], entry[2]
                # check that fname is file name that exists on the  file system
                try:
                    with open(fname, 'r') as f:
                        print(line, end='')
                except FileNotFoundError:
                    print(f'File {fname} does not exist')
            # Perform further validation on start_time and length if needed
            
    except FileNotFoundError:
        print("File not found:", file_name)
        return False
    
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python validate.py <edl_file>")
        sys.exit(1)
    
    edl_file = sys.argv[1]
    validate_edl_file(edl_file)
