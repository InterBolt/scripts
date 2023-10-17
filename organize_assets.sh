#!/bin/bash

# if the debug flag is set, print out all commands before running them
if [ "$1" == "--debug" ]; then
  set -x;
else 
  set +x;
fi;

# Make sure all commands run inside of the ~/magik directory
cd ~/magik;

# Convert all jpeg files to jpg and remove the jpeg files
for file in *.jpeg; do
  # Get the file name without the extension
  jpegfilename="${file%.*}";
  # Convert the file to jpg
  convert "$file" "$jpegfilename.jpg";
  # Remove the jpeg file
  rm "$file";
done;

# Create ~/magik/webp if it doesn't exist
if [ ! -d "webp" ]; then
  mkdir webp;
fi;
if [ ! -d "webp/optimized" ]; then
  mkdir webp/optimized;
fi;
# Create ~/magik/jpg if it doesn't exist
if [ ! -d "jpg" ]; then
  mkdir jpg;
fi;
if [ ! -d "webp/optimized" ]; then
  mkdir webp/optimized;
fi;
# Create ~/magik/png if it doesn't exist
if [ ! -d "png" ]; then
  mkdir png;
fi;
if [ ! -d "png/optimized" ]; then
  mkdir png/optimized;
fi;
if [ ! -d "mov" ]; then
  mkdir mov;
fi;
if [ ! -d "mov/optimized" ]; then
  mkdir mov/optimized;
fi;
# Create ~/magik/mp4 if it doesn't exist
if [ ! -d "mp4" ]; then
  mkdir mp4;
fi;
if [ ! -d "mp4/optimized" ]; then
  mkdir mp4/optimized;
fi;
# Create ~/magik/gif if it doesn't exist
if [ ! -d "gif" ]; then
  mkdir gif;
fi;
if [ ! -d "gif/optimized" ]; then
  mkdir gif/optimized;
fi;

# Move all webp files to the ~/magik/webp directory
mv *.webp webp || true;
# Move all png files to the ~/magik/png directory
mv *.png png || true;
# Move all jpg files to the ~/magik/jpg directory
mv *.jpg jpg || true;
# Move all mov files to the ~/magik/mov directory
mv *.mov mov || true;
# Move all mp4 files to the ~/magik/mp4 directory.
mv *.mp4 mp4 || true;
# Move all gif files to the ~/magik/gif directory
mv *.gif gif || true;

echo "Moved all files to their respective directories";

# Copy all of the files in the top level of the ~/magik/mov directory to the ~/magik/mp4 directory
cp -n mov/* mp4 || true;
cp -n jpg/* webp || true;
cp -n png/* webp || true;

echo "Copied all files to their target conversion directories";

for file in webp/*.jpg; do
  # Get the file name without the extension
  jpgfilename="${file%.*}";
  # Convert the file to webp
  cwebp -q 80 "$file" -o "$jpgfilename.webp";
done;

for file in webp/*.png; do
  # Get the file name without the extension
  pngfilename="${file%.*}";
  # Convert the file to webp
  cwebp -q 80 "$file" -o "$pngfilename.webp";
done;

echo "Converted images to webp";

# Convert all mov files in ~/magik/mp4 to mp4
for file in mp4/*.mov; do
  # Get the file name without the extension
  movfilename="${file%.*}";
  # Convert the file to mp4
  ffmpeg -i "$file" -vcodec libx264 -crf 20 "$movfilename.mp4";

  rm "$file";
done;

echo "Converted mov files to mp4";

cp -n mp4/* gif || true;

# Convert all mp4 files in the gif directory to gifs
for file in gif/*.mp4; do
  # Get the file name without the extension
  mp4filename="${file%.*}";
  # Convert the file to gif. Do not keep the mp4 file. Make sure the gif includes all frames.
  ffmpeg -y -i "$file" -vf "fps=24" -loop 0 "$mp4filename.gif";
done;

echo "Converted all videos to gifs";

cp -n webp/* webp/optimized || true;
cp -n png/* png/optimized || true;
cp -n jpg/* jpg/optimized || true;
cp -n mp4/* mp4/optimized || true;
cp -n gif/* gif/optimized || true;

echo "Prepared files for optimization";

# Compress all files in the ~/magik/webp directory using lossless compression
for file in webp/optimized/*.webp; do
  # Get the file name without the extension
  webpfilenametocompress="${file%.*}";
  # Compress the file
  cwebp -lossless "$file" -o "$webpfilenametocompress.webp";
done;

echo "Optimized webp files";

# Compress all files in the ~/magik/jpg directory using lossless compression
for file in jpg/optimized/*.jpg; do
  # Get the file name without the extension
  jpgfilenametocompress="${file%.*}";
  # Compress the file
  jpegoptim --strip-all "$file";
done;

echo "Optimized jpg files";

# Compress all files in the ~/magik/png directory using lossless compression
for file in png/optimized/*.png; do
  # Get the file name without the extension
  pngfilenametocompress="${file%.*}";
  # Compress the file
  pngquant --strip --force --skip-if-larger --output "$pngfilenametocompress.png" "$file";
done;

echo "Optimized png files";

# Compress all files in the ~/magik/gif directory using lossless compression
for file in gif/optimized/*.gif; do
  # Get the file name without the extension
  giffilenametocompress="${file%.*}";
  # Compress the file
  gifsicle -O3 "$file" -o "$giffilenametocompress.gif";
done;

echo "Optimized gif files";

find ~/magik/webp -type f ! -name '*.webp' -delete;
find ~/magik/gif -type f ! -name '*.gif' -delete;
find ~/magik/jpg -type f ! -name '*.jpg' -delete;
find ~/magik/png -type f ! -name '*.png' -delete;
find ~/magik/mp4 -type f ! -name '*.mp4' -delete;

rm -rf ~/magik/mov;

# Print out a success message
echo "Successfully organized ~/magik";

