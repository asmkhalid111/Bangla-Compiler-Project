@echo off
REM A Windows Batch script to build and run the Bangla-Compiler-V3 project.

ECHO 1. Generating the lexer from compiler.l...
flex compiler.l
IF ERRORLEVEL 1 (
    ECHO Flex failed. Aborting.
    EXIT /B 1
)
ECHO    Lexer (lex.yy.c) generated successfully.

ECHO 2. Generating the parser from compiler.y...
bison -d compiler.y
IF ERRORLEVEL 1 (
    ECHO Bison failed. Aborting.
    EXIT /B 1
)
ECHO    Parser (compiler.tab.c and compiler.tab.h) generated successfully.

ECHO 3. Compiling the C++ source files...
g++ lex.yy.c compiler.tab.c -o compiler.exe
IF ERRORLEVEL 1 (
    ECHO G++ compilation failed. Aborting.
    EXIT /B 1
)
ECHO    Compiler (compiler.exe) created successfully.

REM Use the first argument as the input file, or default to "test.lang"
SET INPUT_FILE=%1
IF "%INPUT_FILE%"=="" SET INPUT_FILE=test.lang

IF NOT EXIST "%INPUT_FILE%" (
    ECHO Error: Input file '%INPUT_FILE%' not found. Aborting run.
    EXIT /B 1
)

ECHO 4. Running compiler with input file: %INPUT_FILE%
ECHO ------------------------------------------
compiler.exe %INPUT_FILE%
ECHO ------------------------------------------
ECHO Script finished.
