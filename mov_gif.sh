#!/bin/bash

# Function to print usage of current script
function print_usage {
  echo -e "\n$0 - Convert MOV files to gifs using FFMPEG"
  echo -e "\nUsage:\n\t$0 -f <string> [-d <string>] [-g <string>] [-h]"
  echo -e "\nWhere:"
  echo -e "\t-f <string>, --fileName <string>"
  echo -e "\tMOV file to convert"
  echo -e "\tOutput file with the same name and .gif extension is written next"
  echo -e "\tto the input file."
  echo -e "\n\t-d <string>, --dir <string>"
  echo -e "\tConvert all MOV files in this directory to gifs."
  echo -e "\tThe output files are written to a folder with the name 'gifs'"
  echo -e "\tinside the input directory"
  echo -e "\tThis option takes precedence over -f, --filename."
  echo -e "\n\t-g <string>, --geometry <string>"
  echo -e "\tThe geometry of the output file. Default: 800x600."
  echo -e "\n\t-h, --help"
  echo -e "\tDisplay this usage information and exit."
}

# Function that converts a single MOV file to gif file
# Takes 2 arguments -> input output
function convert_mov {
  echo "Converting '$1' to '$2'..."
  ffmpeg -i "$1" -s $3 -pix_fmt rgb24 -r 10 -f gif -| gifsicle --optimize=3 --delay=3 > "$2"
  echo "Converting '$1' to '$2'...Done"
}

if [ $# -eq 0 ];
then
  echo "No arguments provided." >&2
  print_usage >&2
  exit 1;
fi

optspec=":hfdg-:"
fileName=""
dirName=""
geometry="800x600"
while getopts "$optspec" opt; do
  case ${opt} in
    -)
      case "${OPTARG}" in
        help)
          print_usage
          exit 1
          ;;
        fileName)
          fileName="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          echo "Parsing option: '--${OPTARG}', value: '${fileName}'"
          ;;
        dir)
          dirName="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          echo "Parsing option: '--${OPTARG}', value: '${dirName}'"
          ;;
        geometry)
          geometry="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
          echo "Parsing option: '--${OPTARG}', value: '${geometry}'"
          ;;
        *)
          if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
            echo "Unknown option --${OPTARG}" >&2
            print_usage >&2
            exit 1
          fi
          ;;
      esac;;
          
    h)
      print_usage
      exit 1
      ;;
    f)
      fileName="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
      echo "Parsing option: '-${opt}', value: '${fileName}'"
      ;;
    d)
      dirName="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
      echo "Parsing option: '-${opt}', value: '${dirName}'"
      ;;
    g)
      geometry="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
      echo "Parsing option: '-${opt}', value: '${geometry}'"
      ;;
    *)
      echo "Invalid option: -${OPTARG}" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [ -z "$fileName" ] && [ -z "$dirName" ]; then
  echo "No filename or directory provided." >&2
  print_usage
  exit 1
fi

if [ -n "$dirName" ]; then
  if [ ! -d "$dirName" ]; then
    echo "Directory '$dirName' not a valid directory" >&2
    exit 1
  else
    echo "Processing MOV files in $dirName"
    outdirName=$dirName/gifs
    if [ ! -d $outdirName ]; then
      echo -n "Output directory '$outdirName' does not exist. Creating..."
      mkdir -p $outdirName
      echo "Done"
    fi
    for filename in $dirName/*.mov; do
      outfilename="$(basename "$filename")"
      outfilename="${outfilename/"mov"/gif}"
      outfilename="$outdirName/$outfilename"
      convert_mov "$filename" "$outfilename" "$geometry"
    done
  fi
else
    if [ -n "$fileName" ]; then
      if [ -f "$fileName" ]; then
        outfilename="${fileName/"mov"/gif}"
        convert_mov "$fileName" "$outfilename" "$geometry"
      else
        echo "File '$fileName' not a valid file" >&2
        exit 1
      fi
    fi
fi
