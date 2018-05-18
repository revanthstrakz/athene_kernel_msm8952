#!/usr/bin/env bash

source "SK/scripts/env.sh";
setperf

# Kernel compiling script

function check_toolchain() {

    export TC="$(find ${TOOLCHAIN}/bin -type f -name *-gcc)";

	if [[ -f "${TC}" ]]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/$(echo ${TC} | awk -F '/' '{print $NF'} |\
sed -e 's/gcc//')";
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)";
	else
		echo -e "No suitable toolchain found in ${TOOLCHAIN}";
		exit 1;
	fi
}

if [[ -z ${KERNELDIR} ]]; then
    echo -e "Please set KERNELDIR";
    exit 1;
fi

export DEVICE=$1;
if [[ -z ${DEVICE} ]]; then
    export DEVICE="mido";
fi

export SRCDIR="${KERNELDIR}/${DEVICE}";
export OUTDIR="${KERNELDIR}/out";
export ANYKERNEL="${KERNELDIR}/SK/anykernel/";
export ARCH="arm64";
export SUBARCH="arm64";
export TOOLCHAIN="${HOME}/LINARO/7.x";
export DEFCONFIG="strakz_defconfig";
export ZIP_DIR="${KERNELDIR}/SK/files/";
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";
export IMAGE2="${OUTDIR}/arch/${ARCH}/boot/Image.gz";
export VERSION="🐼😂";
export KBUILD_BUILD_USER="ReVaNtH";
export KBUILD_BUILD_HOST="StRaKz";
export CLANG_PATH=/home/adesikha15/clang/clang-4679922/bin
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CLANG_TCHAIN="${HOME}/clang/clang-4679922/bin/clang"
export KBUILD_COMPILER_STRING="$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"


if [[ -z "${JOBS}" ]]; then
    export JOBS="32";
fi

export MAKE="make O=${OUTDIR}";
check_toolchain;

export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F '(' '{print $2}' | awk '{print tolower($1)}')"
export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F ')' '{print $2}' | awk '{print tolower($1)}')"
export ZIPNAME="StRaKz_KeRnEl-${TCVERSION1}.${TCVERSION2}-${DEVICE}-$(date +%Y%m%d-%H%M).zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-opt-linux-android-"

[ ! -d "${ZIP_DIR}" ] && mkdir -pv ${ZIP_DIR}
[ ! -d "${OUTDIR}" ] && mkdir -pv ${OUTDIR}

cd "${SRCDIR}";
rm -fv ${IMAGE};

# if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
# fi

# if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
# fi
${MAKE} CC=clang strakz_defconfig

START=$(date +"%s");

exitCode="$?";
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

make CC=clang -j${JOBS} O=out/

echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";
cp -v "${IMAGE2}" "${ANYKERNEL}/";
cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
transfer "${FINAL_ZIP}";
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check 
rm -fv ${IMAGE2};
rm -fv ${FINAL_ZIP};
${MAKE} $DEFCONFIG;
${MAKE} -j${JOBS};
echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";
cp -v "${IMAGE2}" "${ANYKERNEL}/";
cp ${KERNEL_DIR}/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-mido-nontreble.dtb ${ANYKERNEL}/

cp ${KERNELDIR}/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-mido-treble.dtb ${ANYKERNEL}/




cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
transfer "${FINAL_ZIP}";
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check 
