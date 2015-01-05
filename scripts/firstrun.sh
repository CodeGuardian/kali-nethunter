nhb_firstrun(){
  echo -e "\e[32mSetting variables.\e[0m"
  export date=$(date +%m%d%Y)
  export architecture="armhf"
  export workingdir=$maindir/working-directory
  export rootfsdir=$maindir/rootfs
  export kalirootfs=$rootfsdir/kali-$architecture
  export boottools=$maindir/files/bin/boottools
  export toolchaindir=$maindir/files/toolchains
  export rootfsbuild="source $maindir/scripts/rootfsbuild.sh"
  export kernelbuild="source $maindir/scripts/kernelbuild.sh"

  echo -e "\e[32mChecking for previous installation.\e[0m"
  ### Checks for existing build directory exists
  if [ -d $maindir ]; then
    echo -e "\e[32mPrevious install found.\e[0m"
    cd $maindir
  else
    echo -e "\e[32mNetHunter build directory not found. Downloading required files...\e[0m"
    echo -e "\e[32mCloning NetHunter files to $maindir.\e[0m"
    git clone -b nethunterbuild https://github.com/offensive-security/kali-nethunter $maindir
    mkdir -p $maindir/rootfs
    ### Make Directories and Prepare to build
    echo -e "\e[32mCloning toolchain to $toolchaindir/gcc-arm-linux-gnueabihf-4.7.\e[0m"
    git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7 $toolchaindir/gcc-arm-linux-gnueabihf-4.7
    export PATH=${PATH}:$toolchaindir/gcc-arm-linux-gnueabihf-4.7/bin
    ### Build Dependencies for script
    echo -e "\e[32mUpdating sources.\e[0m"
    apt-get update
    echo -e "\e[32mInstalling dependencies needed to build NetHunter.\e[0m"
    apt-get install -y git-core gnupg flex bison gperf libesd0-dev build-essential zip curl libncurses5-dev zlib1g-dev libncurses5-dev gcc-multilib g++-multilib \
    parted kpartx debootstrap pixz qemu-user-static abootimg cgpt vboot-kernel-utils vboot-utils uboot-mkimage bc lzma lzop automake autoconf m4 dosfstools pixz rsync \
    schedtool git dosfstools e2fsprogs device-tree-compiler ccache dos2unix zip
    echo -e "\e[32mDetermining host architecture.\e[0m"
    MACHINE_TYPE=`uname -m`
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
      dpkg --add-architecture i386
      apt-get update
      apt-get install -y ia32-libs
      # Required for kernel cross compiles
      apt-get install -y libncurses5:i386
    else
      apt-get install -y libncurses5
    fi
    echo -e "\e[32mChecking for /usr/bin/lz4c.\e[0m"
    if [ ! -e "/usr/bin/lz4c" ]; then
      echo -e "\e[32mDownloading and making lz4c for system:\e[0m"
      cd $maindir
      wget http://lz4.googlecode.com/files/lz4-r112.tar.gz
      tar -xf lz4-r112.tar.gz
      cd lz4-r112
      make
      make install
      echo -e "\e[32mlz4c now installed. Removing leftover files.\e[0m"
      cd ..
      rm -rf lz4-r112.tar.gz lz4-r112
    fi
    cd $maindir
  fi
}



while getopts "o:w:" flag; do
  case "$flag" in
    o)
    export outputdir=`pwd`/$OPTARG;;
    w)
    export maindir=`pwd`/$OPTARG;;
  esac
done

nhb_firstrun
rm -- "$0"
