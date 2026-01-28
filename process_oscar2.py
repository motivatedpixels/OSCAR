#!/usr/bin/env python3

# Read the input file
with open('input/oscar.txt', 'r') as f:
    lines = f.readlines()

# Strip newlines from each line
lines = [line.rstrip('\n') for line in lines]

# Process lines
result = []
i = 0
while i < len(lines):
    current_line = lines[i]

    # Check if there's a next line
    if i < len(lines) - 1:
        next_line = lines[i + 1]

        # If next line starts with lowercase, join with space
        if next_line and next_line[0].islower():
            result.append(current_line + ' ')
        else:
            # Next line starts with uppercase or is empty, keep newline
            result.append(current_line + '\n')
    else:
        # Last line
        result.append(current_line)

    i += 1

# Write the output
with open('input/oscar.txt', 'w') as f:
    f.write(''.join(result))

print("Processing complete!")
print(f"Original lines: {len(lines)}")
