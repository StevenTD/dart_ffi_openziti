# OpenZiti Flutter Integration via Dart FFI

## Overview

This project demonstrates how to use the **OpenZiti SDK** in a Flutter application by calling native OpenZiti functions through **Dart's Foreign Function Interface (FFI)**. The goal is to create a seamless integration between Flutter and OpenZiti, allowing you to leverage Ziti's secure network fabric in your Flutter applications, with the help of ChatGPT ofc.

## What is OpenZiti?

**OpenZiti** is a zero-trust networking platform that allows secure connectivity between services and devices. It enables you to create secure networks for your applications without relying on traditional **VPN** solutions.

## Status

- Add bin file for other platform like [OpenZiti Python SDK](https://github.com/openziti/ziti-sdk-py/blob/main/src/openziti/zitilib.py) **(Windows only for now)**
- **Unusable**
- Successfully **Enrolled with JWT**
- Connect using **Identity**
- Ziti console detects the identity as **online**

## Project Structure

- **`bin/`**: Entry point of the command-line application
- **`lib/`**: Library code for interfacing with OpenZiti SDK
- **`test/`**: Example unit tests for validating the functionality

## Setup and Installation

### Prerequisites

1. **Flutter SDK**: Ensure you have Flutter installed and set up for your project.
2. **OpenZiti SDK**: Download or compile the OpenZiti SDK from the official repository. The Dart code interfaces with the compiled C library.
3. **Dart FFI**: Knowledge of Dart’s FFI to create bindings for native libraries.

### Steps to Integrate OpenZiti with Flutter using Dart FFI

1. **Download OpenZiti SDK**

   - Clone the OpenZiti repository:
     `git clone https://github.com/openziti/ziti-sdk-c.git`
   - Compile the OpenZiti SDK into a shared library (`libziti.so` or `libziti.dylib` depending on your platform).

2. **Add FFI Dependencies**
   Add the `ffi` package to your **`pubspec.yaml`**:
   ```yaml
   dependencies:
     ffi: ^2.0.0
   ```
