function prompt {
    #  . $PROFILE
    # https://decodeunicode.org/en/u+1F4C1
    # notepad $PROFILE
    # Test-Path $PROFILE
    # New-Item -Path $PROFILE -ItemType File -Force



    # Colors (Escape sequences in PowerShell use double quotes)
    $esc = [char]27  # Escape character
    $ResetColor = "$($esc)[0m"    # Reset color
    $BGBlue = "$($esc)[48;5;27m"  # Background color 003 (blue)
    $BGLightGray = "$($esc)[48;5;8m"  # Background color 008 (light gray)

    # Static elements
    $emoji = [System.Char]::ConvertFromUtf32(128054)
    $folderEmoji = [System.Char]::ConvertFromUtf32(128194)
    $name = "Pedro"
    $directory = (Get-Location)
    $gitBranch = $(git rev-parse --abbrev-ref HEAD 2>$null)  # Current Git branch (if in repo)

    # Build the prompt
    $promptLine1 = "$BGBlue $emoji $name > $folderEmoji $(Split-Path -Leaf $directory) $ResetColor"
    
    if ($gitBranch) {
        $promptLine2 = "$BGLightGray Git: $gitBranch $ResetColor"
    } else {
        $promptLine2 = ""
    }

    # Combine lines
    $prompt = "$promptLine1`n$promptLine2`n> "
    
    # Return the prompt to display
    return $prompt
}
