#!/bin/zsh

myname=`basename $0`

usage () {      # usageを表示する関数を先頭にしておくと親切
  cat<<_EOU_
===== $myname	Run spatialsimulator on docker ===================
Usage          : $myname [option] filename(SBML file only)
 -h            : show this message
 -x #(int)     : the number of points at x coordinate (for analytic geometry only) (ex. -x 100)
 -y #(int)     : the number of points at y coordinate (for analytic geometry only) (ex. -y 100)
 -z #(int)     : the number of points at z coordinate (for analytic geometry only) (ex. -z 100)
 -t #(double)  : simulation time (ex. -t 10)
 -d #(double)  : delta t (ex. -d 0.01)
 -o #(int)     : output results every # steps (ex. -o 10)
 -c #(double)  : min of color bar range (ex. -c 1)
 -C #(double)  : max of color bar range (ex. -C 10)
 -s char#(int) : {x,y,z} and the number of slice (only 3D) (ex. -s z10)
 -O outDir     : path to output directory

(ex)           : $myname -t 0.1 -d 0.001 -o 10 -C 10 sam2d.xml
_EOU_
  exit 0
}

get_abs_filename() {
  # $1 : relative filename
  if [ -d "$(dirname "$1")" ]; then
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  fi
}

# Colors
# http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
# Reset
Color_Off='\033[0m'       # Text Reset

while getopts x:y:z:t:d:o:c:C:s:O:h OPT; do
	case $OPT in
		x)  val_x=$OPTARG
			;;
		y)  val_y=$OPTARG
			;;
		z)  val_z=$OPTARG
			;;
		t)  val_t=$OPTARG
			;;
		d)  val_d=$OPTARG
			;;
		o)  val_o=$OPTARG
			;;
		c)  val_c=$OPTARG
			;;
		C)  val_C=$OPTARG
			;;
		s)  val_s=$OPTARG
			;;
		O)  val_O=$OPTARG
			;;
		h)  usage
			;;
		\?) usage
			;;
	esac
done

shift $((OPTIND - 1))

# is model specified
if [ "$1" = "" ]; then
	usage
fi

# check model exists
if [ ! -f $1 ]; then
	echo "${IRed}File $1 not found.${Color_Off}"
	exit 1
fi
model=$1

if [ "$val_x" ]; then
  option_arg="$option_arg -x $val_x"
fi
if [ "$val_y" ]; then
  option_arg="$option_arg -y $val_y"
fi
if [ "$val_z" ]; then
  option_arg="$option_arg -z $val_z"
fi
if [ "$val_t" ]; then
  option_arg="$option_arg -t $val_t"
fi
if [ "$val_d" ]; then
  option_arg="$option_arg -d $val_d"
fi
if [ "$val_o" ]; then
  option_arg="$option_arg -o $val_o"
fi
if [ "$val_c" ]; then
  option_arg="$option_arg -c $val_c"
fi
if [ "$val_C" ]; then
  option_arg="$option_arg -C $val_C"
fi
if [ "$val_s" ]; then
  option_arg="$option_arg -s $val_s"
fi
# Handle -O option
docker_out_dir="/tmp/outdir"
if [ "$val_O" ]; then
  out_dir=$(get_abs_filename $val_O)
  option_arg="$option_arg -O $docker_out_dir"
  mnt_out="--volume=${out_dir}:${docker_out_dir}"
else
  out_dir="."
  mnt_out="--volume=`pwd`:$docker_out_dir"
fi

# Handle model
docker_model_dir="/tmp/modeldir"
abs_filename=$(get_abs_filename $model)
filename=$(basename $abs_filename)
model_dir=$(dirname $abs_filename)
mnt_model="--volume=${model_dir}:${docker_model_dir}"

#docker run --rm -v `pwd`:/tmp funasoul/spatialsim -t 0.1 -d 0.001 -o 10 -C 10 -O /tmp /tmp/sam2d.xml
cmdline="docker run --rm $mnt_out $mnt_model funasoul/spatialsim $option_arg ${docker_model_dir}/${filename}"
# execute!
eval $cmdline

# check return value
if [ "$?" != "0" ]; then
  echo "${IRed}Simulation failed.${Color_Off}"
  echo "Command was:\n  ${IYellow}${cmdline}${Color_Off}"
  exit 1
fi
echo "Command was:\n  ${IYellow}${cmdline}${Color_Off}"
echo "${IGreen}Simulation result is saved in ${Color_Off}[${out_dir}/result]."
#open ${out_dir}/result
