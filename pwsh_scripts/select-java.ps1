
function select-java([String]$VERSION) {
  $JDK = "TEMURIN_"+$VERSION+"_JDK"
  # check if jdk environment variable is set
  if (Test-Path Env:$JDK) {
    # set JAVA_HOME
    $NEW_JAVA_HOME = (Get-Item env:$JDK).Value
    # add $JAVA_HOME/bin to the path
    $PREVIOUS_PATH = $Env:Path
    if (Test-Path Env:$JAVA_HOME) {
      $PREVIOUS_JAVA_HOME = (Get-Item env:$JAVA_HOME).Value
      if ($PREVIOUS_PATH -contains $PREVIOUS_JAVA_HOME) {
        $NEW_PATH = $PREVIOUS_PATH.Replace($PREVIOUS_JAVA_HOME, $NEW_JAVA_HOME)
      } else {
        $NEW_PATH = $NEW_JAVA_HOME + "/bin;" +$PREVIOUS_PATH
      }
      # update PATH Env variable
      Set-Item -Path Env:PATH -Value $NEW_PATH
    }
    # update JAVA_HOME Env variable
    Set-Item -Path Env:JAVA_HOME -Value $NEW_JAVA_HOME
  }
}

select-java $args[0]
