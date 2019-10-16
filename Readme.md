# Understand

This is an empty AVR project template. It does nothing but could be developed to become a great thing :)
This template assumes that you are using GNU AVR compiller.


# Start

```
git clone https://github.com/specadmin/avr-project
mv avr-project your_project_name
cd your_project_name
git submodule update --init
```

# Develop

Use Code::Blocks or any other IDE for development.


# Compile

```
make
```
See Makefile for details


# Upload 

You may use the following command for uploading a compilled firmware to your AVR device. It uses **avrdude** for uploading.

```
make install
```
See Makefile for details
