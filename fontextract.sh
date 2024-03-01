# fontextract by dieselbaby
# github.com/dieselbabyy/fontextract

#!/bin/bash

# Function to extract font files from zip files
extract_fonts_from_zips() {
  local destination_dir="extracted-$(date +%Y-%m-%d-%H%M)"
  local keep_zips=false

  # Process command-line arguments
  while getopts ":s:d:k" opt; do
    case $opt in
      s) source_dir=$OPTARG ;;
      d) destination_dir=$OPTARG ;;
      k) keep_zips=true ;;
      \?) echo "Sorry amigo.  Invalid option: -$OPTARG" >&2 ;;
    esac
  done

  # Create the destination directory for our extraction if it doesn't exist yet
  mkdir -p "$destination_dir"

  # Loop through each .zip file in the source directory
  for file in "$source_dir"/*.zip; do
    # Extract the contents of the .zip files out to the destination directory
    unzip -qq "$file" -d "$destination_dir"
  done

  # Remove all files except .ttf, .otf, and .woff files from the destination directory - you can edit this for other types of files if you like
  find "$destination_dir" ! -name "*.ttf" ! -name "*.otf" ! -name "*.woff" -type f -delete

  # Move zip files to the "keptzips-{timestamp}" folder if specified (for all of you /r/datahoarders types)
  if [ "$keep_zips" = true ]; then
    local kept_zips_dir="${destination_dir%/*}/keptzips-$(date +%Y-%m-%d-%H%M)"
    mkdir -p "$kept_zips_dir"
    mv "$source_dir"/*.zip "$kept_zips_dir"
  else
    # Delete zip files
    rm "$source_dir"/*.zip
  fi
}

# Function to collect font files from subdirectories (for when you have a mess of existing unzipped folders already - it goes 3 subdirectories deep by default)
collect_fonts() {
  local destination_dir="collectedfonts-$(date +%Y-%m-%d-%H%M)"
  local keep_original_dirs=false
  local depth=3

  # Process command-line arguments
  while getopts ":s:d:k" opt; do
    case $opt in
      s) source_dir=$OPTARG ;;
      d) destination_dir=$OPTARG ;;
      k) keep_original_dirs=true ;;
      \?) echo "Invalid option: -$OPTARG" >&2 ;;
    esac
  done

  # Create the destination directory if it doesn't exist
  mkdir -p "$destination_dir"

  # Traverse through subdirectories up to the specified depth
  find "$source_dir" -maxdepth "$depth" -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.woff" \) -exec mv {} "$destination_dir" \;

  # Move original directories to the "originaldirs-{timestamp}" folder if specified
  if [ "$keep_original_dirs" = true ]; then
    local original_dirs_dir="${destination_dir%/*}/originaldirs-$(date +%Y-%m-%d-%H%M)"
    mkdir -p "$original_dirs_dir"
    find "$source_dir" -maxdepth "$depth" -type d -exec cp -r {} "$original_dirs_dir" \;
  else
    # Delete original directories
    find "$source_dir" -maxdepth "$depth" -type d -delete
  fi

  # Rename font files using fc-query
  find "$destination_dir" -type f \( -name "*.otf" -o -name "*.ttf" -o -name "*.woff" \) -exec bash -c '
    for font_file; do
      # Get the font family name using fc-query
      font_family=$(fc-query -f "%{family}\n" "$font_file")

      # Format the font family name
      formatted_name=$(echo "$font_family" | sed -e "s/[^[:alnum:]]/_/g" -e "s/\b\(.\)/\u\1/g")

      # Rename the font file
      new_file_name="${font_file%/*}/${formatted_name}.${font_file##*.}"
      mv "$font_file" "$new_file_name"
    done
  ' bash {} +
}

# Process command-line arguments
while getopts ":s:d:k" opt; do
  case $opt in
    s) source_dir=$OPTARG ;;
    d) destination_dir=$OPTARG ;;
    k) keep_zips=true ;;
    \?) echo "Invalid option: -$OPTARG" >&2 ;;
  esac
done

# Check if the source directory is passsed through as an argument from the user
if [ -n "$source_dir" ]; then
  # Call the extract_fonts_from_zips function with the specified source and destination directories
  extract_fonts_from_zips -s "$source_dir" -d "$destination_dir" -k
else
  # Otherwise we move forward with the extract_fonts_from_zips function with default values
  extract_fonts_from_zips -k
fi

# Call the collect_fonts function with default values
collect_fonts
