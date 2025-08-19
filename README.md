# BanglaScript Compiler 🇧🇩

![Language](https://img.shields.io/badge/language-C++-blue.svg)
![Tools](https://img.shields.io/badge/tools-Flex%20&%20Bison-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A simple, bilingual compiler for a custom programming language that understands both English and Bangla keywords. This project was developed using Flex for lexical analysis and Bison for parsing, and it interprets the code by building and traversing an Abstract Syntax Tree (AST).

---

## ✨ Features

* **Bilingual Syntax**: Write code using either English (`let`, `if`, `while`) or Bangla (`ধরি`, `যদি`, `যতক্ষণ`) keywords.
* **Variable Support**: Declare variables and assign integer values.
* **User Input**: Take numerical input from the user.
* **Arithmetic Operations**: Supports `+`, `-`, `*`, `/`.
* **Control Flow**: Includes `if-else` conditionals and `while` loops.
* **Loop Control**: `break` statement to exit loops prematurely.
* **Cross-Platform**: Compiles and runs on both Windows (via MSYS2) and Linux (via WSL).

---

## 📝 Language Syntax

The compiler supports the following syntax:

| Feature              | English Syntax        | Bangla Syntax         | Example                               |
| -------------------- | --------------------- | --------------------- | ------------------------------------- |
| Variable Assignment  | `let`                 | `ধরি`                 | `ধরি my_var = 10;`                    |
| Print to Console     | `print`               | `দেখাও`                | `দেখাও "Hello, World!";`              |
| User Input           | `input`               | `ইনপুট`                | `ধরি num = ইনপুট;`                     |
| Conditional (If)     | `if { ... }`          | `যদি { ... }`          | `যদি x > 5 { দেখাও "Greater"; }`      |
| Conditional (Else)   | `else { ... }`        | `নতুবা { ... }`        | `... নতুবা { দেখাও "Not greater"; }`  |
| Loop (While)         | `while { ... }`       | `যতক্ষণ { ... }`       | `যতক্ষণ i < 5 { ... }`                |
| Break Loop           | `break`               | `বিরতি`                | `বিরতি;`                              |

---

## 🚀 Getting Started

### Prerequisites

You must have **Flex**, **Bison**, and a **C++ compiler** (like g++) installed.
* On **Windows**, it's recommended to use [MSYS2](https://www.msys2.org/) to get these tools.
* On **Linux (WSL/Ubuntu)**, you can install them with:
    ```bash
    sudo apt-get update
    sudo apt-get install flex bison g++
    ```

### Compilation & Usage

A build script is provided to automate the entire process.

#### On Linux (WSL) or MSYS2:

1.  **Make the script executable (only once):**
    ```bash
    chmod +x build.sh
    ```
2.  **Run the script:**
    ```bash
    # To compile and run a file named test.lang
    ./build.sh test.lang
    ```

#### On Windows (Command Prompt):

1.  **Ensure MSYS2 is in your PATH.** (See setup instructions for this).
2.  **Run the batch script:**
    ```cmd
    # To compile and run a file named test.lang
    build.bat test.lang
    ```

---

## 💻 Example Program

Here is an example program (`test.lang`) that showcases the language's features:


// --- বাংলা কম্পাইলারের সক্ষমতা পরীক্ষা ---

দেখাও "--- ভেরিয়েবল এবং ইনপুট পরীক্ষা ---";
দেখাও "একটি সংখ্যা ইনপুট দিন (1-20 এর মধ্যে):";
ধরি user_number = ইনপুট;

দেখাও "--- কন্ডিশনাল (যদি/নতুবা) পরীক্ষা ---";
যদি user_number > 20 {
দেখাও "সংখ্যাটি 20 এর চেয়ে বড়।";
}
নতুবা যদি user_number == 10 {
দেখাও "আপনি 10 ইনপুট দিয়েছেন।";
}
নতুবা {
দেখাও "আপনার দেওয়া সংখ্যাটি হলো:";
দেখাও user_number;
}

দেখাও "--- লুপ এবং ব্রেক পরীক্ষা ---";
দেখাও "একটি লুপ শুরু হচ্ছে যা 5 এ গিয়ে থেমে যাবে...";

ধরি counter = 0;
যতক্ষণ counter < 10 {
দেখাও counter;

যদি counter == 5 {
    দেখাও "বিরতি! লুপটি এখন থামবে।";
    বিরতি;
}

ধরি counter = counter + 1;

}

দেখাও "--- পরীক্ষা সফলভাবে সম্পন্ন হয়েছে ---";


---

## 🛠️ Tools Used

* **Flex**: For generating the lexical analyzer.
* **Bison**: For generating the parser.
* **g++**: For compiling the final C++ code.

