#!/bin/bash

# A script to build and run the Bangla-Compiler-V3 project.

# --- Color Codes for Output ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Step 1: Generate the Lexer ---
echo "1. Generating the lexer from compiler.l..."
flex compiler.l
if [ $? -ne 0 ]; then
    echo -e "${RED}Flex failed. Aborting.${NC}"
    exit 1
fi
echo -e "${GREEN}   Lexer (lex.yy.c) generated successfully.${NC}"

# --- Step 2: Generate the Parser ---
echo "2. Generating the parser from compiler.y..."
bison -d compiler.y
if [ $? -ne 0 ]; then
    echo -e "${RED}Bison failed. Aborting.${NC}"
    exit 1
fi
echo -e "${GREEN}   Parser (compiler.tab.c and compiler.tab.h) generated successfully.${NC}"

# --- Step 3: Compile the C++ Code ---
echo "3. Compiling the C++ source files..."
g++ lex.yy.c compiler.tab.c -o compiler.exe
if [ $? -ne 0 ]; then
    echo -e "${RED}G++ compilation failed. Aborting.${NC}"
    exit 1
fi
echo -e "${GREEN}   Compiler (compiler.exe) created successfully.${NC}"

# --- Step 4: Run the Compiler ---
# Use the first argument as the input file, or default to "test.lang"
INPUT_FILE=${1:-test.lang}

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: Input file '$INPUT_FILE' not found. Aborting run.${NC}"
    exit 1
fi

echo "4. Running compiler with input file: $INPUT_FILE"
echo "------------------------------------------"
./compiler.exe "$INPUT_FILE"
echo "------------------------------------------"
echo -e "${GREEN}Script finished.${NC}"
