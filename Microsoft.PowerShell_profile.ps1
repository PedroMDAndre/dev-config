#  . $PROFILE
# https://decodeunicode.org/en/u+1F4C1
# notepad $PROFILE
# Test-Path $PROFILE
# New-Item -Path $PROFILE -ItemType File -Force

$branchIcon = [System.Char]::ConvertFromUtf32(127883)
$arrowUp = [System.Char]::ConvertFromUtf32(128314)
$arrowDown = [System.Char]::ConvertFromUtf32(128315)
$greenCircle = [System.Char]::ConvertFromUtf32(128994)
$yellowCircle = [System.Char]::ConvertFromUtf32(128993)
$redCircle = [System.Char]::ConvertFromUtf32(128992 )
$lightning = [System.Char]::ConvertFromUtf32(9889)
$dogEmoji = [System.Char]::ConvertFromUtf32(128054)  # Dog emoji
$folderEmoji = [System.Char]::ConvertFromUtf32(128194)  # Folder emoji

# Colors (Escape sequences in PowerShell use double quotes)
$esc = [char]27  # Escape character
$ResetColor = "$($esc)[0m"    # Reset color
$BGBlue = "$($esc)[48;5;27m"  # Background color 003 (blue)
$BGLightGray = "$($esc)[48;5;8m"  # Background color 008 (light gray)

function Get-GitBranch {
  if (Test-Path .git) {
    $gitStatus = git rev-parse --abbrev-ref HEAD 2>$null
    if ($gitStatus -eq 'HEAD') {
      return (git describe --tags --always)
    }
    elseif ($gitStatus) {
      return $gitStatus
    }
    else {
      return (git describe --tags --always)
    }
  }
}

function Get-GitDivergence {
  $upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  
  $numAhead = (git rev-list --count "$upstream..HEAD" 2>$null)
  if (-not $numAhead) { $numAhead = 0 }
  
  $numBehind = (git rev-list --count "HEAD..$upstream" 2>$null)
  if (-not $numBehind) { $numBehind = 0 }
  
  $divergence = @()
  $divergence += "$arrowUp $numAhead"
  $divergence += "$arrowDown $numBehind"

  return $divergence
}

function Get-GitStatus {
  try {
    # Initialize the status flags and branch information
    $gitStatus = git status --porcelain 2>$null
    $statusFlags = ""

    # Check for untracked files
    if ($gitStatus -match "^\?\?") {
      $statusFlags += " $redCircle"  # Untracked files
    }

    # Check for changes not staged for commit (modified files)
    if ($gitStatus -match "^\s*M") {
      $statusFlags += " $yellowCircle"  # Modified files
    }

    # Check for changes staged for commit
    if ($gitStatus -match "^\s*A|\s*D|\s*M|\s*R") {
      $statusFlags += " $greenCircle"  # Staged files
    }

    # Check if we're in a merge state (i.e., MERGE_HEAD exists)
    $mergeHeadPath = Join-Path (git rev-parse --git-dir) "MERGE_HEAD"
    if (Test-Path $mergeHeadPath) {
      $statusFlags += " ligthning"  # Merge state
    }

    return $statusFlags
  }
  catch {
    return "Error checking Git status: $_"
  }
}

function Test-GitRepository {
  $isInsideGitRepo = git rev-parse --is-inside-work-tree 2>&1
  return $isInsideGitRepo -eq 'true'
}

function prompt {
  $name = "Pedro"
  $directory = (Get-Location)

  $mainPrompt = "$BGBlue$dogEmoji $name > $folderEmoji $(Split-Path -Leaf $directory) $ResetColor"
  $endPrompt = "> "
  $promptStr = "$mainPrompt`n$endPrompt"
  $gitStatus = Get-GitStatus
  $gitDivergence = Get-GitDivergence
  if (Test-GitRepository) {
    $gitBranch = Get-GitBranch
    $promptStr = "$mainPrompt`n$BGLightGray$gitDivergence $gitStatus $branchIcon $gitBranch$BGLightGray$ResetColor`n$endPrompt"  
  }
  return $promptStr
}