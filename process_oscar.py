#!/usr/bin/env python3
import re

# Read the input file
with open('input/oscar.txt', 'r') as f:
    content = f.read()

# Common English words to help split concatenated text
# Using a comprehensive word list approach
def split_concatenated_words(text):
    # Load a basic word list (common English words)
    # This is a simple approach - looking for lowercase word boundaries

    result = []
    i = 0

    # Process character by character
    while i < len(text):
        char = text[i]

        # If we find a lowercase letter followed by an uppercase letter,
        # that's likely a word boundary
        if i < len(text) - 1:
            next_char = text[i + 1]

            # Lowercase followed by uppercase = word boundary
            if char.islower() and next_char.isupper():
                result.append(char)
                result.append('\n')
                i += 1
                continue

        result.append(char)
        i += 1

    return ''.join(result)

# Process the text
processed = split_concatenated_words(content)

# Write the output
with open('input/oscar.txt', 'w') as f:
    f.write(processed)

print("Processing complete!")
print(f"Original length: {len(content)}")
print(f"Processed length: {len(processed)}")
