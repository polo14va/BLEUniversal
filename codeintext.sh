#!/bin/bash

# Define el directorio raíz del proyecto y el archivo de salida
root_directory="/Users/pedro/Documents/UOC/TFG/BLEuniversal/BLEuniversal"
output_file="codeintext.txt"
temp_file="temp_tree.txt"

# Borra el archivo de salida y el archivo temporal si ya existen
rm -f "$output_file" "$temp_file"

# Genera el árbol del directorio y guarda la salida en el archivo temporal
tree "$root_directory" > "$temp_file"

# Encuentra archivos .swift y .plist y procesa cada uno
# Note el uso de 'find ... -print0 | while IFS= read -r -d $'\0' file; do' para manejar nombres de archivo complejos
find "$root_directory" \( -name "*.swift" -o -name "*.plist" \) -print0 | while IFS= read -r -d $'\0' file; do
    if [ -f "$file" ]; then
        relative_path="${file#$root_directory/}"
        echo "Path: $relative_path" >> "$output_file"
        echo "" >> "$output_file"
        cat "$file" >> "$output_file"
        echo "" >> "$output_file"
        echo "" >> "$output_file"
    else
        echo "File not found: $file" >> "$output_file"
    fi
done

# Concatena el árbol del directorio al principio del archivo de salida
cat "$temp_file" "$output_file" > "$output_file.tmp"
mv "$output_file.tmp" "$output_file"

# Borra el archivo temporal
rm -f "$temp_file"

echo "Los archivos han sido consolidados en $output_file."
