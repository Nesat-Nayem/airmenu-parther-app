$filePath = "lib/l10n/"
$fileName = "intl_en.arb"
$fileFullPath = "lib/l10n/intl_en.arb"

if (-Not (Test-Path -Path $fileFullPath -PathType Leaf)) {
    Write-Host "creating File $fileFullPath"
    # Create an empty file if it doesn't exist
    New-Item -Path $fileFullPath -ItemType File
} else {
    Write-Host "File $fileFullPath already exists. Skipping file creation."
}
 # Run the Ruby script
ruby merge_translations.rb

# Generate localization files using Flutter
flutter gen-l10n --template-arb-file=$fileName

# Generate localization code using intl_utils
dart run intl_utils:generate

# Add a print message
Write-Host "Script completed..."
Start-Sleep -Seconds 3