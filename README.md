# Rokomote: The Roku Remote in Linux Bash

Rokomote is a simple, lightweight Bash-based CLI tool that allows you to
control your Roku device from a Linux terminal. With features like
navigation, text input, volume control, and power management, Rokomote
transforms your terminal into a Roku remote.

## Description

Rokomote is Free and Open Source Software (FOSS), designed to be a
simple and accessible solution for Roku users. It scans your local
network for Roku devices, lets you select one, and provides intuitive
key mappings to control the device. It\'s ideal for Linux users who want
a quick, command-line alternative to a physical remote or mobile app.

## Notes

-   **Tested on an Acer C720 Chromebook:** This project was developed
    and tested using an Acer C720 Chromebook, so the default keyboard
    layout may not be optimal for your setup. If you don\'t like the
    layout, you can easily edit the Bash file to assign your preferred
    keys.
-   **In Development:** This project is still in development. If you
    encounter any bugs, please report them in the **Issues** section of
    the repository.
-   **Roku Compatibility:** This tool has only been tested with Roku
    TVs. If you find that it does not work with your Roku device, please
    report the issue.
-   **Contributions Welcome:** If you\'re able to fix issues or improve
    the tool, feel free to submit a pull request.

## Prerequisites

Before using Rokomote, ensure the following:

-   Your Roku device and Linux machine are on the same local network.
-   `curl` and `nmap` are installed on your system.
    - `sudo snap install curl && sudo apt install nmap`  
-   Your terminal supports raw input handling for keypress detection.

## How to Use Rokomote

1.  Clone the repository
  - `git clone https://github.com/jri-creator/rokomote.git`
  - `cd rokomote`
2.  Make the script executable
   - `chmod +x rokomote.sh`
3.  (Optional) Move the script to a directory in your `PATH` for easier
    use
    - `sudo mv rokomote.sh /usr/local/bin/rokomote`
    -    -    Now you can run the program simply by typing `rokomote` in any
        terminal.

4. Run the script

**Follow the prompts**

1.  -   Select the Roku device you wish to control.

    -   Use the following key mappings to control your Roku:

        -   **Arrow keys**: Navigation (Up, Down, Left, Right)
        -   **Backspace**: Home
        -   ****/****: OK (Select)
        -   ****. (Period)****: Backspace
        -   ****- (Minus)****: Volume Down
        -   ****= (Equals)****: Volume Up
        -   ****p****: Power on/off prompt
        -   ****' (Apostrophe)****: Text mode (type input and press Enter)
        -   ****, (Comma)****: Roku Options
        -   ****Esc****: Exit the script

2.  Enjoy controlling your Roku!

## Acknowledgments

Rokomote is Free and Open Source Software, developed with assistance
from [ChatGPT](https://openai.com/chatgpt). If you find this tool
helpful, consider starring the repository and sharing it with others.
