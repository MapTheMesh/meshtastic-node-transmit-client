import sys
import json

# Read input from stdin
input_data = sys.stdin.read()

# Split the input into lines
output = input_data.strip().split('\n')

# Process each line
for i, line in enumerate(output):
    line = line.lstrip('│').rstrip('│')
    output[i] = [value.strip() for value in line.split('│')]

# Extract headers
headers = output.pop(0)

# Combine each row with headers
output = [dict(zip(headers, row)) for row in output]

# Print the resulting JSON
print(json.dumps(output, separators=(',', ':')))
