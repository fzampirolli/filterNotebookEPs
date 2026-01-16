#!/bin/bash

echo "Starting environment setup..."

# Check for Python and Pip
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 not found. Please install Python 3 and pip."
    exit 1
fi

# Install gdown for downloading test cases
echo "Installing gdown..."
pip3 install --upgrade gdown

# Optional: Check for compilers (standard for UFABC's CS environment)
echo "Checking for compilers..."
for cmd in gcc g++ javac node Rscript; do
    if command -v $cmd &> /dev/null; then
        echo "✅ $cmd found."
    else
        echo "⚠️  $cmd not found (skip if you won't use this language)."
    fi
done

echo "Setup complete! You can now run the testsuite."