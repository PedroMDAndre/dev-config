#  . $PROFILE
# https://decodeunicode.org/en/u+1F4C1
# notepad $PROFILE
# Test-Path $PROFILE
# New-Item -Path $PROFILE -ItemType File -Force

$branchIcon = [System.Char]::ConvertFromUtf32(127883)   # 🎋 
$arrowUp = [System.Char]::ConvertFromUtf32(128314)      # 🔺
$arrowDown = [System.Char]::ConvertFromUtf32(128315)    # 🔻
$greenCircle = [System.Char]::ConvertFromUtf32(128994)  #
$yellowCircle = [System.Char]::ConvertFromUtf32(128993) # 🟡
$redCircle = [System.Char]::ConvertFromUtf32(128992 )   # 🟠
$lightning = [System.Char]::ConvertFromUtf32(9889)      #
$dogEmoji = [System.Char]::ConvertFromUtf32(128054)     # 🐶
$folderEmoji = [System.Char]::ConvertFromUtf32(128194)  # 📂

# Colors (Escape sequences in PowerShell use double quotes)
$esc = [char]27                   # Escape character
$ResetColor = "$($esc)[0m"        # Reset color
$BGBlue = "$($esc)[48;5;27m"      # Background color (blue)
$BGLightGray = "$($esc)[48;5;8m"  # Background color (light gray)

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
  $MERGING = "$lightning"
  $UNTRACKED = "$redCircle"
  $MODIFIED = "$yellowCircle"
  $STAGED = "$greenCircle"

  # Initialize the FLAGS array
  $FLAGS = @()

  # Check for the Git directory and merge state
  $GIT_DIR = git rev-parse --git-dir 2>$null
  if ($GIT_DIR -and (Test-Path "$GIT_DIR\MERGE_HEAD")) {
    $FLAGS += $MERGING
  }

  # Check for untracked files
  $untrackedFiles = git ls-files --other --exclude-standard 2>$null
  if ($untrackedFiles) {
    $FLAGS += $UNTRACKED
  }

  # Check for modified files
  git diff --quiet 2>$null
  if ($LASTEXITCODE -ne 0) {
    $FLAGS += $MODIFIED
  }

  # Check for staged changes
  git diff --cached --quiet 2>$null
  if ($LASTEXITCODE -ne 0) {
    $FLAGS += $STAGED
  }

  if ($FLAGS.Count -ne 0) {
    $FLAGS += ""
  }

  return $FLAGS
}

function Test-GitRepository {
  $isInsideGitRepo = git rev-parse --is-inside-work-tree 2>&1
  return $isInsideGitRepo -eq 'true'
}

function prompt {
  $name = "Pedro"
  $directory = (Get-Location)

  $mainPrompt = "$BGBlue$dogEmoji $name | $folderEmoji $(Split-Path -Leaf $directory) $ResetColor"
  $endPrompt = "> "
  $promptStr = "$mainPrompt`n$endPrompt"
  $gitStatus = Get-GitStatus
  $gitDivergence = Get-GitDivergence
  if (Test-GitRepository) {
    $gitBranch = Get-GitBranch
    $promptStr = "$mainPrompt`n$BGLightGray$gitDivergence $branchIcon $gitBranch $gitStatus$ResetColor`n$endPrompt"  
  }
  return $promptStr
}