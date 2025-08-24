#!/bin/bash
# notify_lib.sh

notify() {
    # Display a notification message in different formats
    #
    # Usage:
    #   notify "MESSAGE" [FORMAT]
    #
    # Note: For multi-line messages, newlines and indentation will be preserved
    #   notify "Line 1
    #   Line 2" "heading"
    # Or use $'...' for escape sequences:
    #   notify $'Line 1\nLine 2' "heading"
    #
    # Parameters:
    #   MESSAGE - The notification text to display
    #   FORMAT  - Optional format (default: "oneline")
    #             Available formats:
    #               "oneline" - Simple wrapped message (default)
    #               "heading" - Highlighted heading style
    #               "success" - Green success message with checkmark
    #               "info"    - Informational message (blue, with "INFO:" prefix)
    #               "error"   - Error message (red, with "ERROR:" prefix)
    #
    # Examples:
    #   notify "Task completed"                   # Default oneline format
    #   notify $'Line 1\nLine 2' "heading"       # Multi-line heading
    #   notify "Operation succeeded" "success"    # Success format
    #   notify "This might take a while" "info"   # Info format
    #   notify "Process failed" "error"           # Error format
    #
    # Returns:
    #   0 - Success
    #   1 - Invalid format specified

    local message="$1"
    local format="${2:-oneline}"

    # Convert \n to actual newlines and preserve indentation
    message="${message//\\n/$'\n'}"

    case "$format" in
        oneline)
            echo -e "\n---> ${message//$'\n'/ }\n"
            ;;
        
        heading)
            local line="--------------------------------------------------------------"
            # Start with newline + separator
            echo -e "\n$line"
            # Add 2-space indent to each line (preserves empty lines)
            while IFS= read -r msg_line; do
                echo "  $msg_line"
            done <<< "$message"
            # End with separator + newline
            echo -e "$line\n"
            ;;
        success)
            echo -e "\n\033[32m✓ Success: ${message//$'\n'/$'\n✓ Success: '}\033[0m\n"
            ;;
        info)
            echo -e "\n\033[34mINFO: ${message//$'\n'/$'\nINFO: '}\033[0m\n"
            ;;
        error)
            echo -e "\n\033[31m✗ ERROR: ${message//$'\n'/$'\n✗ ERROR: '}\033[0m\n" >&2
            exit 1
            ;;
        warning)
            echo -e "\n\033[33m⚠ WARNING: ${message//$'\n'/$'\n⚠ WARNING: '}\033[0m\n" >&2
            ;;
        *)
            echo "Unknown format: $format" >&2
            return 1
            ;;
    esac
}